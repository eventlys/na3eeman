import 'package:na3eeman/Models/shop/shop_service_model.dart';

class ServiceCalculator {
  static int parseDuration(String duration) {
    final regex = RegExp(r'(\d+)\s*h?\.?\s*(\d*)\s*min?');
    final match = regex.firstMatch(duration);
    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      return hours * 60 + minutes;
    }
    return 30;
  }

  static double parsePrice(String price) {
    final regex = RegExp(r'\$(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(price);
    if (match != null) return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    return 0.0;
  }

  static String formatTotalDuration(List<ShopService> services) {
    if (services.isEmpty) return '0 min';
    int totalMinutes = 0;
    for (var service in services) totalMinutes += parseDuration(service.duration);
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    } else {
      return '${totalMinutes} min';
    }
  }

  static String formatTotalPrice(List<ShopService> services) {
    if (services.isEmpty) return '\$0';
    double total = 0;
    for (var service in services) total += parsePrice(service.price);
    return '\$${total.toStringAsFixed(0)}';
  }

  static int getTotalDurationInMinutes(List<ShopService> services) {
    int totalMinutes = 0;
    for (var service in services) totalMinutes += parseDuration(service.duration);
    return totalMinutes;
  }
}
