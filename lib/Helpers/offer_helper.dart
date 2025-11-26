class OfferHelpers {
  static int calculateDaysRemaining(String endDate) {
    final end = DateTime.parse(endDate);
    final now = DateTime.now();
    final difference = end.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  static bool isOfferExpired(String endDate) {
    return calculateDaysRemaining(endDate) <= 0;
  }

  static String formatDiscount(double discountPercentage) {
    return '${(discountPercentage * 100).toStringAsFixed(0)}%';
  }
}
