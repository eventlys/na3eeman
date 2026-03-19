import 'package:flutter/material.dart';
import '../../Services/barber_service.dart';
import '../../Helpers/barber_list_helper.dart';

class PerformanceProvider with ChangeNotifier {
  final BarberService _barberService;
  final PerformanceHelper _performanceHelper;

  List<BarberPerformanceData> _performanceData = [];
  bool _isLoading = false;
  String? _error;

  PerformanceProvider({
    required BarberService barberService,
    required PerformanceHelper performanceHelper,
  }) : _barberService = barberService,
       _performanceHelper = performanceHelper;

  List<BarberPerformanceData> get performanceData => _performanceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPerformanceData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final barbers = await _barberService.getBarbers();
      _performanceData = _performanceHelper.calculatePerformanceMetrics(
        barbers,
      );
    } catch (e) {
      _error = 'Failed to load performance data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void sortByRating() {
    _performanceData = _performanceHelper.sortByRating(_performanceData);
    notifyListeners();
  }

  void sortByEarnings() {
    _performanceData = _performanceHelper.sortByEarnings(_performanceData);
    notifyListeners();
  }

  void sortByEfficiency() {
    _performanceData = _performanceHelper.sortByEfficiency(_performanceData);
    notifyListeners();
  }

  void refresh() {
    loadPerformanceData();
  }
}
