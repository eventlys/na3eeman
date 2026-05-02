import 'package:logger/logger.dart';

class PasswordHelper {
  final Logger _logger = Logger();

  /// Validates password strength
  Map<String, dynamic> validatePassword(String password) {
    if (password.isEmpty) {
      return {
        'isValid': false,
        'message': 'Password cannot be empty',
        'strength': 'weak',
      };
    }

    if (password.length < 8) {
      return {
        'isValid': false,
        'message': 'Password must be at least 8 characters',
        'strength': 'weak',
      };
    }

    // Check for password strength criteria
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    final strengthCriteria = [hasUppercase, hasLowercase, hasDigits, hasSpecialChars];
    final metCriteriaCount = strengthCriteria.where((criteria) => criteria).length;

    String strength;
    if (metCriteriaCount >= 4) {
      strength = 'strong';
    } else if (metCriteriaCount >= 3) {
      strength = 'good';
    } else if (metCriteriaCount >= 2) {
      strength = 'fair';
    } else {
      strength = 'weak';
    }

    return {
      'isValid': true,
      'message': _getPasswordStrengthMessage(strength),
      'strength': strength,
      'criteria': {
        'length': password.length >= 8,
        'uppercase': hasUppercase,
        'lowercase': hasLowercase,
        'digits': hasDigits,
        'specialChars': hasSpecialChars,
      },
    };
  }

  String _getPasswordStrengthMessage(String strength) {
    switch (strength) {
      case 'strong':
        return 'Strong password';
      case 'good':
        return 'Good password';
      case 'fair':
        return 'Fair password - consider adding more character types';
      case 'weak':
        return 'Weak password - use uppercase, lowercase, numbers, and symbols';
      default:
        return 'Password must be at least 8 characters';
    }
  }

  /// Generates password requirements widget data
  Map<String, dynamic> getPasswordRequirements(String password) {
    final validation = validatePassword(password);
    final criteria = validation['criteria'] as Map<String, bool>? ?? {};

    return {
      'requirements': [
        {
          'text': 'At least 8 characters',
          'isMet': criteria['length'] ?? false,
        },
        {
          'text': 'Uppercase letter (A-Z)',
          'isMet': criteria['uppercase'] ?? false,
        },
        {
          'text': 'Lowercase letter (a-z)',
          'isMet': criteria['lowercase'] ?? false,
        },
        {
          'text': 'Number (0-9)',
          'isMet': criteria['digits'] ?? false,
        },
        {
          'text': 'Special character (!@#\$ etc.)',
          'isMet': criteria['specialChars'] ?? false,
        },
      ],
      'strength': validation['strength'],
      'message': validation['message'],
    };
  }

  /// Validates reset token format
  bool validateResetToken(String token) {
    return token.isNotEmpty && token.length >= 6;
  }

  /// Handles post-reset navigation
  List<Map<String, dynamic>> getPostResetSteps(bool isSuccess) {
    if (isSuccess) {
      return [
        {'step': 'Password updated successfully', 'completed': true},
        {'step': 'Securing your account', 'completed': true},
        {'step': 'Redirecting to login', 'completed': false},
      ];
    } else {
      return [
        {'step': 'Password reset failed', 'completed': false},
        {'step': 'Please try again', 'completed': false},
      ];
    }
  }
}
