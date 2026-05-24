import 'package:intl/intl.dart';

class GiftCardUtils {
  /// Value = Price (No profit deduction as per user request)
  static double calculateValue(double price) {
    return price;
  }

  /// Calculates profit (0% as per user request)
  static double calculateProfit(double price) {
    return 0.0;
  }

  /// Formats the gift card ID/Code for display
  static String formatCardCode(String code) {
    if (code.length <= 4) return code;
    return code
        .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
        .trim();
  }

  /// Checks if the card is expired
  static bool isExpired(DateTime expiresAt) {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Gets remaining days until expiry
  static int remainingDays(DateTime expiresAt) {
    final difference = expiresAt.difference(DateTime.now());
    return max(0, difference.inDays);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

int max(int a, int b) => a > b ? a : b;
