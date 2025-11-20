import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import 'logger.dart';

class SecurityHelper {
  static final SecurityHelper _instance = SecurityHelper._internal();

  factory SecurityHelper() => _instance;

  SecurityHelper._internal();

  // Generate secure random string
  static String generateSecureRandomString(int length) {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Generate secure token
  static String generateSecureToken() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Hash data using SHA-256
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Hash with salt
  static String hashWithSalt(String data, String salt) {
    return hashData(data + salt);
  }

  // Generate salt
  static String generateSalt() {
    return generateSecureRandomString(32);
  }

  // Validate password strength
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score >= 6) return PasswordStrength.strong;
    if (score >= 4) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  // Sanitize input data
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<.*?>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .trim();
  }

  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-()]'), ''));
  }

  // Mask sensitive data for logging
  static String maskSensitiveData(String data, {int visibleChars = 4}) {
    if (data.length <= visibleChars * 2) {
      return '*' * data.length;
    }

    final firstVisible = data.substring(0, visibleChars);
    final lastVisible = data.substring(data.length - visibleChars);
    final maskedLength = data.length - (visibleChars * 2);

    return '$firstVisible${'*' * maskedLength}$lastVisible';
  }

  // Mask email address
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${'*' * username.length}@$domain';
    }

    final firstChar = username[0];
    final lastChar = username[username.length - 1];
    final masked = '*' * (username.length - 2);

    return '$firstChar$masked$lastChar@$domain';
  }

  // Mask phone number
  static String maskPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (cleaned.length <= 4) {
      return '*' * cleaned.length;
    }

    final lastFour = cleaned.substring(cleaned.length - 4);
    return '${'*' * (cleaned.length - 4)}$lastFour';
  }

  // Generate PIN code
  static String generatePinCode(int length) {
    final random = Random.secure();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(random.nextInt(10));
    }

    return buffer.toString();
  }

  // Validate PIN code
  static bool isValidPinCode(String pin) {
    return RegExp(r'^[0-9]{4,6}$').hasMatch(pin);
  }

  // Encrypt data (basic implementation - for production use proper encryption)
  static String encryptData(String data, String key) {
    try {
      // In production, use a proper encryption library like pointycastle
      // This is a simplified version for demonstration
      final bytes = utf8.encode(data + key);
      return base64Url.encode(bytes);
    } catch (e) {
      AppLogger.error('Encryption failed', error: e);
      return data;
    }
  }

  // Decrypt data (basic implementation)
  static String decryptData(String encryptedData, String key) {
    try {
      final bytes = base64Url.decode(encryptedData);
      final decrypted = utf8.decode(bytes);
      return decrypted.substring(0, decrypted.length - key.length);
    } catch (e) {
      AppLogger.error('Decryption failed', error: e);
      return encryptedData;
    }
  }

  // Generate secure file name
  static String generateSecureFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = generateSecureRandomString(8);
    final extension = originalName.contains('.')
        ? originalName.substring(originalName.lastIndexOf('.'))
        : '';

    return '${hashData('$timestamp$random')}$extension';
  }

  // Validate file type
  static bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedExtensions.contains(extension);
  }

  // Check for malicious file names
  static bool isSafeFileName(String fileName) {
    final dangerousPatterns = [
      '..', '//', '\\', '~', '/etc/', '/bin/', '/usr/', 'cmd', 'bat', 'exe', 'sh'
    ];

    for (final pattern in dangerousPatterns) {
      if (fileName.toLowerCase().contains(pattern)) {
        return false;
      }
    }

    return RegExp(r'^[a-zA-Z0-9._\-() ]+$').hasMatch(fileName);
  }

  // Calculate data integrity hash
  static String calculateDataIntegrityHash(Map<String, dynamic> data) {
    final sortedData = _sortMap(data);
    final jsonString = json.encode(sortedData);
    return hashData(jsonString);
  }

  // Verify data integrity
  static bool verifyDataIntegrity(Map<String, dynamic> data, String expectedHash) {
    final calculatedHash = calculateDataIntegrityHash(data);
    return calculatedHash == expectedHash;
  }

  // Generate secure session ID
  static String generateSessionId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List<int>.generate(16, (i) => random.nextInt(256));

    final combined = [..._intToBytes(timestamp), ...randomBytes];
    return base64Url.encode(combined);
  }

  // Validate session ID format
  static bool isValidSessionId(String sessionId) {
    try {
      final bytes = base64Url.decode(sessionId);
      return bytes.length == 24; // 8 bytes timestamp + 16 bytes random
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
  static Map<String, dynamic> _sortMap(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final sortedMap = <String, dynamic>{};

    for (final key in sortedKeys) {
      final value = map[key];
      if (value is Map<String, dynamic>) {
        sortedMap[key] = _sortMap(value);
      } else if (value is List) {
        sortedMap[key] = _sortList(value);
      } else {
        sortedMap[key] = value;
      }
    }

    return sortedMap;
  }

  static List<dynamic> _sortList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return _sortMap(item);
      } else if (item is List) {
        return _sortList(item);
      }
      return item;
    }).toList();
  }

  static List<int> _intToBytes(int value) {
    return [
      (value >> 56) & 0xFF,
      (value >> 48) & 0xFF,
      (value >> 40) & 0xFF,
      (value >> 32) & 0xFF,
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }
}

// Rate limiting helper
class RateLimiter {
    final Map<String, List<DateTime>> _attempts = {};
    final Duration _timeWindow;
    final int _maxAttempts;

    RateLimiter({required Duration timeWindow, required int maxAttempts})
        : _timeWindow = timeWindow,
          _maxAttempts = maxAttempts;

    bool checkLimit(String identifier) {
      _cleanOldAttempts(identifier);

      final now = DateTime.now();
      final attempts = _attempts[identifier] ?? [];

      if (attempts.length >= _maxAttempts) {
        return false;
      }

      attempts.add(now);
      _attempts[identifier] = attempts;
      return true;
    }

    int getRemainingAttempts(String identifier) {
      _cleanOldAttempts(identifier);
      final attempts = _attempts[identifier] ?? [];
      return _maxAttempts - attempts.length;
    }

    Duration getTimeUntilReset(String identifier) {
      _cleanOldAttempts(identifier);
      final attempts = _attempts[identifier] ?? [];

      if (attempts.isEmpty) {
        return Duration.zero;
      }

      final oldestAttempt = attempts.first;
      final resetTime = oldestAttempt.add(_timeWindow);
      final now = DateTime.now();

      return resetTime.isAfter(now) ? resetTime.difference(now) : Duration.zero;
    }

    void resetAttempts(String identifier) {
      _attempts.remove(identifier);
    }

    void _cleanOldAttempts(String identifier) {
      final now = DateTime.now();
      final attempts = _attempts[identifier] ?? [];

      _attempts[identifier] = attempts
          .where((attempt) => now.difference(attempt) < _timeWindow)
          .toList();
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
        return 'Weak - Use a longer password with mixed characters';
      case PasswordStrength.medium:
        return 'Medium - Good, but could be stronger';
      case PasswordStrength.strong:
        return 'Strong - Excellent password security';
    }
  }

  double get score {
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
