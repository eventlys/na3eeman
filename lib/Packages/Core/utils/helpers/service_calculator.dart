import 'package:na3eeman/Models/salon/salon_service_model.dart';

import '../../../../Helpers/service_models_helper.dart';

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

  static String formatTotalDuration(List<Map<String, dynamic>> services) {
    try {
      int totalMinutes = 0;

      for (final service in services) {
        final duration = ServiceDataHelper.getServiceDuration(service);
        totalMinutes += _parseDurationToMinutes(duration);
      }

      if (totalMinutes < 60) {
        return '$totalMinutes min';
      } else {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
      }
    } catch (e) {
      return '0 min';
    }
  }

  static String formatTotalPrice(List<Map<String, dynamic>> services) {
    try {
      double total = 0.0;

      for (final service in services) {
        final priceString = ServiceDataHelper.getServicePrice(service);
        // Remove currency symbols and parse
        final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
        total += double.tryParse(cleanPrice) ?? 0.0;
      }

      return '\$${total.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  static int _parseDurationToMinutes(String duration) {
    try {
      if (duration.toLowerCase().contains('hour') || duration.contains('h')) {
        final hoursMatch = RegExp(r'(\d+)\s*h').firstMatch(duration);
        final minutesMatch = RegExp(r'(\d+)\s*m').firstMatch(duration);

        final hours = int.tryParse(hoursMatch?.group(1) ?? '0') ?? 0;
        final minutes = int.tryParse(minutesMatch?.group(1) ?? '0') ?? 0;

        return hours * 60 + minutes;
      } else {
        // Assume it's just minutes
        final minutesMatch = RegExp(r'(\d+)').firstMatch(duration);
        return int.tryParse(minutesMatch?.group(1) ?? '0') ?? 0;
      }
    } catch (e) {
      return 0;
    }
  }

  static double calculateTotalPriceValue(List<Map<String, dynamic>> services) {
    try {
      double total = 0.0;

      for (final service in services) {
        final priceString = ServiceDataHelper.getServicePrice(service);
        final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
        total += double.tryParse(cleanPrice) ?? 0.0;
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Calculate total duration in minutes
  static int calculateTotalDurationMinutes(
    List<Map<String, dynamic>> services,
  ) {
    try {
      int totalMinutes = 0;

      for (final service in services) {
        final duration = ServiceDataHelper.getServiceDuration(service);
        totalMinutes += _parseDurationToMinutes(duration);
      }

      return totalMinutes;
    } catch (e) {
      return 0;
    }
  }

  static int getTotalDurationInMinutes(List<SalonService> services) {
    int totalMinutes = 0;
    for (var service in services) {
      totalMinutes += parseDuration(service.duration);
    }
    return totalMinutes;
  }
}
