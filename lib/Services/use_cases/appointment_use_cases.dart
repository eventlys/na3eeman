// lib/Services/use_cases/appointment_use_cases.dart
import '../../Helpers/error_handler.dart';
import '../business_service.dart';

class AppointmentUseCases {
  final BusinessService _appointmentService;

  AppointmentUseCases(this._appointmentService);

  Future<List<dynamic>> getAppointments({
    int page = 1,
    int limit = 20,
    String? status,
    int? shopId,
    int? customerId,
  }) async {
    if (page < 1) throw AppError('Page must be greater than 0');
    if (limit < 1 || limit > 100) throw AppError('Limit must be between 1 and 100');

    return await _appointmentService.getAppointments(
      page: page,
      limit: limit,
      status: status,
      shopId: shopId,
      customerId: customerId,
    );
  }

  Future<dynamic> bookAppointment({
    required int customerId,
    required int shopId,
    required int? barberId,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> services,
    required String attendeeType,
    int? requestedStyleId,
    String? recurrence,
    DateTime? recurrenceEndDate,
    bool isGroup = false,
  }) async {
    if (customerId <= 0) throw AppError('Invalid customer ID');
    if (shopId <= 0) throw AppError('Invalid shop ID');
    if (startTime.isBefore(DateTime.now())) {
      throw AppError('Appointment time must be in the future');
    }
    if (endTime.isBefore(startTime)) {
      throw AppError('End time must be after start time');
    }
    if (services.isEmpty) throw AppError('At least one service is required');

    final validAttendeeTypes = ['SELF', 'FAMILY', 'FRIEND'];
    if (!validAttendeeTypes.contains(attendeeType)) {
      throw AppError('Invalid attendee type');
    }

    if (recurrence != null) {
      final validRecurrence = ['WEEKLY', 'BIWEEKLY'];
      if (!validRecurrence.contains(recurrence)) {
        throw AppError('Invalid recurrence type');
      }
      if (recurrenceEndDate == null || recurrenceEndDate.isBefore(startTime)) {
        throw AppError('Recurrence end date must be after start time');
      }
    }

    return await _appointmentService.bookAppointment(
      customerId: customerId,
      shopId: shopId,
      barberId: barberId,
      startTime: startTime,
      endTime: endTime,
      services: services,
      attendeeType: attendeeType,
      requestedStyleId: requestedStyleId,
      recurrence: recurrence,
      recurrenceEndDate: recurrenceEndDate,
      isGroup: isGroup,
    );
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    if (appointmentId.isEmpty) throw AppError('Appointment ID is required');
    if (reason.isEmpty) throw AppError('Cancellation reason is required');
    if (reason.length < 10) throw AppError('Reason must be at least 10 characters');

    await _appointmentService.cancelAppointment(appointmentId, reason);
  }

  Future<dynamic> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    DateTime newEndTime,
  ) async {
    if (appointmentId.isEmpty) throw AppError('Appointment ID is required');
    if (newStartTime.isBefore(DateTime.now())) {
      throw AppError('New appointment time must be in the future');
    }
    if (newEndTime.isBefore(newStartTime)) {
      throw AppError('End time must be after start time');
    }

    return await _appointmentService.rescheduleAppointment(
      appointmentId,
      newStartTime,
      newEndTime,
    );
  }

  Future<void> confirmCashPayment(int appointmentId, int confirmedByUserId, double amount) async {
    if (appointmentId <= 0) throw AppError('Invalid appointment ID');
    if (confirmedByUserId <= 0) throw AppError('Invalid user ID');
    if (amount <= 0) throw AppError('Amount must be greater than 0.0');

    await _appointmentService.confirmCashPayment(appointmentId, confirmedByUserId, amount);
  }

  Future<dynamic> createFreeAppointment(int customerId, {int? shopId}) async {
    if (customerId <= 0) throw AppError('Invalid customer ID');
    if (shopId != null && shopId <= 0) throw AppError('Invalid shop ID');

    return await _appointmentService.createFreeAppointment(customerId, shopId: shopId);
  }
}
