import 'dart:convert';

import '../../Helpers/config.dart';
import '../../Helpers/logger.dart';
import '../../Models/appointments/booking_group_model.dart';
import '../../Models/appointments/salon_appointments_model.dart';
import '../../Models/appointments/soonest_appointment_model.dart';
import '../api/api_interceptor_service.dart';
import '../api/api_service.dart';
import '../security_service.dart';

/// Repository for appointment and booking-group backend access.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class AppointmentRepository {
  final ApiService _apiService;
  final ApiInterceptorService _logger;
  final SecurityService _networkSecurity;

  AppointmentRepository({
    ApiService? apiService,
    ApiInterceptorService? logger,
    SecurityService? networkSecurity,
  }) : _apiService = apiService ?? ApiService(),
       _logger = logger ?? ApiInterceptorService(ApiService()),
       _networkSecurity = networkSecurity ?? SecurityService();

  static String get _baseUrl => AppConfig.baseUrl;

  Future<List<SalonAppointment>> getAppointments({
    int page = 1,
    int limit = 20,
    String? status,
    int? salonId,
    int? customerId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (salonId != null) queryParams['salon'] = salonId.toString();
      if (customerId != null) queryParams['customer'] = customerId.toString();

      final response = await _apiService.get(
        '/appointments',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => SalonAppointment.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching appointments: $e');
      rethrow;
    }
  }

  Future<SalonAppointment> createAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      final response = await _apiService.post(
        '/appointments',
        data: appointmentData,
      );
      return SalonAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error creating appointment: $e');
      rethrow;
    }
  }

  Future<SalonAppointment> bookAppointment({
    required int customerId,
    required int salonId,
    required int? expertId,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> services,
    required String attendeeType,
    int? requestedStyleId,
    String? recurrence,
    DateTime? recurrenceEndDate,
    bool isGroup = false,
  }) async {
    try {
      final appointmentData = {
        'customer': customerId,
        'salon': salonId,
        'expert': expertId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'attendee_type': attendeeType,
        'services': services,
        'style': requestedStyleId,
        'recurrence': recurrence,
        'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
        'is_group': isGroup,
      };

      final response = await _apiService.post(
        '/appointments/',
        data: appointmentData,
      );
      return SalonAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _apiService.patch(
        '/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );
    } catch (e) {
      AppLogger.error('Error cancelling appointment: $e');
      rethrow;
    }
  }

  Future<SalonAppointment> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    DateTime newEndTime,
  ) async {
    try {
      final response = await _apiService.patch(
        '/appointments/$appointmentId/reschedule',
        data: {
          'new_start_time': newStartTime.toIso8601String(),
          'new_end_time': newEndTime.toIso8601String(),
        },
      );
      return SalonAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error rescheduling appointment: $e');
      rethrow;
    }
  }

  Future<SoonestAppointment?> getSoonestAppointment(int customerId) async {
    try {
      final response = await _apiService.get(
        '/appointments/soonest',
        queryParams: {'customer': customerId.toString()},
      );

      if (response['data'] != null) {
        return SoonestAppointment.fromAppointment(response['data']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error fetching soonest appointment: $e');
      return null;
    }
  }

  Future<SalonAppointment> createFreeAppointment(
    int customerId, {
    int? salonId,
  }) async {
    try {
      final data = {'customer': customerId};
      if (salonId != null) data['salon'] = salonId;

      final response = await _apiService.post('/appointments/free', data: data);
      return SalonAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error creating free appointment: $e');
      rethrow;
    }
  }

  // ============ BOOKING GROUP SERVICES ============

  Future<List<BookingGroup>> getBookingGroups({
    int page = 1,
    int limit = 20,
    int? organizerId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (organizerId != null) {
        queryParams['organizer'] = organizerId.toString();
      }

      final response = await _apiService.get(
        '/booking-groups',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => BookingGroup.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching booking groups: $e');
      return [];
    }
  }

  Future<BookingGroup> createBookingGroup({
    required int organizerId,
    required bool isRecurring,
    int? salonId,
  }) async {
    try {
      _logger.logRequest('POST', '$_baseUrl/booking-groups/', {
        'organizer': organizerId,
        'is_recurring': isRecurring,
        'salon': salonId,
      });

      final response = await _networkSecurity.securePost(
        '$_baseUrl/booking-groups/',
        headers: await _getAuthHeaders(),
        body: json.encode({
          'organizer': organizerId,
          'is_recurring': isRecurring,
          'salon': salonId,
        }),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      _logger.logResponse(response.statusCode, responseBody);

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        return BookingGroup.fromJson(data);
      } else {
        throw Exception(
          'Failed to create booking group: ${response.statusCode}',
        );
      }
    } catch (error) {
      AppLogger.error('Error creating booking group: $error');
      rethrow;
    }
  }

  // ============ HELPER METHODS ============

  Future<Map<String, String>> _getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _getToken()}',
    };
  }

  Future<String> _getToken() async {
    // Implement token retrieval from your auth service
    return ''; // Replace with actual token retrieval
  }
}
