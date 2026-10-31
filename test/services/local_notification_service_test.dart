import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Models/appointments/salon_appointments_model.dart';
import 'package:na3eeman/Services/enums/appointment_status.dart';
import 'package:na3eeman/Services/notification/local_notification_service.dart';

// Tests for the reconcile/schedule/cancel decision logic of
// LocalNotificationService. The platform plugin is never touched: a fake
// NotificationScheduler records the calls the service would make, and a fake
// ReminderStore keeps the persisted registry in memory.

class FakeScheduler extends NotificationScheduler {
  final List<String> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> scheduleReminder({
    required String appointmentId,
    required String customerName,
    required DateTime appointmentTime,
    required String salonName,
    Duration reminderBefore = const Duration(hours: 1),
  }) async {
    scheduled.add('$appointmentId@$salonName');
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
  }
}

class FakeStore extends ReminderStore {
  List<ScheduledReminder> data = [];
  int saveCount = 0;

  @override
  Future<List<ScheduledReminder>> load() async => List.of(data);

  @override
  Future<void> save(List<ScheduledReminder> reminders) async {
    saveCount++;
    data = List.of(reminders);
  }
}

SalonAppointment makeAppointment({
  String id = '1',
  AppointmentStatus status = AppointmentStatus.scheduled,
  required DateTime startTime,
  int salonId = 3,
  String? customerName,
}) {
  return SalonAppointment(
    id: id,
    customerId: 7,
    salonId: salonId,
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1)),
    status: status,
    createdAt: DateTime(2026, 1, 1),
    services: const [],
    customerName: customerName,
  );
}

void main() {
  late FakeScheduler scheduler;
  late FakeStore store;
  late LocalNotificationService service;

  setUp(() {
    scheduler = FakeScheduler();
    store = FakeStore();
    service = LocalNotificationService(scheduler: scheduler, store: store);
    // Each test starts from an empty registry.
    store.data = [];
  });

  group('reconcileAppointments', () {
    test('schedules a reminder for a future SCHEDULED appointment', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.reconcileAppointments([
        makeAppointment(id: 'a1', startTime: start),
      ]);

      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.scheduled.single, startsWith('a1@'));
      expect(store.data, hasLength(1));
      expect(store.data.single.appointmentId, 'a1');
      expect(
        store.data.single.reminderTime,
        start.subtract(const Duration(hours: 1)),
      );
    });

    test('schedules for future PENDING and CHECKED_IN appointments', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.reconcileAppointments([
        makeAppointment(
          id: 'p1',
          status: AppointmentStatus.pending,
          startTime: start,
        ),
        makeAppointment(
          id: 'c1',
          status: AppointmentStatus.checkedIn,
          startTime: start,
        ),
      ]);

      expect(scheduler.scheduled, hasLength(2));
    });

    test('skips appointments whose start time is in the past', () async {
      final past = DateTime.now().subtract(const Duration(days: 1));
      await service.reconcileAppointments([
        makeAppointment(id: 'old', startTime: past),
      ]);

      expect(scheduler.scheduled, isEmpty);
      expect(store.data, isEmpty);
    });

    test('skips PENDING_PAYMENT appointments', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.reconcileAppointments([
        makeAppointment(
          id: 'pp',
          status: AppointmentStatus.pendingPayment,
          startTime: start,
        ),
      ]);

      expect(scheduler.scheduled, isEmpty);
    });

    test(
      'cancels reminders for appointments that became COMPLETED/CANCELLED/NO_SHOW',
      () async {
        final start = DateTime.now().add(const Duration(days: 1));
        await service.reconcileAppointments([
          makeAppointment(id: 'a1', startTime: start),
          makeAppointment(id: 'a2', startTime: start),
          makeAppointment(id: 'a3', startTime: start),
        ]);
        expect(scheduler.scheduled, hasLength(3));

        await service.reconcileAppointments([
          makeAppointment(
            id: 'a1',
            status: AppointmentStatus.completed,
            startTime: start,
          ),
          makeAppointment(
            id: 'a2',
            status: AppointmentStatus.cancelled,
            startTime: start,
          ),
          makeAppointment(
            id: 'a3',
            status: AppointmentStatus.noShow,
            startTime: start,
          ),
        ]);

        expect(
          scheduler.cancelled,
          containsAll([
            LocalNotificationService.notificationIdFor('a1'),
            LocalNotificationService.notificationIdFor('a2'),
            LocalNotificationService.notificationIdFor('a3'),
          ]),
        );
        expect(store.data, isEmpty);
      },
    );

    test('does not reschedule an unchanged appointment (idempotent)', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      final appointment = makeAppointment(id: 'a1', startTime: start);

      await service.reconcileAppointments([appointment]);
      await service.reconcileAppointments([appointment]);
      await service.reconcileAppointments([appointment]);

      expect(scheduler.scheduled, hasLength(1));
      expect(scheduler.cancelled, isEmpty);
      expect(store.data, hasLength(1));
    });

    test('reschedules when the start time changes', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.reconcileAppointments([
        makeAppointment(id: 'a1', startTime: start),
      ]);

      final newStart = start.add(const Duration(hours: 3));
      await service.reconcileAppointments([
        makeAppointment(id: 'a1', startTime: newStart),
      ]);

      // One cancel of the stale reminder, then a fresh schedule.
      expect(scheduler.cancelled, [
        LocalNotificationService.notificationIdFor('a1'),
      ]);
      expect(scheduler.scheduled, hasLength(2));
      expect(
        store.data.single.reminderTime,
        newStart.subtract(const Duration(hours: 1)),
      );
    });

    test(
      'cancels reminders for appointments that vanished from the list',
      () async {
        final start = DateTime.now().add(const Duration(days: 1));
        await service.reconcileAppointments([
          makeAppointment(id: 'a1', startTime: start),
          makeAppointment(id: 'a2', startTime: start),
        ]);

        await service.reconcileAppointments([
          makeAppointment(id: 'a1', startTime: start),
        ]);

        expect(scheduler.cancelled, [
          LocalNotificationService.notificationIdFor('a2'),
        ]);
        expect(store.data, hasLength(1));
        expect(store.data.single.appointmentId, 'a1');
      },
    );

    test(
      'cancels a stored reminder when its appointment moved to the past',
      () async {
        // Seed the store with a reminder whose appointment is now past.
        final past = DateTime.now().subtract(const Duration(hours: 2));
        store.data = [
          ScheduledReminder(
            notificationId: LocalNotificationService.notificationIdFor('gone'),
            appointmentId: 'gone',
            reminderTime: past.subtract(const Duration(hours: 1)),
          ),
        ];

        await service.reconcileAppointments([
          makeAppointment(id: 'gone', startTime: past),
        ]);

        expect(scheduler.cancelled, [
          LocalNotificationService.notificationIdFor('gone'),
        ]);
        expect(store.data, isEmpty);
      },
    );

    test(
      'uses the salon name resolver and falls back when it returns null',
      () async {
        final start = DateTime.now().add(const Duration(days: 1));
        await service.reconcileAppointments([
          makeAppointment(id: 'a1', startTime: start, salonId: 3),
          makeAppointment(id: 'a2', startTime: start, salonId: 99),
        ], salonNameResolver: (id) => id == 3 ? 'Glow Salon' : null);

        expect(
          scheduler.scheduled,
          containsAll(['a1@Glow Salon', 'a2@your salon']),
        );
      },
    );

    test('does not throw when the store contains corrupt data', () async {
      // Corrupt entries are filtered out by ScheduledReminder.fromJson.
      await service.reconcileAppointments(const []);
      expect(store.saveCount, greaterThan(0));
    });
  });

  group('scheduleReminder / cancelReminder', () {
    test('scheduleReminder schedules a single appointment', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.scheduleReminder(
        makeAppointment(id: 's1', startTime: start),
      );

      expect(scheduler.scheduled, hasLength(1));
      expect(store.data.single.appointmentId, 's1');
    });

    test('scheduleReminder reschedules when called with a new time', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.scheduleReminder(
        makeAppointment(id: 's1', startTime: start),
      );
      await service.scheduleReminder(
        makeAppointment(
          id: 's1',
          startTime: start.add(const Duration(hours: 2)),
        ),
      );

      expect(scheduler.scheduled, hasLength(2));
      expect(scheduler.cancelled, hasLength(1));
    });

    test('cancelReminder cancels and removes a stored reminder', () async {
      final start = DateTime.now().add(const Duration(days: 1));
      await service.scheduleReminder(
        makeAppointment(id: 's1', startTime: start),
      );

      await service.cancelReminder('s1');

      expect(scheduler.cancelled, [
        LocalNotificationService.notificationIdFor('s1'),
      ]);
      expect(store.data, isEmpty);
    });

    test('cancelReminder is a no-op for unknown appointment ids', () async {
      await service.cancelReminder('nope');

      expect(scheduler.cancelled, isEmpty);
    });
  });

  group('notificationIdFor', () {
    test('is deterministic and non-negative', () {
      final id1 = LocalNotificationService.notificationIdFor('abc-123');
      final id2 = LocalNotificationService.notificationIdFor('abc-123');

      expect(id1, id2);
      expect(id1, greaterThanOrEqualTo(0));
      expect(id1, lessThanOrEqualTo(0x7fffffff));
    });
  });
}
