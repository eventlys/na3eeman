import 'package:flutter/material.dart';
import '../../Services/business_service.dart';
import '../../Helpers/profit_helper.dart';

class ProfitProvider with ChangeNotifier {
  final ProfitService _reportService;

  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _yearlyData = [];
  bool _isLoading = false;
  String? _error;
  bool _isMonthlyView = true;

  ProfitProvider({required ProfitService reportService})
    : _reportService = reportService;

  // Getters
  List<Map<String, dynamic>> get currentData =>
      _isMonthlyView ? _monthlyData : _yearlyData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isMonthlyView => _isMonthlyView;

  double get totalRevenue {
    final data = _isMonthlyView ? _monthlyData : _yearlyData;
    return data.fold(
      0.0,
      (sum, item) => sum + (item['revenue'] as num).toDouble(),
    );
  }

  double get totalProfit {
    final data = _isMonthlyView ? _monthlyData : _yearlyData;
    return data.fold(
      0.0,
      (sum, item) => sum + (item['profit'] as num).toDouble(),
    );
  }

  double get totalExpenses {
    final data = _isMonthlyView ? _monthlyData : _yearlyData;
    return data.fold(
      0.0,
      (sum, item) => sum + (item['expenses'] as num).toDouble(),
    );
  }

  // Methods
  Future<void> loadProfitData({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
    String? authToken,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawData = await _reportService.getProfitData(
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        authToken: authToken,
      );

      // Generate monthly and yearly data
      _monthlyData = ProfitHelper.generateMonthlyProfitData(
        rawData,
        startDate,
        endDate,
      );
      _yearlyData = ProfitHelper.generateYearlyProfitData(
        rawData,
        startDate,
        endDate,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profit data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleView() {
    _isMonthlyView = !_isMonthlyView;
    notifyListeners();
  }

  void setMonthlyView(bool isMonthly) {
    _isMonthlyView = isMonthly;
    notifyListeners();
  }

  Future<void> downloadReport({
    required String format,
    required String fileName,
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
    String? authToken,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _reportService.generateReport(
        reportType: 'profit',
        format: format,
        fileName: fileName,
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        authToken: authToken,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Download failed: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
