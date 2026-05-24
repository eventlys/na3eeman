import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      AppLogger.debug('Login attempt for: $email');

      final response = await _apiService.post(
        Endpoints.login,
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

      final response = await _apiService.post(
        Endpoints.register,
        data: userData,
      );

      return response;
    } catch (error) {
      AppLogger.error('Registration failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String socialId,
    required String email,
  }) async {
    try {
      AppLogger.debug('Social login attempt for: $provider - $email');

      final response = await _apiService.post(
        Endpoints.socialLogin,
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
        '/auth/check/email/', // There is no social check endpoint in Endpoints.dart yet, but this matches backend pattern
        data: {'provider': provider, 'social_id': socialId, 'email': email},
      );

      return response;
    } catch (error) {
      AppLogger.debug(
        'Check social user exists skipped/mocked: returning false',
      );
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
        Endpoints.socialLink,
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
        Endpoints.socialUnlink,
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
        Endpoints.socialAccounts,
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
      final response = await _apiService.get(Endpoints.currentUser);
      // Handling both direct response and wrapped response if any
      final userData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      return User.fromJson(userData);
    } catch (error) {
      AppLogger.error('Get current user failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.patch(
        Endpoints.profile,
        data: profileData,
      );
      final userData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      return User.fromJson(userData);
    } catch (error) {
      AppLogger.error('Update profile failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _apiService.post(
        Endpoints.logout,
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
        Endpoints.passwordReset,
        data: {'email': email},
      );

      if (response is Map<String, dynamic>) {
        return {
          'success': response['success'] ?? true,
          'message': response['message'] ?? 'OTP sent successfully'.tr(),
          ...response,
        };
      }
      return {
        'success': true,
        'message': 'OTP sent successfully'.tr(),
        'data': response,
      };
    } catch (error) {
      AppLogger.error('Forgot password failed', error: error);
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
        Endpoints.passwordResetVerify,
        data: {'email': email, 'otp': otp},
      );

      if (response is Map<String, dynamic>) {
        return {
          'success': response['success'] ?? true,
          'message': response['message'] ?? 'OTP verified successfully'.tr(),
          ...response,
        };
      }
      return {
        'success': true,
        'message': 'OTP verified successfully'.tr(),
        'data': response,
      };
    } catch (error) {
      AppLogger.error('Verify password reset OTP failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    String? token,
    String? email,
    String? otp,
    required String newPassword,
  }) async {
    try {
      AppLogger.debug('Resetting password');

      final Map<String, dynamic> data = {'new_password': newPassword};

      if (token != null) data['token'] = token;
      if (email != null) data['email'] = email;
      if (otp != null) data['otp'] = otp;

      final response = await _apiService.post(
        Endpoints.passwordResetConfirm,
        data: data,
      );

      if (response is Map<String, dynamic>) {
        return {
          'success': response['success'] ?? true,
          'message': response['message'] ?? 'Password reset successful'.tr(),
          ...response,
        };
      }
      return {
        'success': true,
        'message': 'Password reset successful'.tr(),
        'data': response,
      };
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
        Endpoints.passwordChange,
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

  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      AppLogger.debug('Verifying token');

      final response = await _apiService.post(
        Endpoints.tokenVerify,
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
        Endpoints.tokenRefresh,
        data: {'refresh_token': refreshToken},
      );

      return response;
    } catch (error) {
      AppLogger.error('Token refresh failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> sendVerificationOtp(String email) async {
    try {
      AppLogger.debug('Send verification OTP for: $email');

      final response = await _apiService.post(
        Endpoints.sendEmailVerification,
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
        Endpoints.verifyEmail,
        data: {'email': email, 'otp': otp},
      );

      return response;
    } catch (error) {
      AppLogger.error('Verify email OTP failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> adminCreateStaff(
    Map<String, dynamic> staffData,
  ) async {
    try {
      AppLogger.debug('Admin creating staff for: ${staffData['email']}');
      return await _apiService.post(
        Endpoints.adminCreateStaff,
        data: staffData,
      );
    } catch (error) {
      AppLogger.error('Admin staff creation failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<dynamic>> adminFetchSalons() async {
    try {
      final response = await _apiService.get('/salons/salons/');
      return response is List
          ? response
          : (response['results'] ?? response['data'] ?? []);
    } catch (error) {
      AppLogger.error('Admin fetch salons failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }
}
