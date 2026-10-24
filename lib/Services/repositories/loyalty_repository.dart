import '../../Helpers/logger.dart';
import '../../Models/loyalty/points_model.dart';
import '../enums/points_types.dart';

/// Repository for loyalty/points logic.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
/// Note: point awarding is currently computed locally; no backend call.
class LoyaltyRepository {
  LoyaltyRepository();

  static const Map<PointsType, int> pointsValues = {
    PointsType.appointmentComplete: 50,
    PointsType.reviewWrite: 25,
    PointsType.referral: 100,
    PointsType.rewardRedeem: 0,
    PointsType.signup: 100,
    PointsType.milestoneReached: 200,
    PointsType.other: 10,
  };

  int getPointsForAction(PointsType action) {
    return pointsValues[action] ?? 0;
  }

  Future<PointsModel> awardPoints({
    required int userId,
    required PointsType action,
    String description = '',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final points = getPointsForAction(action);
      AppLogger.debug('Awarding $points points to user $userId for $action');

      final pointsModel = PointsModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        points: points,
        type: action,
        description: description.isNotEmpty
            ? description
            : getDefaultDescription(action),
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      AppLogger.debug('Points awarded successfully: ${pointsModel.id}');
      return pointsModel;
    } catch (e) {
      AppLogger.error('Failed to award points: $e');
      rethrow;
    }
  }

  Future<PointsModel> awardReviewPoints(int userId, int reviewId) async {
    return await awardPoints(
      userId: userId,
      action: PointsType.reviewWrite,
      description: 'Points for writing a review',
      metadata: {'review_id': reviewId},
    );
  }

  Future<PointsModel> awardAppointmentPoints(
    int userId,
    int appointmentId,
  ) async {
    return await awardPoints(
      userId: userId,
      action: PointsType.appointmentComplete,
      description: 'Points for completing an appointment',
      metadata: {'appointment_id': appointmentId},
    );
  }

  String getDefaultDescription(PointsType action) {
    switch (action) {
      case PointsType.appointmentComplete:
        return 'Appointment completed';
      case PointsType.reviewWrite:
        return 'Review written';
      case PointsType.referral:
        return 'Customer referred';
      case PointsType.rewardRedeem:
        return 'Reward redeemed';
      case PointsType.signup:
        return 'Welcome bonus awarded';
      case PointsType.milestoneReached:
        return 'Loyalty milestone reached';
      case PointsType.other:
      default:
        return 'Points awarded';
    }
  }
}
