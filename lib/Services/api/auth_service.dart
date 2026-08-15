import '../../Helpers/registration_helper.dart';
import '../../Models/auth/user_model.dart';
import '../repositories/auth_repository.dart';
import '../analytics_service.dart';
import '../../Helpers/logger.dart';
import '../storage_service.dart';

class AuthService {
  final AuthRepository _authRepository;
  final UnifiedStorageService _secureStorage = UnifiedStorageService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final SocialRegistrationHelper _socialHelper = SocialRegistrationHelper();

  AuthService(this._authRepository);

  // Email/Password Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      AppLogger.debug('Login attempt for: $email');

      final response = await _authRepository.login(email, password);

      if (response['access'] != null) {
        await _saveAuthData(response);

        // Analytics event
        if (response['user'] != null && response['user']['id'] != null) {
          await _analyticsService.logLogin(
            method: 'email',
            userId: response['user']['id'],
          );
        }
      }

      return response;
    } catch (e) {
      AppLogger.error('Login error: $e');
      rethrow;
    }
  }

  // Email/Password Signup
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
    required String role,
  }) async {
    try {
      AppLogger.debug('Signup attempt for: $email');

      final userData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'username': email.split('@')[0],
        'phone': phoneNumber,
        'gender': gender.toUpperCase(),
        'password': password,
        'role': role.toUpperCase(),
      };

      final response = await _authRepository.register(userData);

      if (response['access'] != null) {
        await _saveAuthData(response);

        if (response['user'] != null && response['user']['id'] != null) {
          await _analyticsService.logSignUp(
            method: 'email',
            userId: response['user']['id'],
          );
        }
      }

      return response;
    } catch (e) {
      AppLogger.error('Signup error: $e');
      rethrow;
    }
  }

  // Social Registration
  Future<Map<String, dynamic>> socialSignup({
    required String provider,
    required Map<String, dynamic> socialData,
    String? selectedRole,
    String? selectedGender,
  }) async {
    try {
      AppLogger.debug('Social signup attempt for: $provider');

      // Process social data through helper
      final userData = await _socialHelper.processSocialRegistration(
        provider: provider,
        socialData: socialData,
        selectedRole: selectedRole,
        selectedGender: selectedGender,
      );

      // Register user with processed data
      final response = await _authRepository.register(userData);

      if (response['access'] != null) {
        await _saveAuthData(response);

        if (response['user'] != null && response['user']['id'] != null) {
          await _analyticsService.logSignUp(
            method: provider,
            userId: response['user']['id'],
          );
        }

        AppLogger.info(
          'Social registration successful for ${userData['email']}',
        );
      }

      return response;
    } catch (e) {
      AppLogger.error('Social signup error: $e');
      rethrow;
    }
  }

  // Social Login (for existing social users)
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String socialId,
    required String email,
  }) async {
    try {
      AppLogger.debug('Social login attempt for: $provider - $email');

      final response = await _authRepository.socialLogin(
        provider: provider,
        socialId: socialId,
        email: email,
      );

      if (response['access'] != null) {
        await _saveAuthData(response);

        if (response['user'] != null && response['user']['id'] != null) {
          await _analyticsService.logLogin(
            method: provider,
            userId: response['user']['id'],
          );
        }
      }

      return response;
    } catch (e) {
      AppLogger.error('Social login error: $e');
      rethrow;
    }
  }

  // Check if social user exists
  Future<bool> checkSocialUserExists({
    required String provider,
    required String socialId,
    required String email,
  }) async {
    try {
      AppLogger.debug('Checking social user existence: $provider - $email');

      final response = await _authRepository.checkSocialUserExists(
        provider: provider,
        socialId: socialId,
        email: email,
      );

      return response['exists'] == true;
    } catch (e) {
      AppLogger.error('Check social user exists error: $e');
      return false;
    }
  }

  // Unified social authentication - automatically handles login or signup
  Future<Map<String, dynamic>> handleSocialAuthentication({
    required String provider,
    required Map<String, dynamic> socialData,
    String? selectedRole,
    String? selectedGender,
  }) async {
    try {
      AppLogger.debug('Handling social authentication for: $provider');

      // Extract essential data using the helper's process method
      final processedData = await _socialHelper.processSocialRegistration(
        provider: provider,
        socialData: socialData,
        selectedRole: selectedRole,
        selectedGender: selectedGender,
      );

      final email = processedData['email'];
      final socialId = processedData['social_id'];

      // Check if user already exists
      final userExists = await checkSocialUserExists(
        provider: provider,
        socialId: socialId,
        email: email,
      );

      if (userExists) {
        // User exists - perform social login
        AppLogger.debug('Existing social user found, performing login');
        return await socialLogin(
          provider: provider,
          socialId: socialId,
          email: email,
        );
      } else {
        // New user - perform social registration
        AppLogger.debug('New social user, performing registration');
        return await socialSignup(
          provider: provider,
          socialData: socialData,
          selectedRole: selectedRole,
          selectedGender: selectedGender,
        );
      }
    } catch (e) {
      AppLogger.error('Social authentication error: $e');
      rethrow;
    }
  }

  // Other existing methods...
  Future<User> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    return await _authRepository.updateProfile(profileData);
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    await _authRepository.updateProfile({'is_online': isOnline});
  }

  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      await _authRepository.logout(refreshToken: refreshToken);
    } catch (e) {
      AppLogger.error('Logout API error: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // Password reset methods
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      AppLogger.debug('Forgot password request for: $email');
      return await _authRepository.forgotPassword(email);
    } catch (e) {
      AppLogger.error('Forgot password error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      AppLogger.debug('Resetting password');
      return await _authRepository.resetPassword(
        token: token,
        newPassword: newPassword,
      );
    } catch (e) {
      AppLogger.error('Reset password error: $e');
      rethrow;
    }
  }

  // Token management
  Future<String?> getAuthToken() async {
    return await _secureStorage.getAuthToken();
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Private methods
  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    // DRF backend returns: { user: {...}, access: "...", refresh: "..." }
    // Legacy/mock paths may return: { user: {...}, token: "...", refresh_token: "..." }
    final token = response['access'] ?? response['token'];
    final refreshToken = response['refresh'] ?? response['refresh_token'];
    final user = response['user'];

    if (token != null) {
      await _secureStorage.setAuthTokens(token, refreshToken ?? '');
    }
    if (user != null) {
      await _secureStorage.saveUserData(user);
    }
  }

  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      AppLogger.debug('Verify password reset OTP for: $email');
      return await _authRepository.verifyPasswordResetOtp(
        email: email,
        otp: otp,
      );
    } catch (e) {
      AppLogger.error('Verify password reset OTP error: $e');
      rethrow;
    }
  }

  // Optional: For email verification
  Future<Map<String, dynamic>> sendEmailVerificationOtp(String email) async {
    try {
      AppLogger.debug('Send email verification OTP for: $email');
      return await _authRepository.sendVerificationOtp(email);
    } catch (e) {
      AppLogger.error('Send email verification OTP error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      AppLogger.debug('Verify email OTP for: $email');
      return await _authRepository.verifyEmailOtp(email: email, otp: otp);
    } catch (e) {
      AppLogger.error('Verify email OTP error: $e');
      rethrow;
    }
  }

  Future<void> _clearAuthData() async {
    await _secureStorage.clearAuthData();
  }

  Future<Map<String, dynamic>> adminCreateStaff(
    Map<String, dynamic> staffData,
  ) async {
    return await _authRepository.adminCreateStaff(staffData);
  }

  Future<Map<String, dynamic>> adminOnboardSalon(
    Map<String, dynamic> payload,
  ) async {
    return await _authRepository.adminOnboardSalon(payload);
  }

  Future<List<dynamic>> adminFetchSalons() async {
    return await _authRepository.adminFetchSalons();
  }

  // Utility method to get social helper (if needed externally)
  SocialRegistrationHelper get socialHelper => _socialHelper;
}
