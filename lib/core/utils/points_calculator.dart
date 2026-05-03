import 'dart:math';

class PointsCalculator {
  /// Conversion rate: 100 points = 0.50 JOD
  static const double pointsPerJod = 200.0;
  static const double jodPerPoint = 0.005;

  /// Converts JOD amount to Points
  static int jodToPoints(double jod) {
    return (jod * pointsPerJod).round();
  }

  /// Converts Points to JOD amount
  static double pointsToJod(int points) {
    return points * jodPerPoint;
  }

  /// Exact Delayed Payment Formula:
  /// JOD = 0.005 × (P_total − 200 × C_JOD + max(D × (L / 2), 0.40 × 200 × C_JOD))
  ///
  /// Variables:
  /// - [currentPoints] (P_total): Total points the customer has earned
  /// - [serviceCostJod] (C_JOD): Service cost in JOD
  /// - [delayHours] (L): Total late hours
  /// - [penaltyPerHalfHour] (D): Delay penalty value per half-hour (default 10)
  static DelayedPaymentResult calculateDelayedPayment({
    required int currentPoints,
    required double serviceCostJod,
    required double delayHours,
    int penaltyPerHalfHour = 10,
  }) {
    final double pTotal = currentPoints.toDouble();
    final double cJod = serviceCostJod;
    final double d = penaltyPerHalfHour.toDouble();
    final double l = delayHours;

    // Step 1: Convert service cost to points
    final double cPoints = 200 * cJod;

    // Step 2: Calculate base penalty
    final double basePenalty = d * (l / 2);

    // Step 3: Calculate minimum penalty (40% of service cost)
    final double minPenalty = 0.40 * cPoints;

    // Step 4: Take the larger penalty
    final double finalPenalty = max(basePenalty, minPenalty);

    // Step 5: Calculate net points
    final double netPoints = pTotal - cPoints + finalPenalty;

    // Step 6: Convert to JOD
    final double jodResult = netPoints * 0.005;

    return DelayedPaymentResult(
      jodResult: jodResult,
      netPoints: netPoints.toInt(),
      finalPenaltyPoints: finalPenalty.toInt(),
      servicePoints: cPoints.toInt(),
    );
  }
}

class DelayedPaymentResult {
  final double jodResult;
  final int netPoints;
  final int finalPenaltyPoints;
  final int servicePoints;

  DelayedPaymentResult({
    required this.jodResult,
    required this.netPoints,
    required this.finalPenaltyPoints,
    required this.servicePoints,
  });

  bool get owesMoney => jodResult < 0;
  double get amountOwed => owesMoney ? jodResult.abs() : 0.0;
  double get creditAmount => owesMoney ? 0.0 : jodResult;
}
