// ignore_for_file: unused_field
class AppValidators {
  // Singleton pattern with private constructor
  AppValidators._();

  // Pre-compiled regex patterns for better performance
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  static final RegExp _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  static final RegExp _htmlRegex = RegExp(r'<[^>]*>', multiLine: true);

  static final RegExp _sqlInjectionRegex = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|EXEC|ALTER|CREATE|TRUNCATE)\b)',
    caseSensitive: false,
  );

  static final RegExp _urlRegex = RegExp(
    r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$',
  );

  static final RegExp _creditCardRegex = RegExp(r'^\d{13,19}$');

  // ========== SECURITY & SANITIZATION ==========

  /// Sanitizes input by removing HTML tags and limiting length
  static String? sanitizeInput(String? input, {int maxLength = 1000}) {
    if (input == null) return null;

    // Remove HTML tags
    var sanitized = input.replaceAll(_htmlRegex, '');

    // Trim whitespace
    sanitized = sanitized.trim();

    // Limit length
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Checks for potentially malicious input
  static bool isPotentialMaliciousInput(String input) {
    return _htmlRegex.hasMatch(input) ||
        _sqlInjectionRegex.hasMatch(input) ||
        input.contains('javascript:') ||
        input.contains('data:') ||
        input.length > 10000;
  }

  /// Sanitizes entire map of string values
  static Map<String, dynamic> sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.value is String) {
        sanitized[entry.key] = sanitizeInput(entry.value as String);
      } else {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  // ========== VALIDATION METHODS WITH SECURITY ==========

  /// Validates email with security checks
  static String? validateEmail(String? value, {bool securityChecks = true}) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    if (securityChecks) {
      // Security checks
      if (isPotentialMaliciousInput(email)) {
        return 'Invalid email format';
      }

      // Check email length
      if (email.length > 254) {
        return 'Email is too long';
      }
    }

    final errors = <String>[];
    if (!email.contains('@')) {
      errors.add('• Include an @ symbol');
    } else {
      final parts = email.split('@');
      if (parts[0].isEmpty) {
        errors.add('• Text before @ (e.g., string@)');
      }
      if (parts.length > 1 && !parts[1].contains('.')) {
        errors.add('• A domain name (e.g., mailservice.com)');
      }
    }

    // Validate overall email format
    if (!_emailRegex.hasMatch(email)) {
      if (errors.isNotEmpty) {
        return 'Email must contain:\n${errors.join('\n')}';
      } else {
        return 'Please enter a valid email address (e.g., name@example.com)';
      }
    }

    return null;
  }

  /// Validates phone number
  static String? validatePhone(String? value, {bool securityChecks = true}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    if (securityChecks && isPotentialMaliciousInput(phone)) {
      return 'Invalid phone number format';
    }

    // Clean phone number for validation
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    final errors = <String>[];

    if (cleanedPhone.length != 10) {
      errors.add('• Exactly 10 digits');
    } else if (!RegExp(r'^\d+$').hasMatch(cleanedPhone)) {
      errors.add('• Only numbers allowed');
    }

    if (!cleanedPhone.startsWith('07')) {
      errors.add('• Start with 07');
    }

    if (errors.isNotEmpty) {
      return 'Phone number must contain:\n${errors.join('\n')}';
    }

    return null;
  }

  /// Validates name with security checks
  static String? validateName(String? value, {bool securityChecks = true}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    final name = value.trim();

    if (securityChecks) {
      final sanitized = sanitizeInput(name);
      if (sanitized != name) {
        return 'Name contains invalid characters';
      }

      if (isPotentialMaliciousInput(name)) {
        return 'Invalid name format';
      }
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (name.length > 50) {
      return 'Name is too long';
    }

    return null;
  }

  /// Validates password with configurable security level
  static String? validatePassword(
    String? value, {
    bool strongValidation = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (isPotentialMaliciousInput(value)) {
      return 'Invalid password format';
    }

    if (strongValidation) {
      final errors = <String>[];
      if (value.length < 8) {
        errors.add('• At least 8 characters');
      }
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        errors.add('• At least 1 uppercase letter');
      }
      if (!RegExp(r'[a-z]').hasMatch(value)) {
        errors.add('• At least 1 lowercase letter');
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        errors.add('• At least 1 number');
      }
      if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
        errors.add('• At least 1 special character');
      }

      if (errors.isNotEmpty) {
        return 'Password must contain:\n${errors.join('\n')}';
      }
    } else {
      if (value.length < 6) {
        return 'Password must be at least 6 characters';
      }
    }

    return null;
  }

  /// Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates hourly rate/numeric value
  static String? validateHourlyRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hourly rate is required';
    }

    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Please enter a valid number';
    }

    if (rate < 0) {
      return 'Hourly rate cannot be negative';
    }

    return null;
  }

  // ========== BOOLEAN VALIDATION HELPERS ==========

  /// Pure validation without error messages
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim()) &&
        !isPotentialMaliciousInput(email);
  }

  /// Pure phone validation
  static bool isValidPhone(String phone) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    return _phoneRegex.hasMatch(cleanedPhone) &&
        !isPotentialMaliciousInput(phone);
  }

  /// URL validation
  static bool isValidUrl(String url) {
    return _urlRegex.hasMatch(url) && !isPotentialMaliciousInput(url);
  }

  /// Credit card validation with Luhn algorithm
  static bool isValidCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (!_creditCardRegex.hasMatch(cleaned)) return false;
    if (isPotentialMaliciousInput(cardNumber)) return false;
    return _isValidLuhn(cleaned);
  }

  /// Date validation
  static bool isValidDate(String date) {
    try {
      DateTime.parse(date);
      return !isPotentialMaliciousInput(date);
    } catch (e) {
      return false;
    }
  }

  /// Password strength validation
  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (isPotentialMaliciousInput(password)) return false;

    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  // ========== PRIVATE HELPERS ==========

  /// Luhn algorithm for credit card validation
  static bool _isValidLuhn(String number) {
    int sum = 0;
    bool isEven = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      if (isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      isEven = !isEven;
    }
    return sum % 10 == 0;
  }
}
