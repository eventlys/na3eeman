import '../Models/points_model.dart';

class PointsService {
  static const Map<PointsType, int> pointsValues = {
    PointsType.inviteFriend: 25,
    PointsType.rateShop: 15,
    PointsType.arriveOnTime: 10,
    PointsType.shopFeedback: 20,
    PointsType.rateApp: 50,
    PointsType.appFeedback: 50,
    PointsType.makeAppointment: 10,
  };

  static const Map<PointsType, String> pointsDescriptions = {
    PointsType.inviteFriend: 'Invited a friend',
    PointsType.rateShop: 'Rated a shop',
    PointsType.arriveOnTime: 'Arrived on time for appointment',
    PointsType.shopFeedback: 'Added shop feedback',
    PointsType.rateApp: 'Rated the app',
    PointsType.appFeedback: 'Added app feedback',
    PointsType.makeAppointment: 'Make Appointment',
  };

  static PointsModel addPoints({
    required PointsModel currentPoints,
    required PointsType type,
    String? shopName,
  }) {
    // Check if it's a one-time action that's already completed
    if (_isOneTimeAction(type) &&
        currentPoints.completedOneTimeActions.contains(type)) {
      return currentPoints;
    }

    final points = pointsValues[type] ?? 0;
    final description = _buildDescription(type, pointsDescriptions[type]!, shopName);

    final newTransaction = PointsTransaction(
      type: type,
      points: points,
      date: DateTime.now(),
      description: description,
    );

    final newCompletedActions = {...currentPoints.completedOneTimeActions};
    if (_isOneTimeAction(type)) {
      newCompletedActions.add(type);
    }

    return currentPoints.copyWith(
      totalPoints: currentPoints.totalPoints + points,
      transactions: [...currentPoints.transactions, newTransaction],
      completedOneTimeActions: newCompletedActions,
    );
  }

  static bool _isOneTimeAction(PointsType type) {
    return type == PointsType.rateApp || type == PointsType.appFeedback;
  }

  static String _buildDescription(PointsType type, String baseDescription, String? shopName) {
    switch (type) {
      case PointsType.rateShop:
      case PointsType.shopFeedback:
        return '$baseDescription${shopName != null ? ' - $shopName' : ''}';
      default:
        return baseDescription;
    }
  }

  static bool canEarnPoints(PointsModel points, PointsType type) {
    if (_isOneTimeAction(type)) {
      return !points.completedOneTimeActions.contains(type);
    }
    return true;
  }

  static int getPointsValue(PointsType type) {
    return pointsValues[type] ?? 0;
  }
}

