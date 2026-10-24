import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Models/appointments/booking_group_model.dart';
import 'package:na3eeman/Models/appointments/salon_appointments_model.dart';
import 'package:na3eeman/Models/appointments/soonest_appointment_model.dart';
import 'package:na3eeman/Services/enums/appointment_status.dart';
import 'package:na3eeman/Services/enums/attendee_type.dart';
import 'package:na3eeman/Services/enums/recurrence_type.dart';

// Characterization tests for the appointment booking models.
// They pin down CURRENT fromJson/toJson behavior — including quirks — so a
// refactoring that changes parsing breaks loudly here.
void main() {
  group('SalonAppointment.fromJson', () {
    Map<String, dynamic> fullPayload() {
      return {
        'id': 42,
        'customer': 7,
        'salon': 3,
        'expert': 11,
        'start_time': '2026-11-01T10:00:00.000',
        'end_time': '2026-11-01T11:00:00.000',
        'arrival_time': '2026-11-01T09:55:00.000',
        'status': 'SCHEDULED',
        'is_free': false,
        'booking_group_id': 99,
        'style': 5,
        'attendee_type': 'FRIEND',
        'recurrence': 'WEEKLY',
        'recurrence_end_date': '2026-12-01T10:00:00.000',
        'created_at': '2026-10-20T08:30:00.000',
        'services': [
          {
            'service_type': 'OPTION',
            'option': 21,
            'package': null,
            'product': null,
            'service_name': 'Haircut',
            'quantity': 1,
          },
        ],
        'payment': {
          'id': 'pay_1',
          'appointment': '42',
          'amount': 150,
          'method': 'CASH',
          'status': 'PAID',
          'transaction_id': 'txn_123',
          'is_deposit': true,
          'paid_at': '2026-11-01T11:05:00.000',
          'reported_at': null,
        },
        'is_gift': true,
        'gift_receiver_name': 'Sara',
        'gift_receiver_phone': '+966500000000',
        'gift_receiver_gender': 'FEMALE',
        'gift_relation': 'Sister',
        'gift_message': 'Happy birthday',
        'gift_link': 'https://example.com/gift/abc',
        'total_amount': 150,
        'deposit_amount': 50.5,
      };
    }

    test('parses a full realistic payload', () {
      final appt = SalonAppointment.fromJson(fullPayload());

      // Quirk: numeric ids are stringified via .toString().
      expect(appt.id, '42');
      expect(appt.bookingGroupId, '99');
      expect(appt.customerId, 7);
      expect(appt.salonId, 3);
      expect(appt.expertId, 11);
      expect(appt.startTime, DateTime.parse('2026-11-01T10:00:00.000'));
      expect(appt.endTime, DateTime.parse('2026-11-01T11:00:00.000'));
      expect(appt.arrivalTime, DateTime.parse('2026-11-01T09:55:00.000'));
      expect(appt.status, AppointmentStatus.scheduled);
      expect(appt.isFree, isFalse);
      expect(appt.requestedStyleId, 5);
      expect(appt.attendeeType, AttendeeType.friend);
      expect(appt.recurrence, RecurrenceType.weekly);
      expect(appt.recurrenceEndDate, DateTime.parse('2026-12-01T10:00:00.000'));
      expect(appt.createdAt, DateTime.parse('2026-10-20T08:30:00.000'));
      expect(appt.services, hasLength(1));
      expect(appt.isGift, isTrue);
      expect(appt.giftReceiverName, 'Sara');
      expect(appt.giftReceiverPhone, '+966500000000');
      expect(appt.giftReceiverGender, 'FEMALE');
      expect(appt.giftRelation, 'Sister');
      expect(appt.giftMessage, 'Happy birthday');
      expect(appt.giftLink, 'https://example.com/gift/abc');

      // Quirk: ints are coerced to double via (num).toDouble().
      expect(appt.totalAmount, 150.0);
      expect(appt.totalAmount, isA<double>());
      expect(appt.depositAmount, 50.5);
    });

    test('applies defaults for missing optional fields', () {
      final appt = SalonAppointment.fromJson({
        'start_time': '2026-11-01T10:00:00.000',
        'end_time': '2026-11-01T11:00:00.000',
        'created_at': '2026-10-20T08:30:00.000',
      });

      // Quirk: missing id / customer / salon become '' / 0 / 0, not errors.
      expect(appt.id, '');
      expect(appt.customerId, 0);
      expect(appt.salonId, 0);
      expect(appt.expertId, isNull);
      expect(appt.status, AppointmentStatus.scheduled); // default 'SCHEDULED'
      expect(appt.attendeeType, AttendeeType.self); // default 'SELF'
      expect(appt.isFree, isFalse);
      expect(appt.isGift, isFalse);
      expect(appt.recurrence, isNull);
      expect(appt.recurrenceEndDate, isNull);
      expect(appt.services, isEmpty); // missing 'services' -> []
      expect(appt.payment, isNull);
      expect(appt.totalAmount, isNull);
      expect(appt.depositAmount, isNull);
    });

    test('throws TypeError when a required date field is missing', () {
      // Current behavior: `json['start_time'] as String` on a missing key
      // throws a TypeError (null is not a String), not a FormatException.
      expect(
        () => SalonAppointment.fromJson({
          'end_time': '2026-11-01T11:00:00.000',
          'created_at': '2026-10-20T08:30:00.000',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('unknown status and attendee type fall back to scheduled/self', () {
      final appt = SalonAppointment.fromJson({
        'start_time': '2026-11-01T10:00:00.000',
        'end_time': '2026-11-01T11:00:00.000',
        'created_at': '2026-10-20T08:30:00.000',
        'status': 'SOMETHING_NEW',
        'attendee_type': 'FAMILY', // enum has no FAMILY value
      });
      expect(appt.status, AppointmentStatus.scheduled);
      expect(appt.attendeeType, AttendeeType.self);
    });

    test('customer as a nested map throws TypeError (quirk)', () {
      // Current behavior: 'customer' is read first as `as int?` (line 71),
      // so a nested customer MAP — the shape the customerName getter at
      // line 112 expects — never survives parsing; it throws a TypeError.
      expect(
        () => SalonAppointment.fromJson({
          'start_time': '2026-11-01T10:00:00.000',
          'end_time': '2026-11-01T11:00:00.000',
          'created_at': '2026-10-20T08:30:00.000',
          'customer': {'first_name': 'Mona', 'last_name': 'Ali'},
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('customer as an int id leaves customerName null', () {
      final appt = SalonAppointment.fromJson({
        'start_time': '2026-11-01T10:00:00.000',
        'end_time': '2026-11-01T11:00:00.000',
        'created_at': '2026-10-20T08:30:00.000',
        'customer': 7,
      });
      expect(appt.customerId, 7);
      // Quirk: customerName is therefore always null in practice.
      expect(appt.customerName, isNull);
    });

    test('expertName builds from expert_info map', () {
      final appt = SalonAppointment.fromJson({
        'start_time': '2026-11-01T10:00:00.000',
        'end_time': '2026-11-01T11:00:00.000',
        'created_at': '2026-10-20T08:30:00.000',
        'expert': 11,
        'expert_info': {'first_name': 'Khalid', 'last_name': 'Omar'},
      });
      expect(appt.expertName, 'Khalid Omar');
      expect(appt.expertId, 11);
    });

    test('paymentStatus falls back to PENDING when payment is null', () {
      final appt = SalonAppointment.fromJson({
        'start_time': '2026-11-01T10:00:00.000',
        'end_time': '2026-11-01T11:00:00.000',
        'created_at': '2026-10-20T08:30:00.000',
      });
      expect(appt.paymentStatus, 'PENDING');
    });
  });

  group('SalonAppointment.toJson', () {
    test('emits the booking request shape (no id/customer/status)', () {
      final appt = SalonAppointment(
        id: '42',
        customerId: 7,
        salonId: 3,
        expertId: 11,
        startTime: DateTime.parse('2026-11-01T10:00:00.000'),
        endTime: DateTime.parse('2026-11-01T11:00:00.000'),
        status: AppointmentStatus.completed,
        attendeeType: AttendeeType.friend,
        recurrence: RecurrenceType.biweekly,
        recurrenceEndDate: DateTime.parse('2026-12-01T10:00:00.000'),
        createdAt: DateTime.parse('2026-10-20T08:30:00.000'),
        services: [
          AppointmentServiceModel(
            serviceType: 'OPTION',
            optionId: 21,
            name: 'Haircut',
          ),
        ],
        requestedStyleId: 5,
        totalAmount: 150.0,
      );

      final json = appt.toJson();

      // Quirk: toJson is request-shaped — it does NOT round-trip with
      // fromJson (id, customer, status, created_at, payment are absent).
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('customer'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json['salon'], 3);
      expect(json['expert'], 11);
      expect(json['start_time'], '2026-11-01T10:00:00.000');
      expect(json['end_time'], '2026-11-01T11:00:00.000');
      expect(json['attendee_type'], 'FRIEND');
      expect(json['recurrence'], 'BIWEEKLY');
      expect(json['recurrence_end_date'], '2026-12-01T10:00:00.000');
      expect(json['style'], 5);
      expect(json['is_gift'], isFalse);
      expect(json['total_amount'], 150.0);
      expect(json['deposit_amount'], isNull);
      expect(json['services'], hasLength(1));
      expect(json['services'][0]['service_type'], 'OPTION');
    });
  });

  group('AppointmentServiceModel', () {
    test('parses a service option entry', () {
      final service = AppointmentServiceModel.fromJson({
        'service_type': 'OPTION',
        'option': 21,
        'package': null,
        'product': null,
        'service_name': 'Haircut',
        'quantity': 2,
      });
      expect(service.serviceType, 'OPTION');
      expect(service.optionId, 21);
      expect(service.packageId, isNull);
      expect(service.productId, isNull);
      expect(service.name, 'Haircut');
      expect(service.quantity, 2);
    });

    test('name falls back from service_name to name to "Service"', () {
      final fromName = AppointmentServiceModel.fromJson({
        'service_type': 'PRODUCT',
        'product': 9,
        'name': 'Shampoo',
      });
      expect(fromName.name, 'Shampoo');

      final fallback = AppointmentServiceModel.fromJson({
        'service_type': 'PACKAGE',
        'package': 4,
      });
      expect(fallback.name, 'Service');
      expect(fallback.quantity, 1); // default
    });

    test('throws when service_type is missing', () {
      // `json['service_type'] as String` with a missing key -> TypeError.
      expect(
        () => AppointmentServiceModel.fromJson({'option': 21}),
        throwsA(isA<TypeError>()),
      );
    });

    test('toJson omits the name field (one-way round trip)', () {
      final service = AppointmentServiceModel(
        serviceType: 'OPTION',
        optionId: 21,
        name: 'Haircut',
        quantity: 2,
      );
      final json = service.toJson();

      // Quirk: `name` is parsed on the way in but never serialized out.
      expect(json.containsKey('service_name'), isFalse);
      expect(json.containsKey('name'), isFalse);
      expect(json, {
        'service_type': 'OPTION',
        'option': 21,
        'package': null,
        'product': null,
        'quantity': 2,
      });

      final reparsed = AppointmentServiceModel.fromJson(json);
      expect(reparsed.name, 'Service'); // name is lost on round trip
      expect(reparsed.quantity, 2);
    });
  });

  group('Payment', () {
    test('parses a full payment payload', () {
      final payment = Payment.fromJson({
        'id': 9,
        'appointment': 42,
        'amount': 150,
        'method': 'VISA',
        'status': 'PAID',
        'transaction_id': 'txn_123',
        'is_deposit': true,
        'paid_at': '2026-11-01T11:05:00.000',
        'reported_at': '2026-11-02T09:00:00.000',
      });

      // Quirk: numeric ids are stringified; amount is coerced to double.
      expect(payment.id, '9');
      expect(payment.appointmentId, '42');
      expect(payment.amount, 150.0);
      expect(payment.amount, isA<double>());
      expect(payment.method, 'VISA');
      expect(payment.status, 'PAID');
      expect(payment.transactionId, 'txn_123');
      expect(payment.isDeposit, isTrue);
      expect(payment.paidAt, DateTime.parse('2026-11-01T11:05:00.000'));
      expect(payment.reportedAt, DateTime.parse('2026-11-02T09:00:00.000'));
    });

    test('applies defaults for a sparse payload', () {
      final payment = Payment.fromJson(const {});
      expect(payment.id, '');
      expect(payment.appointmentId, '');
      expect(payment.amount, 0.0);
      expect(payment.method, 'CASH'); // default
      expect(payment.status, 'PENDING'); // default
      expect(payment.transactionId, isNull);
      expect(payment.isDeposit, isFalse);
      expect(payment.paidAt, isNull);
      expect(payment.reportedAt, isNull);
    });
  });

  group('SoonestAppointment', () {
    Map<String, dynamic> apiPayload() {
      return {
        'id': 17,
        'start_time': '2026-11-05T14:00:00.000',
        'total_amount': 200,
        'salon_name': 'Glow Salon',
        'salon_phone': '+966511111111',
        'salon_id': 3,
        'customer_name': 'Mona Ali',
        'services': ['Haircut', 'Manicure'],
        'expert_name': 'Khalid Omar',
        'status': 'SCHEDULED',
        'salon_address': 'King Fahd Rd',
        'customer': 7,
        'expert': 11,
      };
    }

    test('fromAppointment parses a realistic API payload', () {
      final soonest = SoonestAppointment.fromAppointment(apiPayload());

      expect(soonest.id, '17'); // numeric id stringified
      expect(soonest.dateTime, DateTime.parse('2026-11-05T14:00:00.000'));
      expect(soonest.totalPrice, 200.0);
      expect(soonest.salonName, 'Glow Salon');
      expect(soonest.salonPhoneNumber, '+966511111111');
      expect(soonest.salonId, '3');
      expect(soonest.customerName, 'Mona Ali');
      expect(soonest.services, ['Haircut', 'Manicure']);
      expect(soonest.expertName, 'Khalid Omar');
      expect(soonest.status, 'SCHEDULED');
      expect(soonest.salonAddress, 'King Fahd Rd');
      expect(soonest.customerId, 7);
      expect(soonest.expertId, 11);
    });

    test('salonId falls back from salon_id to salon key', () {
      final payload = apiPayload()
        ..remove('salon_id')
        ..['salon'] = 8;
      expect(SoonestAppointment.fromAppointment(payload).salonId, '8');

      final neither = apiPayload()
        ..remove('salon_id')
        ..remove('salon');
      expect(SoonestAppointment.fromAppointment(neither).salonId, '');
    });

    test('applies defaults for missing optional fields', () {
      final soonest = SoonestAppointment.fromAppointment({
        'start_time': '2026-11-05T14:00:00.000',
      });
      expect(soonest.id, '');
      expect(soonest.totalPrice, 0.0);
      expect(soonest.salonName, '');
      expect(soonest.salonPhoneNumber, '');
      expect(soonest.customerName, '');
      expect(soonest.services, isEmpty);
      expect(soonest.expertName, isNull);
      expect(soonest.status, isNull);
      expect(soonest.salonAddress, isNull);
      expect(soonest.customerId, isNull);
      expect(soonest.expertId, isNull);
    });

    test('toJson round-trips through fromAppointment', () {
      final original = SoonestAppointment.fromAppointment(apiPayload());
      final reparsed = SoonestAppointment.fromAppointment(original.toJson());

      // Note: toJson writes 'salon' (not 'salon_id') — the salon_id -> salon
      // fallback in fromAppointment is what keeps this round trip working.
      expect(reparsed.id, original.id);
      expect(reparsed.dateTime, original.dateTime);
      expect(reparsed.totalPrice, original.totalPrice);
      expect(reparsed.salonName, original.salonName);
      expect(reparsed.salonPhoneNumber, original.salonPhoneNumber);
      expect(reparsed.salonId, original.salonId);
      expect(reparsed.customerName, original.customerName);
      expect(reparsed.services, original.services);
      expect(reparsed.expertName, original.expertName);
      expect(reparsed.status, original.status);
      expect(reparsed.salonAddress, original.salonAddress);
      expect(reparsed.customerId, original.customerId);
      expect(reparsed.expertId, original.expertId);
    });

    test('copyWith overrides only the given fields', () {
      final original = SoonestAppointment.fromAppointment(apiPayload());
      final copied = original.copyWith(
        salonName: 'New Name',
        status: 'COMPLETED',
      );

      expect(copied.salonName, 'New Name');
      expect(copied.status, 'COMPLETED');
      expect(copied.id, original.id);
      expect(copied.dateTime, original.dateTime);
      expect(copied.services, original.services);
      // Quirk: salonId/customerName/customerId/expertId have no copyWith
      // parameters and are always carried over unchanged.
      expect(copied.salonId, original.salonId);
      expect(copied.customerId, original.customerId);
    });
  });

  group('SoonestAppointmentData', () {
    SoonestAppointment at(String id, DateTime dateTime) {
      return SoonestAppointment(
        id: id,
        dateTime: dateTime,
        totalPrice: 0,
        salonName: 'Salon',
        salonPhoneNumber: '',
        salonId: '1',
        customerName: 'Customer',
        services: const [],
      );
    }

    test('getSoonestAppointment returns null for an empty list', () {
      expect(SoonestAppointmentData.getSoonestAppointment(const []), isNull);
    });

    test('getSoonestAppointment returns null when all are in the past', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(
        SoonestAppointmentData.getSoonestAppointment([at('a', past)]),
        isNull,
      );
    });

    test('getSoonestAppointment picks the nearest future appointment', () {
      final now = DateTime.now();
      final nearest = at('near', now.add(const Duration(hours: 2)));
      final later = at('later', now.add(const Duration(days: 3)));
      final past = at('past', now.subtract(const Duration(days: 1)));

      final result = SoonestAppointmentData.getSoonestAppointment([
        later,
        past,
        nearest,
      ]);
      expect(result?.id, 'near');
    });

    test(
      'fromAppointmentJson returns null instead of throwing on bad data',
      () {
        // Quirk: parsing errors are swallowed and surfaced as null.
        expect(SoonestAppointmentData.fromAppointmentJson(const {}), isNull);
        expect(
          SoonestAppointmentData.fromAppointmentJson(const {'start_time': 5}),
          isNull,
        );

        final good = SoonestAppointmentData.fromAppointmentJson({
          'start_time': '2026-11-05T14:00:00.000',
        });
        expect(good, isNotNull);
      },
    );
  });

  group('BookingGroup', () {
    Map<String, dynamic> groupPayload() {
      return {
        'id': 5,
        'organizer': 7,
        'organizer_name': 'Mona Ali',
        'created_at': '2026-10-15T12:00:00.000',
        'is_recurring': true,
        'salon': 3,
        'appointments': [
          {
            'id': 'a1',
            'start_time': '2099-01-01T10:00:00.000',
            'end_time': '2099-01-01T11:00:00.000',
            'status': 'SCHEDULED',
            'amount': 100,
            'expert_name': 'Khalid',
            'expert': 11,
            'services': ['Haircut'],
          },
          {
            'id': 'a2',
            'start_time': '2000-01-01T10:00:00.000',
            'end_time': '2000-01-01T11:00:00.000',
            'status': 'COMPLETED',
            'amount': 80.5,
            'services': ['Manicure'],
          },
        ],
      };
    }

    test('fromJson parses a full group payload', () {
      final group = BookingGroup.fromJson(groupPayload());

      expect(group.id, '5'); // numeric id stringified
      expect(group.organizerId, 7);
      expect(group.organizerName, 'Mona Ali');
      expect(group.createdAt, DateTime.parse('2026-10-15T12:00:00.000'));
      expect(group.isRecurring, isTrue);
      expect(group.salonId, 3);
      expect(group.appointments, hasLength(2));

      final first = group.appointments.first;
      expect(first.id, 'a1');
      expect(first.status, 'SCHEDULED');
      expect(first.amount, 100.0); // int coerced to double
      expect(first.expertName, 'Khalid');
      expect(first.expertId, 11);
      expect(first.services, ['Haircut']);
    });

    test('defaults missing organizer_name, is_recurring and appointments', () {
      final group = BookingGroup.fromJson({
        'id': 'g1',
        'organizer': 7,
        'created_at': '2026-10-15T12:00:00.000',
      });
      expect(group.organizerName, '');
      expect(group.isRecurring, isFalse);
      expect(group.appointments, isEmpty);
      expect(group.salonId, isNull);
    });

    test('throws when organizer id is missing', () {
      // `json['organizer'] as int` with a missing key -> TypeError.
      expect(
        () => BookingGroup.fromJson({
          'id': 'g1',
          'created_at': '2026-10-15T12:00:00.000',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('toJson round-trips through fromJson', () {
      final original = BookingGroup.fromJson(groupPayload());
      final reparsed = BookingGroup.fromJson(original.toJson());

      expect(reparsed.id, original.id);
      expect(reparsed.organizerId, original.organizerId);
      expect(reparsed.organizerName, original.organizerName);
      expect(reparsed.createdAt, original.createdAt);
      expect(reparsed.isRecurring, original.isRecurring);
      expect(reparsed.salonId, original.salonId);
      expect(reparsed.appointments, hasLength(2));
      expect(reparsed.appointments[1].id, 'a2');
      expect(reparsed.appointments[1].amount, 80.5);
      expect(reparsed.appointments[1].expertName, isNull);
    });

    test(
      'derived getters: totalAppointments, totalAmount, nextAppointment',
      () {
        final group = BookingGroup.fromJson(groupPayload());

        expect(group.totalAppointments, 2);
        expect(group.totalAmount, 180.5);
        // Only the 2099 appointment is in the future.
        expect(
          group.nextAppointment,
          DateTime.parse('2099-01-01T10:00:00.000'),
        );
      },
    );

    test('nextAppointment is null when nothing is upcoming', () {
      final payload = groupPayload();
      (payload['appointments'] as List).removeAt(0);
      final group = BookingGroup.fromJson(payload);
      expect(group.nextAppointment, isNull);
    });
  });

  group('AppointmentReference', () {
    test('status helper getters compare exact uppercase strings', () {
      AppointmentReference ref(String status) => AppointmentReference(
        id: 'a1',
        startTime: DateTime.parse('2026-11-01T10:00:00.000'),
        endTime: DateTime.parse('2026-11-01T11:00:00.000'),
        status: status,
        amount: 0,
        services: const [],
      );

      expect(ref('COMPLETED').isCompleted, isTrue);
      expect(ref('completed').isCompleted, isFalse); // case-sensitive
      expect(ref('CANCELLED').isCancelled, isTrue);
      expect(ref('SCHEDULED').isCompleted, isFalse);
      expect(ref('SCHEDULED').isCancelled, isFalse);
    });

    test('isUpcoming compares start time to now', () {
      AppointmentReference at(DateTime start) => AppointmentReference(
        id: 'a1',
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        status: 'SCHEDULED',
        amount: 0,
        services: const [],
      );

      expect(
        at(DateTime.now().add(const Duration(days: 1))).isUpcoming,
        isTrue,
      );
      expect(
        at(DateTime.now().subtract(const Duration(days: 1))).isUpcoming,
        isFalse,
      );
    });
  });
}
