import 'dart:convert';
// import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_roles.dart';
import '../base_provider.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/auth/expert_profile.dart';
import 'package:na3eeman/Models/auth/owner_profile.dart';
import '../../Services/api/api_service.dart';
import '../../Services/api/auth_service.dart';
import '../../Services/repositories/auth_repository.dart';
import '../../Services/enums/gender.dart';
import '../../core/enums/app_enums.dart';
import '../../core/auth/role_permission_manager.dart';

class AuthProvider extends BaseProvider {
  User? _user;
  ExpertProfile? _expertProfile;
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
  ExpertProfile? get expertProfile => _expertProfile;
  OwnerProfile? get ownerProfile => _ownerProfile;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userType => _user?.userRole;
  Gender? get userGender => _user?.gender;
  /// The currently active JWT access token. Null if not logged in.
  String? get currentToken => _currentToken;

  /// Load auth details from storage on startup.
  Future<void> loadSavedAuth() async {
    try {
      final tokens = await secureStorage.getAuthTokens();
      final accessToken = tokens['authToken'];
      
      if (accessToken != null && accessToken.isNotEmpty) {
        final profile = await secureStorage.getUserProfile();
        if (profile != null) {
          _user = profile;
          _isAuthenticated = true;
          _currentToken = accessToken;
          
          // Rehydrate other profiles based on role if needed
          _rehydrateProfiles();

          // INACTIVITY CHECK: "2 months" (60 days)
          final bool isExpired = await checkInactivity();
          if (isExpired) {
            AppLogger.info('Session expired due to inactivity.');
            return;
          }

          notifyListeners();
          AppLogger.info('Auth restored for user: ${_user?.email}');
        }
      }
    } catch (e) {
      AppLogger.error('Failed to load saved auth data', error: e);
    }
  }

  void _rehydrateProfiles() {
    final userData = secureStorage.getMemoryCache('user_profile_${_user?.id}') ?? 
                     secureStorage.getPreference('user_data');
                     
    if (userData != null) {
      try {
        final Map<String, dynamic> data = userData is String 
            ? Map<String, dynamic>.from(json.decode(userData)) 
            : Map<String, dynamic>.from(userData);
            
        if (_user?.isExpert == true || _user?.isOwner == true) {
          _expertProfile = ExpertProfile.fromJson(data['expert_profile'] ?? data['expert_profile'] ?? data);
        }
        if (_user?.isOwner == true) {
          _ownerProfile = OwnerProfile.fromJson(data['owner_profile'] ?? data);
        }
      } catch (e) {
        AppLogger.error('Rehydrating profiles failed', error: e);
      }
    }
  }

  /// Checks if the user was inactive for too long. Returns true if expired and logged out.
  Future<bool> checkInactivity() async {
    final lastActivityStr = secureStorage.getPreference('last_activity');
    if (lastActivityStr != null) {
      try {
        final lastActivity = DateTime.parse(lastActivityStr as String);
        final difference = DateTime.now().difference(lastActivity);

        // CONFIG: update duration back to 6 days for testing if needed
        // Current: 60 days (2 months)
        if (difference.inDays >= 60) {
          await logout();
          return true;
        }
      } catch (e) {
        AppLogger.error('Error parsing last_activity timestamp: $e');
      }
    }
    await updateLastActivity();
    return false;
  }

  Future<void> updateLastActivity() async {
    await secureStorage.setPreference('last_activity', DateTime.now().toIso8601String());
  }

  // Role-based convenience getters
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isExpert => _user?.isExpert ?? false;
  bool get isOwner => _user?.isOwner ?? false;
  bool get isReceptionist => _user?.isReceptionist ?? false;
  bool get isIntern => _user?.isIntern ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  // Profile completion status
  bool get hasExpertProfile => _expertProfile != null;
  bool get hasOwnerProfile => _ownerProfile != null;

  // Combined role checks
  bool get canManageSalon => RolePermissionManager.canAccessSalonManagement(_user?.userRole ?? UserRole.customer);
  bool get canManageAppointments => RolePermissionManager.canManageAppointments(_user?.userRole ?? UserRole.customer);
  bool get canManageInventory => RolePermissionManager.canManageInventory(_user?.userRole ?? UserRole.customer);
  bool get canManageFinancials => RolePermissionManager.canManageFinancials(_user?.userRole ?? UserRole.customer);

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

        await updateLastActivity(); // Update activity on login

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

        await updateLastActivity(); // Update activity on login

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
    if (_user?.isExpert == true || _user?.isOwner == true) {
      _expertProfile = ExpertProfile.fromJson(userData['expert_profile'] as Map<String, dynamic>? ?? userData['expert_profile'] as Map<String, dynamic>? ?? userData);
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
      _expertProfile = null;
      _ownerProfile = null;
      _isAuthenticated = false;

      await secureStorage.clearAuthData();
      clearError();
      notifyListeners();
    }
  }

  /// Check if user exists with social credentials
  Future<bool> checkSocialUserExists(String provider, String socialId, String email) async {
    return await _authService.checkSocialUserExists(
      provider: provider,
      socialId: socialId,
      email: email,
    );
  }

  bool hasAccessTo(String feature) {
    final role = _user?.userRole ?? UserRole.customer;
    switch (feature) {
      case 'salon_management':
        return RolePermissionManager.canAccessSalonManagement(role);
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

  /// Update user profile locally and sync with backend
  Future<void> updateProfile({
    User? updatedUser,
    String? firstName,
    String? lastName,
    String? phone,
    String? specialization,
    String? bio,
  }) async {
    if (updatedUser != null) {
      _user = updatedUser;
      await secureStorage.saveUserData(updatedUser.toJson());
      notifyListeners();
      return;
    }
    try {
      setLoading(true);
      final Map<String, dynamic> updateData = {};
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (specialization != null) updateData['specialization'] = specialization;
      if (bio != null) updateData['bio'] = bio;

      final updatedUser = await _authService.updateProfile(updateData);
      _user = updatedUser;

      // Save to local storage
      await secureStorage.saveUserData(updatedUser.toJson());

      notifyListeners();
      setLoading(false);
    } catch (e) {
      setLoading(false);
      AppLogger.error('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> toggleOnlineStatus() async {
    if (_user == null || !_user!.isStaffMember) return;
    
    try {
      final newStatus = !_user!.isOnline;
      await _authService.updateOnlineStatus(newStatus);
      _user = _user!.copyWith(isOnline: newStatus);
      await secureStorage.saveUserData(_user!.toJson());
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to toggle online status', error: e);
      rethrow;
    }
  }

  Future<bool> adminCreateStaff(Map<String, dynamic> staffData) async {
    try {
      setLoading(true);
      final response = await _authService.adminCreateStaff(staffData);
      setLoading(false);
      return response != null;
    } catch (e) {
      setLoading(false);
      AppLogger.error('Admin create staff failed', error: e);
      rethrow;
    }
  }

  Future<List<dynamic>> fetchSalons() async {
    try {
      setLoading(true);
      final salons = await _authService.adminFetchSalons();
      setLoading(false);
      return salons;
    } catch (e) {
      setLoading(false);
      AppLogger.error('Fetch salons failed', error: e);
      return [];
    }
  }
}
