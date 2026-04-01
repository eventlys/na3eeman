import '../api/api_service.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      AppLogger.debug('Login attempt for: $email');

      final response = await _apiService.post(
        '/auth/login/',
        data: {'email': email, 'password': password},
      );

      return response;
    } catch (error) {
      AppLogger.error('Login failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      AppLogger.debug('Registration attempt for: ${userData['email']}');

      final response = await _apiService.post('/auth/register/', data: userData);

      return response;
    } catch (error) {
      AppLogger.error('Registration failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  // Social Authentication Methods
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String socialId,
    required String email,
  }) async {
    try {
      AppLogger.debug('Social login attempt for: $provider - $email');

      final response = await _apiService.post(
        '/auth/social/login',
        data: {'provider': provider, 'social_id': socialId, 'email': email},
      );

      return response;
    } catch (error) {
      AppLogger.error('Social login failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> checkSocialUserExists({
    required String provider,
    required String socialId,
    required String email,
  }) async {
    try {
      AppLogger.debug('Checking social user existence: $provider - $email');

      final response = await _apiService.post(
        '/auth/social/check',
        data: {'provider': provider, 'social_id': socialId, 'email': email},
      );

      return response;
    } catch (error) {
      AppLogger.debug('Check social user exists skipped/mocked: returning false');
      return {'exists': false};
    }
  }

  Future<Map<String, dynamic>> linkSocialAccount({
    required String provider,
    required String socialId,
    required String email,
    required String token,
  }) async {
    try {
      AppLogger.debug('Linking social account: $provider - $email');

      final response = await _apiService.post(
        '/auth/social/link',
        data: {'provider': provider, 'social_id': socialId, 'email': email},
        customHeaders: {'Authorization': 'Bearer $token'},
      );

      return response;
    } catch (error) {
      AppLogger.error('Link social account failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> unlinkSocialAccount({
    required String provider,
    required String token,
  }) async {
    try {
      AppLogger.debug('Unlinking social account: $provider');

      final response = await _apiService.post(
        '/auth/social/unlink',
        data: {'provider': provider},
        customHeaders: {'Authorization': 'Bearer $token'},
      );

      return response;
    } catch (error) {
      AppLogger.error('Unlink social account failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> getLinkedSocialAccounts({
    required String token,
  }) async {
    try {
      AppLogger.debug('Getting linked social accounts');

      final response = await _apiService.get(
        '/auth/social/accounts',
        customHeaders: {'Authorization': 'Bearer $token'},
      );

      return response;
    } catch (error) {
      AppLogger.error('Get linked social accounts failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      return User.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Get current user failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.patch(
        '/auth/profile',
        data: profileData,
      );
      return User.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Update profile failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _apiService.post(
        '/auth/logout/',
        data: refreshToken != null ? {'refresh': refreshToken} : null,
      );
    } catch (error) {
      AppLogger.error('Logout failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      AppLogger.debug('Forgot password request for: $email');

      final response = await _apiService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return response;
    } catch (error) {
      AppLogger.error('Forgot password failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      AppLogger.debug('Resetting password');

      final response = await _apiService.post(
        '/auth/reset-password',
        data: {'token': token, 'new_password': newPassword},
      );

      return response;
    } catch (error) {
      AppLogger.error('Reset password failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      AppLogger.debug('Changing password');

      final response = await _apiService.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return response;
    } catch (error) {
      AppLogger.error('Change password failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  // Token verification and refresh
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      AppLogger.debug('Verifying token');

      final response = await _apiService.post(
        '/auth/verify-token',
        data: {'token': token},
      );

      return response;
    } catch (error) {
      AppLogger.error('Token verification failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      AppLogger.debug('Refreshing token');

      final response = await _apiService.post(
        '/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      return response;
    } catch (error) {
      AppLogger.error('Token refresh failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      AppLogger.debug('Verify password reset OTP for: $email');

      final response = await _apiService.post(
        '/auth/verify-reset-otp',
        data: {'email': email, 'otp': otp},
      );

      return response;
    } catch (error) {
      AppLogger.error('Verify password reset OTP failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetOtp(String email) async {
    try {
      AppLogger.debug('Send password reset OTP for: $email');

      final response = await _apiService.post(
        '/auth/send-reset-otp',
        data: {'email': email},
      );

      return response;
    } catch (error) {
      AppLogger.error('Send password reset OTP failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> sendVerificationOtp(String email) async {
    try {
      AppLogger.debug('Send verification OTP for: $email');

      final response = await _apiService.post(
        '/auth/send-verification-otp',
        data: {'email': email},
      );

      return response;
    } catch (error) {
      AppLogger.error('Send verification OTP failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      AppLogger.debug('Verify email OTP for: $email');

      final response = await _apiService.post(
        '/auth/verify-email-otp',
        data: {'email': email, 'otp': otp},
      );

      return response;
    } catch (error) {
      AppLogger.error('Verify email OTP failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }
}
