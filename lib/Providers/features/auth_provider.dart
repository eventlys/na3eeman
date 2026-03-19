// import 'package:flutter/material.dart';
import '../base_provider.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/auth/barber_profile.dart';
import '../../Models/auth/owner_profile.dart';
import '../../Services/api/api_service.dart';
import '../../Services/api/auth_service.dart';
import '../../Services/repositories/auth_repository.dart';
import '../../Services/enums/gender.dart';
import '../../core/enums/app_enums.dart';
import '../../core/auth/role_permission_manager.dart';

class AuthProvider extends BaseProvider {
  User? _user;
  BarberProfile? _barberProfile;
  OwnerProfile? _ownerProfile;
  bool _isAuthenticated = false;
  // Cached in-memory token so widgets can read it synchronously.
  String? _currentToken;
  final AuthService _authService;

  // Initialize AuthService with required dependencies
  AuthProvider({AuthRepository? authRepository})
    : _authService = AuthService(
        authRepository ?? AuthRepository(ApiService()),
      );

  // Getters
  User? get user => _user;
  BarberProfile? get barberProfile => _barberProfile;
  OwnerProfile? get ownerProfile => _ownerProfile;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userType => _user?.role;
  Gender? get userGender => _user?.gender;
  /// The currently active JWT access token. Null if not logged in.
  String? get currentToken => _currentToken;

  // Role-based convenience getters
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isEmployee => _user?.isEmployee ?? false;
  bool get isBarber => _user?.isBarber ?? false;
  bool get isOwner => _user?.isOwner ?? false;
  bool get isReceptionist => _user?.isReceptionist ?? false;
  bool get isIntern => _user?.isIntern ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  // Profile completion status
  bool get hasBarberProfile => _barberProfile != null;
  bool get hasOwnerProfile => _ownerProfile != null;

  // Combined role checks
  bool get canManageShop => RolePermissionManager.canAccessShopManagement(_user?.role ?? UserRole.customer);
  bool get canManageAppointments => RolePermissionManager.canManageAppointments(_user?.role ?? UserRole.customer);
  bool get canManageInventory => RolePermissionManager.canManageInventory(_user?.role ?? UserRole.customer);
  bool get canManageFinancials => RolePermissionManager.canManageFinancials(_user?.role ?? UserRole.customer);

  void _setCustomerUser() {
    _user = User(
      id: 1,
      email: 'customer@example.com',
      username: 'john_doe',
      firstName: 'John',
      lastName: 'Doe',
      role: UserRole.customer,
      gender: Gender.male,
      location: 'Amman, Jordan',
      lat: 31.963158,
      lng: 35.930359,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _setBarberUser() {
    _user = User(
      id: 2,
      email: 'barber@example.com',
      username: 'mike_barber',
      firstName: 'Mike',
      lastName: 'Johnson',
      role: UserRole.employee,
      gender: Gender.male,
      location: 'Amman, Jordan',
      lat: 31.963158,
      lng: 35.930359,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _barberProfile = BarberProfile(
      id: 1,
      barberId: 2,
      bio: 'Professional barber with 5 years experience',
      specialties: 'Haircuts, Beard Trims, Shaves',
      contactPhone: '+962791234567',
      hasAccess: true,
      avgRating: 4.5,
    );
  }

  void _setOwnerUser() {
    _user = User(
      id: 3,
      email: 'owner@example.com',
      username: 'sarah_owner',
      firstName: 'Sarah',
      lastName: 'Wilson',
      role: UserRole.owner,
      gender: Gender.female,
      location: 'Amman, Jordan',
      lat: 31.963158,
      lng: 35.930359,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _barberProfile = BarberProfile(
      id: 2,
      barberId: 3,
      bio: 'Shop owner and master barber',
      specialties: 'All Services',
      contactPhone: '+962791234568',
      hasAccess: true,
      avgRating: 4.8,
    );

    _ownerProfile = OwnerProfile(
      id: 1,
      barberProfileId: 2,
      isOwner: true,
      isWorker: true,
      isSubscribed: true,
      hasBranches: true,
      hasOffers: true,
      avgRating: 4.8,
      subscriptionTier: 'PREMIUM',
      subscriptionStartDate: DateTime.now().subtract(const Duration(days: 30)),
      subscriptionEndDate: DateTime.now().add(const Duration(days: 335)),
    );
  }

  // Enhanced login method combining both
  Future<bool> login({
    String? email,
    String? password,
    String? socialProvider,
    Map<String, dynamic>? socialData,
  }) async {
    try {
      setLoading(true);
      clearError();

      if (socialProvider != null && socialData != null) {
        // Handle social login
        return await _handleSocialLogin(socialProvider, socialData);
      } else if (email != null && password != null) {
        // Handle email/password login
        return await _handleEmailLogin(email, password);
      } else {
        throw Exception('Invalid login parameters');
      }
    } catch (e) {
      setError('Login failed: $e');
      setLoading(false);
      AppLogger.error('Login failed', error: e);
      return false;
    }
  }

  Future<bool> _handleEmailLogin(String email, String password) async {
    try {
      final response = await _authService.login(email, password);

      if (response['access'] != null) {
        await _updateUserFromResponse(response);
        _isAuthenticated = true;

        final accessToken = response['access'];
        final refreshToken = response['refresh'];

        if (_user != null) {
          await secureStorage.saveUserData(_user!.toJson());
        }
        
        _currentToken = accessToken;
        await secureStorage.setAuthTokens(
          accessToken,
          refreshToken ?? '',
        );

        setLoading(false);
        return true;
      } else {
        throw Exception('Invalid login response: missing access token');
      }
    } catch (e) {
      setError('Login failed: $e');
      setLoading(false);
      AppLogger.error('Login failed', error: e);
      return false;
    }
  }

  Future<bool> _handleSocialLogin(
    String provider,
    Map<String, dynamic> socialData,
  ) async {
    try {
      // Use the unified social authentication
      final response = await _authService.handleSocialAuthentication(
        provider: provider,
        socialData: socialData,
      );

      if (response['access'] != null) {
        await _updateUserFromResponse(response);
        _isAuthenticated = true;

        // Save to local storage
        if (_user != null) {
          await secureStorage.saveUserData(_user!.toJson());
        }
        
        final accessToken = response['access'];
        final refreshToken = response['refresh'];
        
        await secureStorage.setAuthTokens(
          accessToken,
          refreshToken ?? '',
        );

        setLoading(false);
        return true;
      } else {
        throw Exception('Invalid social login response: missing access token');
      }
    } catch (e) {
      setError('Social login failed: $e');
      setLoading(false);
      return false;
    }
  }

  /// Update user data from API response
  Future<void> _updateUserFromResponse(Map<String, dynamic> response) async {
    final userData = response['user'];

    _user = User.fromJson(userData);

    // Update additional profiles based on role
    if (_user?.isBarber == true || _user?.isOwner == true) {
      _barberProfile = BarberProfile.fromJson(userData['barber_profile'] as Map<String, dynamic>? ?? userData);
    }

    if (_user?.isOwner == true) {
      _ownerProfile = OwnerProfile.fromJson(userData['owner_profile'] as Map<String, dynamic>? ?? userData);
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      setLoading(true);
      clearError();

      final result = await _authService.forgotPassword(email);

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('Failed to send OTP: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      setLoading(true);
      clearError();

      final result = await _authService.verifyPasswordResetOtp(
        email: email,
        otp: otp,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('OTP verification failed: $e');
      return {
        'success': false,
        'message': 'OTP verification failed. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      setLoading(true);
      clearError();

      final result = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('Password reset failed: $e');
      return {
        'success': false,
        'message': 'Password reset failed. Please try again.',
      };
    }
  }

  // Enhanced logout combining both
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      AppLogger.error('Logout service error: $e');
    } finally {
      _user = null;
      _barberProfile = null;
      _ownerProfile = null;
      _isAuthenticated = false;

      await secureStorage.clearAuthData();
      clearError();
      notifyListeners();
    }
  }

  /// Check if user exists with social credentials
  Future<bool> checkSocialUserExists(String provider, String socialId) async {
    // Implement API call to check if social user exists
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Mock implementation
  }

  bool hasAccessTo(String feature) {
    final role = _user?.role ?? UserRole.customer;
    switch (feature) {
      case 'shop_management':
        return RolePermissionManager.canAccessShopManagement(role);
      case 'appointment_management':
        return RolePermissionManager.canManageAppointments(role);
      case 'inventory_management':
        return RolePermissionManager.canManageInventory(role);
      case 'financial_management':
        return RolePermissionManager.canManageFinancials(role);
      case 'admin_dashboard':
        return RolePermissionManager.canViewAdminDashboard(role);
      default:
        return false;
    }
  }

  // Additional helper methods
  Future<bool> refreshUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Refresh user data failed: $e');
      return false;
    }
  }

  /// Update user profile locally and optionally sync with backend
  Future<void> updateProfile(User updatedUser) async {
    try {
      _user = updatedUser;

      // Save to local storage
      await secureStorage.saveUserData(updatedUser.toJson());

      notifyListeners();
    } catch (e) {
      print('Error updating profile in provider: $e');
      rethrow;
    }
  }
}
