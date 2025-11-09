import 'package:logger/logger.dart';
/*import 'package:http/http.dart' as http;*/



class AuthService {
  final Logger _logger = Logger();
  static const String baseUrl = 'https://your-api.com/api/v1/auth'; // Update with your actual API URL

  // static void logout() {
  //   // Implement your logout logic here
  //   print('User logged out');
  // }
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Replace with your actual API call
    try {
      // Mock API response - replace with real API call
      final response = await _mockLoginApi(email, password);
      return response;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _mockLoginApi(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Replace this with your actual API response structure
    return {
      'token': 'your_jwt_token',
      'user': {
        'id': 1,
        'email': email,
        'role': 'customer', // This would come from your API
        'name': 'John Doe',
      }
    };
  }

  // Signup method - ADD THIS INSIDE THE CLASS
  Future<Map<String, dynamic>> signup(
      String firstName,
      String secondName,
      String email,
      String phoneNumber,
      String gender,
      String password,
      String role,
      )  async {
    try {
      // Replace with your actual signup API call
      final response = await _mockSignupApi(
        firstName,
        secondName,
        email,
        phoneNumber,
        gender,
        password,
        role,
      );
      return response;
    } catch (e) {
      _logger.e('Signup error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _mockSignupApi(
      String firstName,
      String secondName,
      String email,
      String phoneNumber,
      String gender,
      String password,
      String role,
      )  async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Replace this with your actual API response structure
    return {
      'token': 'your_jwt_token',
      'user': {
        'id': 2,
        'email': email,
        'role': role,
        'name': '$firstName $secondName',
        'phone': phoneNumber,
        'gender': gender,
      }
    };
  }

  // FORGOT PASSWORD METHODS

  // Forgot Password - Request Reset Link
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      _logger.i('Sending forgot password request for email: $email');

      // Replace with your actual API call
      final response = await _mockForgotPasswordApi(email);

      _logger.i('Forgot password response: ${response['success']}');
      return response;
    } catch (e) {
      _logger.e('Forgot password error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> _mockForgotPasswordApi(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock response - replace with your actual API call
    // This simulates the generic response regardless of email existence
    return {
      'success': true,
      'message': 'If an account with that email exists, a password reset link has been sent to $email.',
    };
  }

  // ACTUAL API IMPLEMENTATION (COMMENTED OUT - READY FOR YOUR REAL API)
  /*
  Future<Map<String, dynamic>> _realForgotPasswordApi(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'If an account with that email exists, a password reset link has been sent to $email.',
      };
    } else {
      return {
        'success': false,
        'message': 'Error sending reset email. Please try again.',
      };
    }
  }
  */

  // Validate Reset Token
  Future<Map<String, dynamic>> validateResetToken(String token) async {
    try {
      _logger.i('Validating reset token');

      // Replace with your actual API call
      final response = await _mockValidateTokenApi(token);

      _logger.i('Token validation result: ${response['success']}');
      return response;
    } catch (e) {
      _logger.e('Token validation error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> _mockValidateTokenApi(String token) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation - in real scenario, check if token is valid and not expired
    final isValid = token.isNotEmpty && token.length > 10; // Simple validation
    return {
      'success': isValid,
      'message': isValid ? 'Token is valid' : 'Invalid or expired reset token',
    };
  }

  // ACTUAL API IMPLEMENTATION (COMMENTED OUT - READY FOR YOUR REAL API)
  /*
  Future<Map<String, dynamic>> _realValidateTokenApi(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/validate-reset-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': token}),
    );

    final data = json.decode(response.body);
    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? 'Token validation failed',
    };
  }
  */

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  })  async {
    try {
      _logger.i('Resetting password for token');

      // Replace with your actual API call
      final response = await _mockResetPasswordApi(
        token: token,
        newPassword: newPassword,
      );

      _logger.i('Password reset result: ${response['success']}');
      return response;
    } catch (e) {
      _logger.e('Password reset error: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> _mockResetPasswordApi({
    required String token,
    required String newPassword,
  })  async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock response - replace with your actual API call
    final isSuccess = token.isNotEmpty && newPassword.length >= 8;

    return {
      'success': isSuccess,
      'message': isSuccess
          ? 'Password reset successfully!'
          : 'Error resetting password. Please try again.',
      'token': isSuccess ? 'new_jwt_token_after_reset' : null,
    };
  }

  // ACTUAL API IMPLEMENTATION (COMMENTED OUT - READY FOR YOUR REAL API)
  /*
  Future<Map<String, dynamic>> _realResetPasswordApi({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    final data = json.decode(response.body);

    return {
      'success': response.statusCode == 200,
      'message': data['message'] ?? (response.statusCode == 200
          ? 'Password reset successfully!'
          : 'Error resetting password.'),
      'token': data['token'], // If your API returns a new JWT
    };
  }
  */

  // You can add other auth methods here
  // Future<void> logout() async {
  //   // Clear tokens, etc.
  //   _logger.i('User logged out');
  // }

  static void logout() {
    // Implement your logout logic here
    print('User logged out');
    // Clear tokens, user data, etc.
    // Navigate to login page
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    // Get current user from storage
    _logger.i('Getting current user');
    return {};
  }

  // OTP METHODS
  Future<Map<String, dynamic>> sendPasswordResetOtp(String email) async {
    try {
      _logger.i('Sending password reset OTP for email: $email');

      // In real implementation, this would send OTP to user's phone
      // For now, we'll mock it and assume OTP is '123456'
      final response = await _mockSendOtpApi(email);

      _logger.i('OTP sent: ${response['success']}');
      return response;
    } catch (e) {
      _logger.e('Send OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> _mockSendOtpApi(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock response - in real app, this would send SMS/WhatsApp OTP
    return {
      'success': true,
      'message': 'OTP sent to your registered phone number',
      'otpLength': 6, // For UI to know how many OTP digits to expect
    };
  }

  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  })  async {
    try {
      _logger.i('Verifying OTP for email: $email');

      final response = await _mockVerifyOtpApi(email: email, otp: otp);

      _logger.i('OTP verification: ${response['success']}');
      return response;
    } catch (e) {
      _logger.e('Verify OTP error: $e');
      return {
        'success': false,
        'message': 'OTP verification failed. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> _mockVerifyOtpApi({
    required String email,
    required String otp,
  })  async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock verification - in real app, verify against what was sent
    // For demo purposes, any 6-digit OTP starting with '123' will work
    final isValid = otp.length == 6 && otp.startsWith('123');

    return {
      'success': isValid,
      'message': isValid ? 'OTP verified successfully' : 'Invalid OTP',
      'resetToken': isValid ? 'reset_token_after_otp_verification' : null,
    };
  }
}

