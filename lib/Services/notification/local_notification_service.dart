import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Helpers/logger.dart';
import '../../Helpers/notification_helper.dart';
import '../../Models/appointments/salon_appointments_model.dart';
import '../../Services/enums/appointment_status.dart';

/// Statuses for which a reminder should exist while the start time is in the
/// future.
const _remindableStatuses = {
  AppointmentStatus.scheduled,
  AppointmentStatus.pending,
  AppointmentStatus.checkedIn,
};

/// A scheduled reminder record, used for dedup and drift detection.
class ScheduledReminder {
  const ScheduledReminder({
    required this.notificationId,
    required this.appointmentId,
    required this.reminderTime,
  });

  final int notificationId;
  final String appointmentId;
  final DateTime reminderTime;

  Map<String, dynamic> toJson() => {
    'notification_id': notificationId,
    'appointment_id': appointmentId,
    'reminder_time': reminderTime.toIso8601String(),
  };

  static ScheduledReminder? fromJson(Map<String, dynamic> json) {
    final notificationId = json['notification_id'] as int?;
    final appointmentId = json['appointment_id'] as String?;
    final reminderTime = DateTime.tryParse(
      json['reminder_time'] as String? ?? '',
    );
    if (notificationId == null ||
        appointmentId == null ||
        reminderTime == null) {
      return null;
    }
    return ScheduledReminder(
      notificationId: notificationId,
      appointmentId: appointmentId,
      reminderTime: reminderTime,
    );
  }
}

/// Internal seam for scheduling/cancelling so the reconcile decision logic can
/// be unit-tested without platform channels. The default implementation
/// delegates to [NotificationHelper].
class NotificationScheduler {
  Future<void> scheduleReminder({
    required String appointmentId,
    required String customerName,
    required DateTime appointmentTime,
    required String salonName,
    Duration reminderBefore = const Duration(hours: 1),
  }) => NotificationHelper().scheduleAppointmentReminder(
    appointmentId: appointmentId,
    customerName: customerName,
    appointmentTime: appointmentTime,
    salonName: salonName,
    reminderBefore: reminderBefore,
  );

  Future<void> cancel(int notificationId) =>
      NotificationHelper().cancelNotification(notificationId);
}

/// Key/value persistence seam for the scheduled-reminder registry. The default
/// implementation uses SharedPreferences directly so it works even when
/// [UnifiedStorageService] has not been initialized.
class ReminderStore {
  static const String prefsKey = 'scheduled_appointment_reminders_v1';

  Future<List<ScheduledReminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => ScheduledReminder.fromJson(Map<String, dynamic>.from(e)))
          .whereType<ScheduledReminder>()
          .toList();
    } catch (e) {
      AppLogger.error('Failed to parse scheduled reminders store', error: e);
      return [];
    }
  }

  Future<void> save(List<ScheduledReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsKey,
      json.encode(reminders.map((r) => r.toJson()).toList()),
    );
  }
}

/// Orchestrates local appointment reminders on top of [NotificationHelper].
///
/// Reconcile is the source of truth: given the current appointment list it
/// ensures exactly one reminder per upcoming remindable appointment and
/// cancels reminders for appointments that are past, finished, or gone.
///
/// Notification ids are derived as `appointment.id.hashCode & 0x7fffffff`,
/// which is deterministic but not collision-free. The persisted registry is
/// keyed by appointment id so collisions are detected (the displaced
/// appointment simply gets rescheduled on the next reconcile); with a single
/// user's upcoming appointments the collision probability is negligible.
///
/// The service is immutable-configured: inject test doubles by constructing
/// a new instance via [LocalNotificationService.new], e.g.
/// `LocalNotificationService(scheduler: fake, store: fake)`.
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal(
        NotificationScheduler(),
        ReminderStore(),
      );

  factory LocalNotificationService({
    NotificationScheduler? scheduler,
    ReminderStore? store,
  }) {
    if (scheduler != null || store != null) {
      // Fresh instance with the provided seams — intended for tests. Does not
      // touch the shared singleton.
      return LocalNotificationService._internal(
        scheduler ?? NotificationScheduler(),
        store ?? ReminderStore(),
      );
    }
    return _instance;
  }

  LocalNotificationService._internal(this._scheduler, this._store);

  final NotificationScheduler _scheduler;
  final ReminderStore _store;

  /// In-memory mirror of the persisted registry, keyed by appointment id.
  /// Null until the first reconcile loads it from disk.
  Map<String, ScheduledReminder>? _registry;

  static const Duration reminderBefore = Duration(hours: 1);

  /// Deterministic notification id for an appointment.
  static int notificationIdFor(String appointmentId) =>
      appointmentId.hashCode & 0x7fffffff;

  /// The moment the reminder for [appointment] should fire.
  static DateTime reminderTimeFor(SalonAppointment appointment) =>
      appointment.startTime.subtract(reminderBefore);

  /// Whether [appointment] should have a scheduled reminder right now.
  static bool shouldSchedule(SalonAppointment appointment) {
    return _remindableStatuses.contains(appointment.status) &&
        reminderTimeFor(appointment).isAfter(DateTime.now());
  }

  /// Reconciles scheduled reminders with the current appointment list.
  ///
  /// Idempotent: safe to call repeatedly, and a second call with unchanged
  /// data performs no schedule/cancel operations.
  ///
  /// [salonNameResolver] maps `SalonAppointment.salonId` to a display name
  /// (wired to SalonProvider at the call site); a generic fallback is used
  /// when it returns null.
  Future<void> reconcileAppointments(
    List<SalonAppointment> appointments, {
    String? Function(int salonId)? salonNameResolver,
  }) async {
    try {
      final registry = await _loadRegistry();
      final seenIds = <String>{};

      for (final appointment in appointments) {
        if (appointment.id.isEmpty) continue;
        seenIds.add(appointment.id);
        await _apply(appointment, registry, salonNameResolver);
      }

      // Cancel reminders for appointments that vanished from the list.
      final orphaned = registry.keys
          .where((id) => !seenIds.contains(id))
          .toList();
      for (final id in orphaned) {
        await _scheduler.cancel(registry[id]!.notificationId);
        registry.remove(id);
      }

      await _saveRegistry(registry);
    } catch (e) {
      AppLogger.error('Failed to reconcile appointment reminders', error: e);
    }
  }

  /// Applies the schedule/cancel decision for a single appointment to
  /// [registry]. Does not sweep orphans and does not persist.
  Future<void> _apply(
    SalonAppointment appointment,
    Map<String, ScheduledReminder> registry,
    String? Function(int salonId)? salonNameResolver,
  ) async {
    final existing = registry[appointment.id];

    if (shouldSchedule(appointment)) {
      final reminderTime = reminderTimeFor(appointment);
      if (existing != null && existing.reminderTime == reminderTime) {
        return; // Already scheduled for the same time — no duplicate.
      }
      if (existing != null) {
        // Time changed: cancel the stale reminder before rescheduling.
        await _scheduler.cancel(existing.notificationId);
      }
      final notificationId = notificationIdFor(appointment.id);
      await _scheduler.scheduleReminder(
        appointmentId: appointment.id,
        customerName: appointment.customerName ?? '',
        appointmentTime: appointment.startTime,
        salonName: salonNameResolver?.call(appointment.salonId) ?? 'your salon',
        reminderBefore: reminderBefore,
      );
      registry[appointment.id] = ScheduledReminder(
        notificationId: notificationId,
        appointmentId: appointment.id,
        reminderTime: reminderTime,
      );
    } else if (existing != null) {
      // Past, completed, cancelled, or no-show: cancel its reminder.
      await _scheduler.cancel(existing.notificationId);
      registry.remove(appointment.id);
    }
  }

  /// Schedules (or reschedules) the reminder for a single appointment,
  /// without touching reminders for any other appointment.
  Future<void> scheduleReminder(
    SalonAppointment appointment, {
    String? Function(int salonId)? salonNameResolver,
  }) async {
    try {
      final registry = await _loadRegistry();
      await _apply(appointment, registry, salonNameResolver);
      await _saveRegistry(registry);
    } catch (e) {
      AppLogger.error(
        'Failed to schedule reminder for appointment ${appointment.id}',
        error: e,
      );
    }
  }

  /// Cancels the reminder for [appointmentId], if one is scheduled.
  Future<void> cancelReminder(String appointmentId) async {
    try {
      final registry = await _loadRegistry();
      final existing = registry.remove(appointmentId);
      if (existing != null) {
        await _scheduler.cancel(existing.notificationId);
        await _saveRegistry(registry);
      }
    } catch (e) {
      AppLogger.error(
        'Failed to cancel reminder for appointment $appointmentId',
        error: e,
      );
    }
  }

  Future<Map<String, ScheduledReminder>> _loadRegistry() async {
    final cached = _registry;
    if (cached != null) return cached;
    final loaded = <String, ScheduledReminder>{
      for (final r in await _store.load()) r.appointmentId: r,
    };
    _registry = loaded;
    return loaded;
  }

  Future<void> _saveRegistry(Map<String, ScheduledReminder> registry) =>
      _store.save(registry.values.toList());
}
