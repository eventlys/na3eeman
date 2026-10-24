import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Helpers/error_handler.dart';
import 'package:na3eeman/Services/business_service.dart';
import 'package:na3eeman/Services/use_cases/appointment_use_cases.dart';

// Characterization tests for AppointmentUseCases.
//
// Seam note: AppointmentUseCases takes a BusinessService via its constructor,
// but BusinessService is a singleton (`factory BusinessService() => _instance`)
// whose methods call the real ApiService over package:http, so it cannot be
// mocked without modifying production code. These tests therefore cover only
// the validation layer, which throws AppError BEFORE any network call. Paths
// that pass validation (and would hit the network/config) are intentionally
// not exercised.
void main() {
  late AppointmentUseCases useCases;

  setUp(() {
    useCases = AppointmentUseCases(BusinessService());
  });

  final futureStart = DateTime.now().add(const Duration(days: 1));
  final futureEnd = DateTime.now().add(const Duration(days: 1, hours: 1));

  Map<String, dynamic> validBooking({
    int customerId = 1,
    int salonId = 1,
    DateTime? startTime,
    DateTime? endTime,
    List<Map<String, dynamic>>? services,
    String attendeeType = 'SELF',
    String? recurrence,
    DateTime? recurrenceEndDate,
  }) {
    return {
      'customerId': customerId,
      'salonId': salonId,
      'startTime': startTime ?? futureStart,
      'endTime': endTime ?? futureEnd,
      'services':
          services ??
          [
            {'option': 10, 'quantity': 1},
          ],
      'attendeeType': attendeeType,
      'recurrence': recurrence,
      'recurrenceEndDate': recurrenceEndDate,
    };
  }

  Future<dynamic> callBook(Map<String, dynamic> args) {
    return useCases.bookAppointment(
      customerId: args['customerId'] as int,
      salonId: args['salonId'] as int,
      expertId: null,
      startTime: args['startTime'] as DateTime,
      endTime: args['endTime'] as DateTime,
      services: args['services'] as List<Map<String, dynamic>>,
      attendeeType: args['attendeeType'] as String,
      recurrence: args['recurrence'] as String?,
      recurrenceEndDate: args['recurrenceEndDate'] as DateTime?,
    );
  }

  Matcher hasMessage(String message) =>
      isA<AppError>().having((e) => e.message, 'message', message);

  group('AppointmentUseCases.getAppointments', () {
    test('rejects page below 1', () {
      expect(
        useCases.getAppointments(page: 0),
        throwsA(hasMessage('Page must be greater than 0')),
      );
      expect(
        useCases.getAppointments(page: -3),
        throwsA(hasMessage('Page must be greater than 0')),
      );
    });

    test('rejects limit below 1', () {
      expect(
        useCases.getAppointments(limit: 0),
        throwsA(hasMessage('Limit must be between 1 and 100')),
      );
    });

    test('rejects limit above 100', () {
      expect(
        useCases.getAppointments(limit: 101),
        throwsA(hasMessage('Limit must be between 1 and 100')),
      );
    });

    test('page validation runs before limit validation', () {
      // Both invalid: the page error wins because it is checked first.
      expect(
        useCases.getAppointments(page: 0, limit: 0),
        throwsA(hasMessage('Page must be greater than 0')),
      );
    });

    // Boundary values page=1 / limit=1 / limit=100 pass validation and reach
    // BusinessService -> ApiService (network + Environment config), which is
    // untestable here; see file header.
  });

  group('AppointmentUseCases.bookAppointment', () {
    test('rejects non-positive customer ID', () {
      expect(
        callBook(validBooking(customerId: 0)),
        throwsA(hasMessage('Invalid customer ID')),
      );
      expect(
        callBook(validBooking(customerId: -1)),
        throwsA(hasMessage('Invalid customer ID')),
      );
    });

    test('rejects non-positive salon ID', () {
      expect(
        callBook(validBooking(salonId: 0)),
        throwsA(hasMessage('Invalid salon ID')),
      );
      expect(
        callBook(validBooking(salonId: -5)),
        throwsA(hasMessage('Invalid salon ID')),
      );
    });

    test('rejects start time in the past', () {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      expect(
        callBook(validBooking(startTime: past, endTime: futureEnd)),
        throwsA(hasMessage('Appointment time must be in the future')),
      );
    });

    test('rejects end time before start time', () {
      final start = DateTime.now().add(const Duration(days: 2));
      final end = DateTime.now().add(const Duration(days: 1));
      expect(
        callBook(validBooking(startTime: start, endTime: end)),
        throwsA(hasMessage('End time must be after start time')),
      );
    });

    test('rejects empty services list', () {
      expect(
        callBook(validBooking(services: const [])),
        throwsA(hasMessage('At least one service is required')),
      );
    });

    test('accepts only SELF, FAMILY and FRIEND attendee types', () {
      expect(
        callBook(validBooking(attendeeType: 'CHILD')),
        throwsA(hasMessage('Invalid attendee type')),
      );
      expect(
        callBook(validBooking(attendeeType: 'self')),
        throwsA(hasMessage('Invalid attendee type')),
      );
      // Current-behavior quirk: the use case accepts 'FAMILY' even though the
      // AttendeeType enum has no FAMILY value, and rejects 'CHILD' even though
      // the enum does have one.
    });

    test('rejects invalid recurrence type', () {
      expect(
        callBook(
          validBooking(recurrence: 'DAILY', recurrenceEndDate: futureEnd),
        ),
        throwsA(hasMessage('Invalid recurrence type')),
      );
    });

    test('rejects recurrence without an end date', () {
      expect(
        callBook(validBooking(recurrence: 'WEEKLY')),
        throwsA(hasMessage('Recurrence end date must be after start time')),
      );
    });

    test('rejects recurrence end date before start time', () {
      expect(
        callBook(
          validBooking(
            recurrence: 'BIWEEKLY',
            recurrenceEndDate: DateTime.now().subtract(
              const Duration(days: 30),
            ),
          ),
        ),
        throwsA(hasMessage('Recurrence end date must be after start time')),
      );
    });

    test('customer ID validation runs before salon ID validation', () {
      expect(
        callBook(validBooking(customerId: 0, salonId: 0)),
        throwsA(hasMessage('Invalid customer ID')),
      );
    });
  });

  group('AppointmentUseCases.cancelAppointment', () {
    test('rejects empty appointment ID', () {
      expect(
        useCases.cancelAppointment('', 'some long enough reason'),
        throwsA(hasMessage('Appointment ID is required')),
      );
    });

    test('rejects empty reason', () {
      expect(
        useCases.cancelAppointment('appt_1', ''),
        throwsA(hasMessage('Cancellation reason is required')),
      );
    });

    test('rejects reason shorter than 10 characters', () {
      expect(
        useCases.cancelAppointment('appt_1', 'too short'),
        throwsA(hasMessage('Reason must be at least 10 characters')),
      );
    });

    test('accepts reason of exactly 10 characters (reaches network seam)', () {
      // '1234567890' is 10 chars: passes validation, then fails inside
      // BusinessService/ApiService (no Environment initialized, no network) —
      // the failure is NOT an AppError validation error.
      expect(
        useCases.cancelAppointment('appt_1', '1234567890'),
        throwsA(isNot(isA<AppError>())),
      );
    });
  });

  group('AppointmentUseCases.rescheduleAppointment', () {
    test('rejects empty appointment ID', () {
      expect(
        useCases.rescheduleAppointment('', futureStart, futureEnd),
        throwsA(hasMessage('Appointment ID is required')),
      );
    });

    test('rejects new start time in the past', () {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      expect(
        useCases.rescheduleAppointment('appt_1', past, futureEnd),
        throwsA(hasMessage('New appointment time must be in the future')),
      );
    });

    test('rejects new end time before new start time', () {
      final start = DateTime.now().add(const Duration(days: 3));
      final end = DateTime.now().add(const Duration(days: 2));
      expect(
        useCases.rescheduleAppointment('appt_1', start, end),
        throwsA(hasMessage('End time must be after start time')),
      );
    });
  });

  group('AppointmentUseCases.confirmCashPayment', () {
    test('rejects non-positive appointment ID', () {
      expect(
        useCases.confirmCashPayment(0, 1, 50.0),
        throwsA(hasMessage('Invalid appointment ID')),
      );
    });

    test('rejects non-positive confirming user ID', () {
      expect(
        useCases.confirmCashPayment(1, -2, 50.0),
        throwsA(hasMessage('Invalid user ID')),
      );
    });

    test('rejects non-positive amount', () {
      expect(
        useCases.confirmCashPayment(1, 1, 0.0),
        throwsA(hasMessage('Amount must be greater than 0.0')),
      );
      expect(
        useCases.confirmCashPayment(1, 1, -10.0),
        throwsA(hasMessage('Amount must be greater than 0.0')),
      );
    });
  });

  group('AppointmentUseCases.createFreeAppointment', () {
    test('rejects non-positive customer ID', () {
      expect(
        useCases.createFreeAppointment(0),
        throwsA(hasMessage('Invalid customer ID')),
      );
    });

    test('rejects non-positive salon ID when provided', () {
      expect(
        useCases.createFreeAppointment(1, salonId: -1),
        throwsA(hasMessage('Invalid salon ID')),
      );
    });

    // A null salonId is explicitly allowed by the validation
    // (`if (salonId != null && salonId <= 0)`); the happy path reaches the
    // network seam and is not exercised here.
  });
}
