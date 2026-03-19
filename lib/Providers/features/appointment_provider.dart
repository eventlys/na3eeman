import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/shop/appointment_model.dart';
import '../../Services/enums/appointment_status.dart';

class AppointmentProvider extends BaseProvider {
  final List<ShopAppointment> _appointments = [];
  AuthProvider? _authProvider;
  Map<String, dynamic>? _soonestAppointment;
  User? _user;

  User? get user => _user;
  // Getters
  List<ShopAppointment> get appointments => _appointments;
  Map<String, dynamic>? get soonestAppointment => _soonestAppointment;

  bool get hasError => error != null;

  List<ShopAppointment> get myAppointments {
    if (_authProvider?.isBarber == true) {
      return _appointments
          .where((appt) => appt.barberId == _authProvider?.user?.id)
          .toList();
    } else if (_authProvider?.isCustomer == true) {
      return _appointments
          .where((appt) => appt.customerId == _authProvider?.user?.id)
          .toList();
    }
    return _appointments;
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

      await _mockLoadAppointments();
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

      // Simulate network delay to yield execution
      await Future.delayed(const Duration(milliseconds: 100));

      // Convert mock data to map format for the widget
      final mockAppointment = _mockSoonestAppointment();
      _soonestAppointment = mockAppointment;
      notifyListeners();
    } catch (e) {
      print('Error loading soonest appointment: $e');
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
        final updatedAppointment = ShopAppointment(
          id: _appointments[appointmentIndex].id,
          customerId: _appointments[appointmentIndex].customerId,
          shopId: _appointments[appointmentIndex].shopId,
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
      'shopId': 1,
      'barberId': 1,
      'dateTime': DateTime.now()
          .add(const Duration(hours: 2))
          .toIso8601String(),
      'totalPrice': 45.00,
      'shopName': 'Premium Barber Shop',
      'shopPhoneNumber': '+1234567890',
      'services': ['Haircut', 'Beard Trim', 'Shave'],
    };
  }

  void _loadCustomerAppointments() {
    _appointments.addAll([
      ShopAppointment(
        id: '2',
        customerId: _authProvider?.user?.id ?? 1,
        shopId: 1,
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
      ShopAppointment(
        id: '1',
        customerId: 1,
        shopId: 1,
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
      ShopAppointment(
        id: '1',
        customerId: 1,
        shopId: 1,
        barberId: 2,
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  Future<void> createAppointment(ShopAppointment appointment) async {
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
