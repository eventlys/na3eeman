import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../Packages/Core/constants/app_color.dart';
import '../Packages/Core/constants/app_images.dart';

class LoginHelper {
  final Logger _logger = Logger();

  static Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    throw UnimplementedError(
      'Use AuthProvider for login instead of LoginHelper',
    );
  }

  /// Validates email format
  Map<String, dynamic> validateEmail(String email) {
    if (email.isEmpty) {
      return {'isValid': false, 'message': 'Email cannot be empty'};
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return {
        'isValid': false,
        'message': 'Please enter a valid email address',
      };
    }

    return {'isValid': true, 'message': 'Valid email'};
  }

  /// Validates password format
  Map<String, dynamic> validatePassword(String password) {
    if (password.isEmpty) {
      return {'isValid': false, 'message': 'Password cannot be empty'};
    }

    if (password.length < 6) {
      return {
        'isValid': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    return {'isValid': true, 'message': 'Valid password'};
  }

  /// Validates login form
  Map<String, dynamic> validateLoginForm({
    required String email,
    required String password,
  }) {
    final emailValidation = validateEmail(email);
    if (!emailValidation['isValid']) {
      return emailValidation;
    }

    final passwordValidation = validatePassword(password);
    if (!passwordValidation['isValid']) {
      return passwordValidation;
    }

    return {'isValid': true, 'message': 'Form is valid'};
  }

  /// Get role-based configuration with theme colors
  Map<String, dynamic> getRoleConfig(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return {
          'color': AppColor.primary,
          'icon': Icons.person,
          'name': 'Customer',
          'homeRoute': '/customer_home',
          'lightColor': AppColor.lightPrimary,
          'darkColor': AppColor.darkPrimary,
        };
      case 'expert':
        return {
          'color': AppColor.lightExpert,
          'icon': Icons.content_cut,
          'name': 'Expert',
          'homeRoute': '/expert_home',
          'lightColor': AppColor.lightExpert,
          'darkColor': AppColor.darkExpert,
        };
      case 'owner':
        return {
          'color': AppColor.secondary,
          'icon': Icons.business,
          'name': 'Owner',
          'homeRoute': '/owner_home',
          'lightColor': AppColor.lightSecondary,
          'darkColor': AppColor.darkSecondary,
        };
      case 'admin':
        return {
          'color': AppColor.lightError,
          'icon': Icons.admin_panel_settings,
          'name': 'Admin',
          'homeRoute': '/admin_home',
          'lightColor': AppColor.lightError,
          'darkColor': AppColor.darkError,
        };
      case 'manager':
        return {
          'color': AppColor.lightManager,
          'icon': Icons.manage_accounts,
          'name': 'Manager',
          'homeRoute': '/manager_home',
          'lightColor': AppColor.lightManager,
          'darkColor': AppColor.darkManager,
        };
      case 'assistant':
        return {
          'color': AppColor.lightAssistant,
          'icon': Icons.assistant,
          'name': 'Assistant',
          'homeRoute': '/assistant_home',
          'lightColor': AppColor.lightAssistant,
          'darkColor': AppColor.darkAssistant,
        };
      case 'receptionist':
        return {
          'color': AppColor.lightReceptionist,
          'icon': Icons.desk,
          'name': 'Receptionist',
          'homeRoute': '/receptionist_home',
          'lightColor': AppColor.lightReceptionist,
          'darkColor': AppColor.darkReceptionist,
        };
      default:
        return {
          'color': AppColor.lightTextHint,
          'icon': Icons.person,
          'name': 'User',
          'homeRoute': '/home',
          'lightColor': AppColor.lightTextHint,
          'darkColor': AppColor.darkTextHint,
        };
    }
  }

  /// Get social login configuration with theme colors
  Map<String, dynamic> getSocialLoginConfig(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return {'icon': ImageIcon(AssetImage(AppImages.google))};
      case 'facebook':
        return {'icon': ImageIcon(AssetImage(AppImages.facebook))};
      default:
        return {'icon': ImageIcon(AssetImage(AppImages.apple))};
    }
  }

  /// Process login response and extract user data
  Map<String, dynamic> processLoginResponse(Map<String, dynamic> response) {
    try {
      final success = response['success'] ?? false;
      final message = response['message'] ?? '';
      final userData = response['user'] ?? {};
      final token = response['token'] ?? '';

      // Extract user details with fallbacks
      final role = userData['role']?.toString().toLowerCase() ?? 'customer';
      final name = userData['name']?.toString() ?? 'User';

      // Get role configuration
      final roleConfig = getRoleConfig(role);

      return {
        'success': success,
        'message': message,
        'user': userData,
        'token': token,
        'role': role,
        'roleConfig': roleConfig,
        'userName': name,
      };
    } catch (e) {
      _logger.e('Error processing login response: $e');
      return {
        'success': false,
        'message': 'Error processing login response',
        'user': {},
        'token': '',
        'role': 'customer',
        'roleConfig': getRoleConfig('customer'),
        'userName': 'User',
      };
    }
  }

  /// Handle login errors with theme-aware messaging
  String handleLoginError(dynamic error) {
    _logger.e('Login error: $error');

    if (error is String) {
      // Check for common error messages and provide user-friendly responses
      if (error.toLowerCase().contains('invalid credentials') ||
          error.toLowerCase().contains('wrong password') ||
          error.toLowerCase().contains('user not found')) {
        return 'Invalid email or password. Please try again.';
      } else if (error.toLowerCase().contains('network') ||
          error.toLowerCase().contains('socket')) {
        return 'Network error. Please check your internet connection.';
      } else if (error.toLowerCase().contains('timeout')) {
        return 'Request timeout. Please try again.';
      }
      return error;
    }

    // Handle specific error types
    if (error.toString().contains('network') ||
        error.toString().contains('socket')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('401')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (error.toString().contains('404')) {
      return 'Account not found. Please check your email address.';
    } else if (error.toString().contains('422')) {
      return 'Invalid input. Please check your information.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.toString().contains('email not verified')) {
      return 'Please verify your email address before logging in.';
    } else if (error.toString().contains('account suspended')) {
      return 'Your account has been suspended. Please contact support.';
    } else {
      return 'Login failed. Please try again.';
    }
  }

  /// Get social login providers
  List<String> getSocialLoginProviders() {
    return ['google', 'facebook', 'apple'];
  }

  /// Validate if user can access specific role-based features
  bool canAccessFeature(String userRole, String feature) {
    final rolePermissions = {
      'admin': ['all'],
      'owner': [
        'manage_salon',
        'manage_staff',
        'view_reports',
        'manage_appointments',
      ],
      'manager': ['manage_staff', 'view_reports', 'manage_appointments'],
      'expert': ['manage_appointments', 'view_schedule', 'update_availability'],
      'receptionist': [
        'manage_appointments',
        'view_schedule',
        'customer_management',
      ],
      'assistant': ['view_schedule', 'assist_appointments'],
      'customer': ['book_appointments', 'view_history', 'manage_profile'],
    };

    final userPermissions = rolePermissions[userRole] ?? [];
    return userPermissions.contains('all') || userPermissions.contains(feature);
  }

  /// Get feature-specific colors
  Map<String, dynamic> getFeatureColors(String feature) {
    switch (feature) {
      case 'manage_salon':
        return {
          'color': AppColor.lightSecondary,
          'iconColor': AppColor.light,
          'darkColor': AppColor.darkSecondary,
        };
      case 'manage_staff':
        return {
          'color': AppColor.lightExpert,
          'iconColor': AppColor.light,
          'darkColor': AppColor.darkExpert,
        };
      case 'manage_appointments':
        return {
          'color': AppColor.primary,
          'iconColor': AppColor.light,
          'darkColor': AppColor.darkPrimary,
        };
      case 'view_reports':
        return {
          'color': AppColor.lightManager,
          'iconColor': AppColor.light,
          'darkColor': AppColor.darkManager,
        };
      default:
        return {
          'color': AppColor.lightTextHint,
          'iconColor': AppColor.light,
          'darkColor': AppColor.darkTextHint,
        };
    }
  }
}
