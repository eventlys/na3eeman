import 'package:flutter/foundation.dart';
import '../Models/points_model.dart';
import '../Services/points_service.dart';

class PointsProvider with ChangeNotifier {
  PointsModel _points = PointsModel(
    totalPoints: 0,
    transactions: [],
    completedOneTimeActions: {},
  );

  PointsModel get points => _points;

  void addPoints(PointsType type, {String? shopName}) {
    _points = PointsService.addPoints(
      currentPoints: _points,
      type: type,
      shopName: shopName,
    );
    notifyListeners();
    _saveToStorage();
  }

  bool canEarnPoints(PointsType type) {
    return PointsService.canEarnPoints(_points, type);
  }

  void loadPoints(PointsModel points) {
    _points = points;
    notifyListeners();
  }

  void _saveToStorage() {
    // Implement your storage logic here (SharedPreferences, Hive, etc.)
    // For now, we'll just print to console
    if (kDebugMode) {
      print('Points saved: ${_points.toJson()}');
    }
  }
}
