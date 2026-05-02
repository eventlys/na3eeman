import 'package:flutter/material.dart';
import '../../Services/expert_service.dart';
import '../../Helpers/expert_list_helper.dart';

class PerformanceProvider with ChangeNotifier {
  final ExpertService _expertService;
  final PerformanceHelper _performanceHelper;

  List<ExpertPerformanceData> _performanceData = [];
  bool _isLoading = false;
  String? _error;

  PerformanceProvider({
    required ExpertService expertService,
    required PerformanceHelper performanceHelper,
  }) : _expertService = expertService,
       _performanceHelper = performanceHelper;

  List<ExpertPerformanceData> get performanceData => _performanceData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPerformanceData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final experts = await _expertService.getExperts();
      _performanceData = _performanceHelper.calculatePerformanceMetrics(
        experts,
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
