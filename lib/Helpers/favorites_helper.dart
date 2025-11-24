class FavoritesHelper {
  // Format shop data for display
  static String formatShopName(Map<String, dynamic> shop) {
    return shop['shopName'] ?? 'Unknown Shop';
  }

  static String formatAddress(Map<String, dynamic> shop) {
    return shop['address'] ?? 'Address not available';
  }

  static double parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  double _parseShopRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  static String formatRating(dynamic rating) {
    return parseRating(rating).toStringAsFixed(1);
  }

  static String formatServices(List<dynamic>? services) {
    if (services == null || services.isEmpty) return 'No services listed';
    return services.join(', ');
  }

  // Get appropriate icon based on shop type or service
  static String getShopIcon(Map<String, dynamic> shop) {
    final type = shop['type']?.toString().toLowerCase() ?? '';

    if (type.contains('barber') || type.contains('hair')) {
      return 'assets/icons/scissors.png'; // Update with your actual icon path
    } else if (type.contains('spa') || type.contains('salon')) {
      return 'assets/icons/spa.png'; // Update with your actual icon path
    } else if (type.contains('nail')) {
      return 'assets/icons/nail.png'; // Update with your actual icon path
    }

    return 'assets/icons/shop.png'; // Default shop icon
  }

  // Validate shop data
  static bool isValidShop(Map<String, dynamic> shop) {
    return shop['id'] != null && shop['shopName'] != null;
  }

  // Sort favorites by different criteria
  static List<Map<String, dynamic>> sortFavorites(
    List<Map<String, dynamic>> shops,
    String sortBy
  ) {
    final sortedShops = List<Map<String, dynamic>>.from(shops);

    switch (sortBy) {
      case 'name':
        sortedShops.sort((a, b) =>
          (a['shopName'] ?? '').compareTo(b['shopName'] ?? ''));
        break;
      case 'rating':
        sortedShops.sort((a, b) =>
          (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
        break;
      case 'distance':
        sortedShops.sort((a, b) =>
          (a['distance'] ?? double.infinity).compareTo(b['distance'] ?? double.infinity));
        break;
      case 'recent':
      default:
        // Keep original order (most likely added date)
        break;
    }

    return sortedShops;
  }

  // Filter favorites
  static List<Map<String, dynamic>> filterFavorites(
    List<Map<String, dynamic>> shops,
    String query,
  ) {
    if (query.isEmpty) return shops;

    final lowerQuery = query.toLowerCase();
    return shops.where((shop) {
      final name = shop['shopName']?.toString().toLowerCase() ?? '';
      final address = shop['address']?.toString().toLowerCase() ?? '';
      final services = shop['services']?.toString().toLowerCase() ?? '';

      return name.contains(lowerQuery) ||
             address.contains(lowerQuery) ||
             services.contains(lowerQuery);
    }).toList();
  }

  // Get shop statistics
  static Map<String, int> getFavoritesStats(List<Map<String, dynamic>> shops) {
    int totalShops = shops.length;
    int withRating = shops.where((shop) => shop['rating'] != null).length;
    int withServices = shops.where((shop) =>
      shop['services'] != null && (shop['services'] as List).isNotEmpty).length;

    return {
      'total': totalShops,
      'withRating': withRating,
      'withServices': withServices,
    };
  }
}
