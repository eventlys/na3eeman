// import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/appointments/salon_appointments_model.dart';
import '../../Services/enums/appointment_status.dart';
import '../../Services/api/api_service.dart';

class AppointmentProvider extends BaseProvider {
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
    if (_authProvider?.isBarber == true) {
      return _appointments
          .where((appt) => appt.barberId == _authProvider?.user?.id)
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

  Future<void> loadAppointments() async {
    try {
      setLoading(true);
      clearError();

      // Fetch from API instead of mocks
      final apiService = ApiService();
      final response = await apiService.get('/salons/appointments/'); // Or Endpoints.appointments
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];
      
      _appointments.clear();
      for (var item in data) {
        try {
          _appointments.add(SalonAppointment.fromJson(item));
        } catch (e) {
          print('Error parsing appointment item JSON: $e');
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
      final futureAppointments = _appointments
          .where((appt) => 
              appt.startTime.isAfter(now) && 
              appt.status == AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      if (futureAppointments.isNotEmpty) {
        final a = futureAppointments.first;
        _soonestAppointment = {
          'id': a.id,
          'customerId': a.customerId,
          'salonId': a.salonId,
          'barberId': a.barberId,
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
      print('Error loading soonest appointment: $e');
    }
  }

  Future<void> delayAppointment(String appointmentId, int minutes) async {
    try {
      setLoading(true);
      final apiService = ApiService();
      await apiService.post('/salons/appointments/$appointmentId/delay/', data: {'minutes': minutes});
      
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
      final apiService = ApiService();
      await apiService.post('/salons/appointments/$appointmentId/verify-payment/', data: {});
      
      await loadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> confirmPayment(String appointmentId, {String? voucherCode}) async {
    try {
      setLoading(true);
      clearError();
      
      final apiService = ApiService();
      await apiService.confirmPayment(appointmentId, voucherCode: voucherCode);
      
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
      final apiService = ApiService();
      await apiService.post('/users/customers/rate/', data: {
        'appointment': appointmentId,
        'rating': rating,
        'reviews': reviews,
      });
      
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

      // Update the soonest appointment if it matches the ID
      if (_soonestAppointment != null &&
          _soonestAppointment!['id'] == appointmentId) {
        _soonestAppointment = Map<String, dynamic>.from(_soonestAppointment!)
          ..['dateTime'] = newStartTime.toIso8601String();
      }

      // Also update in the appointments list
      final appointmentIndex = _appointments.indexWhere(
        (appt) => appt.id == appointmentId,
      );
      if (appointmentIndex != -1) {
        final updatedAppointment = SalonAppointment(
          id: _appointments[appointmentIndex].id,
          customerId: _appointments[appointmentIndex].customerId,
          salonId: _appointments[appointmentIndex].salonId,
          barberId: _appointments[appointmentIndex].barberId,
          startTime: newStartTime,
          endTime: newEndTime,
          status: _appointments[appointmentIndex].status,
          createdAt: _appointments[appointmentIndex].createdAt,
          services: _appointments[appointmentIndex].services,
        );
        _appointments[appointmentIndex] = updatedAppointment;
      }

      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _mockLoadAppointments() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_authProvider?.isCustomer == true) {
      _loadCustomerAppointments();
    } else if (_authProvider?.isBarber == true) {
      _loadBarberAppointments();
    } else if (_authProvider?.isOwner == true) {
      _loadOwnerAppointments();
    }
  }

  Map<String, dynamic> _mockSoonestAppointment() {
    return {
      'id': '1',
      'customerId': _authProvider?.user?.id ?? 1,
      'salonId': 1,
      'barberId': 1,
      'dateTime': DateTime.now()
          .add(const Duration(hours: 2))
          .toIso8601String(),
      'totalPrice': 45.00,
      'salonName': 'Premium Barber Salon',
      'salonPhoneNumber': '+1234567890',
      'services': ['Haircut', 'Beard Trim', 'Shave'],
    };
  }

  void _loadCustomerAppointments() {
    _appointments.addAll([
      SalonAppointment(
        id: '2',
        customerId: _authProvider?.user?.id ?? 1,
        salonId: 1,
        barberId: 1,
        startTime: DateTime.now().add(const Duration(hours: 4)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  void _loadBarberAppointments() {
    _appointments.addAll([
      SalonAppointment(
        id: '1',
        customerId: 1,
        salonId: 1,
        barberId: _authProvider?.user?.id,
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  void _loadOwnerAppointments() {
    _appointments.addAll([
      SalonAppointment(
        id: '1',
        customerId: 1,
        salonId: 1,
        barberId: 2,
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> appointmentData) async {
    try {
      setLoading(true);
      clearError();
      
      final apiService = ApiService();
      final response = await apiService.bookAppointment(appointmentData);
      
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

  Future<void> createAppointment(SalonAppointment appointment) async {
    try {
      setLoading(true);
      clearError();

      _appointments.add(appointment);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
