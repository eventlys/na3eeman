import 'dart:async';
import '../../../Services/api/auth_service.dart' as api;
import '../../../Services/service_locator.dart';
import '../../Models/auth/user_model.dart';
import '../enums/user_type.dart';
// import '../router/app_router.dart';

/// Business-layer Auth service for the Na3eeman ecosystem.
/// Wraps the API-layer AuthService to provide role-based logic and dashboard routing.
class AuthService {
  final api.AuthService _apiAuthService = locator<api.AuthService>();

  /// Core login flow with role-based dashboard routing.
  /// NO mock data used here; consumes real backend responses.
  Future<User?> login(String email, String password) async {
    final response = await _apiAuthService.login(email, password);

    if (response['user'] != null) {
      final user = User.fromJson(response['user']);
      return user;
    }
    return null;
  }

  /// Signup flow for customers.
  Future<User?> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
  }) async {
    final response = await _apiAuthService.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      gender: gender,
      password: password,
      role: 'CUSTOMER', // Default role for public signup
    );

    if (response['user'] != null) {
      return User.fromJson(response['user']);
    }
    return null;
  }

  /// Admin-specific staff creation.
  /// Triggers credential dispatch (OTP) via backend.
  Future<Map<String, dynamic>> adminCreateStaff({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required UserType userType,
    required int salonId,
  }) async {
    final staffData = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'user_type': userType.value,
      'salon_id': salonId,
      'one_time_password': true, // Request OTP generation on backend
    };

    return await _apiAuthService.adminCreateStaff(staffData);
  }

  /// Checks if the user is currently logged in.
  Future<bool> isAuthenticated() async {
    return await _apiAuthService.isLoggedIn();
  }

  /// Fetches the current user profile.
  Future<User?> getProfile() async {
    try {
      final user = await _apiAuthService.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    await _apiAuthService.logout();
  }
}
