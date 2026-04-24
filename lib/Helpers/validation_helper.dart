
class ValidationHelper {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Phone number validation
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(
      r'^\+?[0-9]{10,15}$',
    );
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-()]'), ''));
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int strength = 0;

    // Check length
    if (password.length >= 8) strength++;

    // Check for uppercase
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;

    // Check for lowercase
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;

    // Check for numbers
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;

    // Check for special characters
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    switch (strength) {
      case 0:
      case 1:
      case 2:
        return PasswordStrength.weak;
      case 3:
      case 4:
        return PasswordStrength.medium;
      case 5:
        return PasswordStrength.strong;
      default:
        return PasswordStrength.weak;
    }
  }

  // Name validation
  static bool isValidName(String name) {
    return name.length >= 2 && RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  // URL validation
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (_) {
      return false;
    }
  }

  // Date validation
  static bool isValidDate(DateTime date) {
    return date.isBefore(DateTime(2100, 1, 1)) &&
           date.isAfter(DateTime(1900, 1, 1));
  }

  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Credit card validation (basic)
  static bool isValidCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s\-]'), '');
    return RegExp(r'^[0-9]{13,19}$').hasMatch(cleaned);
  }

  // CVV validation
  static bool isValidCVV(String cvv) {
    return RegExp(r'^[0-9]{3,4}$').hasMatch(cvv);
  }

  // Amount validation
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 1000000; // Reasonable limit
  }

  // Rating validation
  static bool isValidRating(double rating) {
    return rating >= 1 && rating <= 5;
  }

  // Appointment time validation
  static bool isValidAppointmentTime(DateTime startTime, DateTime endTime) {
    return endTime.isAfter(startTime) &&
           startTime.isAfter(DateTime.now().subtract(const Duration(hours: 1)));
  }

  // Business validation
  static bool isValidSalonName(String name) {
    return name.length >= 2 && name.length <= 100;
  }

  static bool isValidServiceName(String name) {
    return name.isNotEmpty && name.length <= 50;
  }

  static bool isValidServicePrice(double price) {
    return price >= 0 && price <= 1000;
  }

  static bool isValidServiceDuration(int duration) {
    return duration > 0 && duration <= 480; // Max 8 hours
  }

  // Address validation
  static bool isValidAddress(String address) {
    return address.length >= 5 && address.length <= 200;
  }

  // Coordinate validation
  static bool isValidLatitude(double lat) {
    return lat >= -90 && lat <= 90;
  }

  static bool isValidLongitude(double lng) {
    return lng >= -180 && lng <= 180;
  }

  // File validation
  static bool isValidImageFile(String fileName) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedExtensions.contains(extension);
  }

  static bool isValidFileSize(int fileSizeInBytes, {int maxSizeInMB = 10}) {
    return fileSizeInBytes <= maxSizeInMB * 1024 * 1024;
  }

  // Loyalty points validation
  static bool isValidPoints(int points) {
    return points >= 0 && points <= 100000;
  }

  // Review validation
  static bool isValidReviewComment(String comment) {
    return comment.length >= 10 && comment.length <= 1000;
  }

  // Bulk validation methods
  static Map<String, String> validateUserRegistration({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String gender,
    required String role,
  }) {
    final errors = <String, String>{};

    if (!isValidName(firstName)) {
      errors['firstName'] = 'Please enter a valid first name (min 2 characters)';
    }

    if (!isValidName(lastName)) {
      errors['lastName'] = 'Please enter a valid last name (min 2 characters)';
    }

    if (!isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    if (!isValidPhoneNumber(phone)) {
      errors['phone'] = 'Please enter a valid phone number';
    }

    if (!isValidPassword(password)) {
      errors['password'] = 'Password must be at least 6 characters long';
    }

    if (gender.isEmpty) {
      errors['gender'] = 'Please select a gender';
    }

    if (role.isEmpty) {
      errors['role'] = 'Please select a role';
    }

    return errors;
  }

  static Map<String, String> validateAppointmentBooking({
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> services,
  }) {
    final errors = <String, String>{};

    if (!isFutureDate(startTime)) {
      errors['startTime'] = 'Appointment must be in the future';
    }

    if (!endTime.isAfter(startTime)) {
      errors['endTime'] = 'End time must be after start time';
    }

    if (services.isEmpty) {
      errors['services'] = 'At least one service is required';
    }

    return errors;
  }

  // Helper to check if all validations pass
  static bool isValidationSuccessful(Map<String, String> errors) {
    return errors.isEmpty;
  }

  // Get validation error message
  static String getValidationMessage(Map<String, String> errors) {
    if (errors.isEmpty) return '';
    return errors.values.join('\n');
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get description {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.medium:
        return 'Medium strength password';
      case PasswordStrength.strong:
        return 'Strong password';
    }
  }

  double get percentage {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
