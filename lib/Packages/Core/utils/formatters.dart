import 'package:intl/intl.dart';

class Formatters {
  // Date and Time Formatters
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  // Currency Formatter
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  // Number Formatters
  static final NumberFormat _compactNumberFormat = NumberFormat.compact();
  static final NumberFormat _decimalFormat = NumberFormat.decimalPattern();

  // Date Formatting
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }

  static String formatApiDateTime(DateTime date) {
    return _apiDateTimeFormat.format(date.toUtc());
  }

  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return formatDate(date);
    }
  }

  // Currency Formatting
  static String formatCurrency(double amount, {String? symbol}) {
    if (symbol != null) {
      return _currencyFormat.format(amount).replaceFirst('\$', symbol);
    }
    return _currencyFormat.format(amount);
  }

  static String formatCurrencyCompact(double amount) {
    return _compactNumberFormat.format(amount);
  }

  // Number Formatting
  static String formatNumber(int number) {
    return _decimalFormat.format(number);
  }

  static String formatCompactNumber(int number) {
    return _compactNumberFormat.format(number);
  }

  static String formatDecimal(double number, {int decimalDigits = 2}) {
    return number.toStringAsFixed(decimalDigits);
  }

  // Percentage Formatting
  static String formatPercentage(double value, {int decimalDigits = 1}) {
    final percentage = value * 100;
    return '${percentage.toStringAsFixed(decimalDigits)}%';
  }

  // Duration Formatting
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String formatDurationMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Phone Number Formatting
  static String formatPhoneNumber(String phoneNumber) {
    // Basic phone number formatting
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.startsWith('+')) {
      // International format
      if (cleaned.length == 13) { // +123456789012
        return '+${cleaned.substring(1, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 10)} ${cleaned.substring(10)}';
      }
    } else {
      // Local format
      if (cleaned.length == 10) { // 1234567890
        return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
      }
    }

    return phoneNumber; // Return original if format doesn't match
  }

  // File Size Formatting
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Text Formatting
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Validation Formatting
  static String formatValidationError(Map<String, dynamic> errors) {
    return errors.entries.map((entry) => '${capitalize(entry.key)}: ${entry.value}').join('\n');
  }

  // Rating Formatting
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String formatRatingStars(double rating) {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return '${'⭐' * fullStars}${hasHalfStar ? '½' : ''}${'☆' * emptyStars}';
  }
}
