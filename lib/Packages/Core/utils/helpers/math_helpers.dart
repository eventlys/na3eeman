import 'dart:math';

class MathHelpers {
  const MathHelpers._();

  static double lerp(double a, double b, double t) => a + (b - a) * t;
  static double clamp(double value, double min, double max) =>
      value.clamp(min, max).toDouble();

  static double calculatePercentage(double part, double total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }

  static double calculatePartFromPercentage(double percentage, double total) {
    return (percentage / 100) * total;
  }

  static double calculateGrowthRate(double current, double previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  static double calculateAverage(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    return numbers.reduce((a, b) => a + b) / numbers.length;
  }

  static double calculateMedian(List<double> numbers) {
    if (numbers.isEmpty) return 0;
    final sorted = numbers..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length.isOdd) {
      return sorted[middle];
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;
}
