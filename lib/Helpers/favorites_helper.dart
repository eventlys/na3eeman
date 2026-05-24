class FavoritesHelper {
  // Format salon data for display
  static String formatSalonName(Map<String, dynamic> salon) {
    return salon['salonName'] ?? 'Unknown Salon';
  }

  static String formatAddress(Map<String, dynamic> salon) {
    return salon['address'] ?? 'Address not available';
  }

  static double parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  double _parseSalonRating(dynamic rating) {
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

  // Get appropriate icon based on salon type or service
  static String getSalonIcon(Map<String, dynamic> salon) {
    final type = salon['type']?.toString().toLowerCase() ?? '';

    if (type.contains('expert') || type.contains('hair')) {
      return 'assets/icons/scissors.png'; // Update with your actual icon path
    } else if (type.contains('spa') || type.contains('salon')) {
      return 'assets/icons/spa.png'; // Update with your actual icon path
    } else if (type.contains('nail')) {
      return 'assets/icons/nail.png'; // Update with your actual icon path
    }

    return 'assets/icons/salon.png'; // Default salon icon
  }

  // Validate salon data
  static bool isValidSalon(Map<String, dynamic> salon) {
    return salon['id'] != null && salon['salonName'] != null;
  }

  // Sort favorites by different criteria
  static List<Map<String, dynamic>> sortFavorites(
    List<Map<String, dynamic>> salons,
    String sortBy,
  ) {
    final sortedSalons = List<Map<String, dynamic>>.from(salons);

    switch (sortBy) {
      case 'name':
        sortedSalons.sort(
          (a, b) => (a['salonName'] ?? '').compareTo(b['salonName'] ?? ''),
        );
        break;
      case 'rating':
        sortedSalons.sort(
          (a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0),
        );
        break;
      case 'distance':
        sortedSalons.sort(
          (a, b) => (a['distance'] ?? double.infinity).compareTo(
            b['distance'] ?? double.infinity,
          ),
        );
        break;
      case 'recent':
      default:
        // Keep original order (most likely added date)
        break;
    }

    return sortedSalons;
  }

  // Filter favorites
  static List<Map<String, dynamic>> filterFavorites(
    List<Map<String, dynamic>> salons,
    String query,
  ) {
    if (query.isEmpty) return salons;

    final lowerQuery = query.toLowerCase();
    return salons.where((salon) {
      final name = salon['salonName']?.toString().toLowerCase() ?? '';
      final address = salon['address']?.toString().toLowerCase() ?? '';
      final services = salon['services']?.toString().toLowerCase() ?? '';

      return name.contains(lowerQuery) ||
          address.contains(lowerQuery) ||
          services.contains(lowerQuery);
    }).toList();
  }

  // Get salon statistics
  static Map<String, int> getFavoritesStats(List<Map<String, dynamic>> salons) {
    int totalSalons = salons.length;
    int withRating = salons.where((salon) => salon['rating'] != null).length;
    int withServices = salons
        .where(
          (salon) =>
              salon['services'] != null &&
              (salon['services'] as List).isNotEmpty,
        )
        .length;

    return {
      'total': totalSalons,
      'withRating': withRating,
      'withServices': withServices,
    };
  }
}
