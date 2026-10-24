// import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/appointments/salon_appointments_model.dart';
import '../../Services/enums/appointment_status.dart';
import '../../Services/api/api_service.dart';
import 'package:na3eeman/Helpers/logger.dart';

class AppointmentProvider extends BaseProvider {
  AppointmentProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final List<SalonAppointment> _appointments = [];
  AuthProvider? _authProvider;
  Map<String, dynamic>? _soonestAppointment;
  User? _user;

  User? get user => _user;
  // Getters
  List<SalonAppointment> get appointments => _appointments;
  Map<String, dynamic>? get soonestAppointment => _soonestAppointment;

  bool get hasError => error != null;

  List<dynamic> get myAppointments {
    if (_authProvider?.isExpert == true) {
      return _appointments
          .where((appt) => appt.expertId == _authProvider?.user?.id)
          .map((a) => a.toJson())
          .toList();
    } else if (_authProvider?.isCustomer == true) {
      return _appointments
          .where((appt) => appt.customerId == _authProvider?.user?.id)
          .map((a) => a.toJson())
          .toList();
    }
    return _appointments.map((a) => a.toJson()).toList();
  }

  Future<Map<String, dynamic>?> getSoonestAppointment(int customerId) async {
    await loadSoonestAppointment();
    return _soonestAppointment;
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    bool stateChanged = false;

    // Check if auth state changed or different user
    if (_authProvider?.isAuthenticated != authProvider.isAuthenticated) {
      stateChanged = true;
    } else if (_authProvider?.user?.id != authProvider.user?.id) {
      stateChanged = true;
    }

    _authProvider = authProvider;

    if (stateChanged && _authProvider?.isAuthenticated == true) {
      Future.microtask(() {
        loadAppointments();
        loadSoonestAppointment();
      });
    }
  }

  Future<void> loadAppointments({String? query, DateTime? date}) async {
    try {
      setLoading(true);
      clearError();

      // Fetch from API instead of mocks
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.isNotEmpty) {
        queryParams['customer_name'] = query;
      }
      if (date != null) {
        queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(date);
      }
      final response = await _apiService.get(
        '/salons/appointments/',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      ); // Or Endpoints.appointments
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      _appointments.clear();
      for (var item in data) {
        try {
          _appointments.add(SalonAppointment.fromJson(item));
        } catch (e) {
          AppLogger.error('Error parsing appointment item JSON: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadSoonestAppointment() async {
    try {
      if (_authProvider?.user?.id == null) return;

      // Filter local appointments for future ones
      final now = DateTime.now();
      final futureAppointments =
          _appointments
              .where(
                (appt) =>
                    appt.startTime.isAfter(now) &&
                    appt.status == AppointmentStatus.scheduled,
              )
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

      if (futureAppointments.isNotEmpty) {
        final a = futureAppointments.first;
        _soonestAppointment = {
          'id': a.id,
          'customerId': a.customerId,
          'salonId': a.salonId,
          'expertId': a.expertId,
          'dateTime': a.startTime.toIso8601String(),
          'totalPrice': 0.0, // Should be calculated or from API
          'salonName': 'Salon #${a.salonId}',
          'services': a.services,
        };
      } else {
        _soonestAppointment = null;
      }
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading soonest appointment: $e');
    }
  }

  Future<void> delayAppointment(String appointmentId, int minutes) async {
    try {
      setLoading(true);
      await _apiService.post(
        '/salons/appointments/$appointmentId/delay/',
        data: {'minutes': minutes},
      );

      // Update local state
      await loadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> verifyPayment(String appointmentId) async {
    try {
      setLoading(true);
      await _apiService.post(
        '/salons/appointments/$appointmentId/verify-payment/',
        data: {},
      );

      await loadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> confirmPayment(
    String appointmentId, {
    String? voucherCode,
  }) async {
    try {
      setLoading(true);
      clearError();

      await _apiService.confirmPayment(appointmentId, voucherCode: voucherCode);

      await loadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> rateCustomer({
    required String appointmentId,
    required double rating,
    String? reviews,
  }) async {
    try {
      setLoading(true);
      await _apiService.post(
        '/users/customers/rate/',
        data: {
          'appointment': appointmentId,
          'rating': rating,
          'reviews': reviews,
        },
      );

      await loadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    DateTime newEndTime,
  ) async {
    try {
      setLoading(true);
      await _apiService.post(
        '/salons/appointments/$appointmentId/reschedule/',
        data: {
          'start_time': newStartTime.toIso8601String(),
          'end_time': newEndTime.toIso8601String(),
        },
      );

      await loadAppointments();
      await loadSoonestAppointment();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> reportCustomer(String appointmentId, String reason) async {
    try {
      setLoading(true);
      clearError();
      await _apiService.reportCustomer(appointmentId, reason: reason);
      await loadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Create a recurring booking (pure delegate, no state change).
  Future<dynamic> createRecurringBooking(Map<String, dynamic> data) =>
      _apiService.createRecurringBooking(data);

  /// Upload a payment proof for an appointment (pure delegate).
  Future<dynamic> uploadPaymentProof({
    required dynamic appointmentId,
    required File proof,
  }) => _apiService.uploadPaymentProof(
    appointmentId: appointmentId,
    proof: proof,
  );

  Future<Map<String, dynamic>> bookAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      setLoading(true);
      clearError();

      final response = await _apiService.bookAppointment(appointmentData);

      // Reload appointments to sync local state
      await loadAppointments();
      await loadSoonestAppointment();

      return response;
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
