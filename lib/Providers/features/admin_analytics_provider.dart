import 'package:flutter/material.dart';
import '../../Models/loyalty/feedback_model.dart';
import '../../Services/analytics_service.dart';

class AdminAnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _usageStats;
  Map<String, dynamic>? _financialStats;
  Map<String, dynamic>? _systemStats;
  
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get overview => _overview;
  Map<String, dynamic>? get userStats => _userStats;
  Map<String, dynamic>? get usageStats => _usageStats;
  Map<String, dynamic>? get financialStats => _financialStats;
  Map<String, dynamic>? get systemStats => _systemStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _overview = await _analyticsService.getAdminOverview();
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminAnalytics Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final futures = [
        _analyticsService.getAdminOverview(),
        _analyticsService.getAdminUserAnalytics(),
        _analyticsService.getAdminUsageAnalytics(),
        _analyticsService.getAdminFinancialAnalytics(),
        _analyticsService.getAdminSystemAnalytics(),
      ];
      final results = await Future.wait(futures);
      _overview = results[0];
      _userStats = results[1];
      _usageStats = results[2];
      _financialStats = results[3];
      _systemStats = results[4];
    } catch (e) {
      _error = e.toString();
      debugPrint('AdminAnalytics All Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserAnalytics() async {
    try {
      _userStats = await _analyticsService.getAdminUserAnalytics();
      notifyListeners();
    } catch (e) {
      debugPrint('UserAnalytics Error: $e');
    }
  }

  Future<void> fetchUsageAnalytics() async {
    try {
      _usageStats = await _analyticsService.getAdminUsageAnalytics();
      notifyListeners();
    } catch (e) {
       debugPrint('UsageAnalytics Error: $e');
    }
  }

  Future<void> fetchFinancialAnalytics() async {
    try {
      _financialStats = await _analyticsService.getAdminFinancialAnalytics();
      notifyListeners();
    } catch (e) {
       debugPrint('FinancialAnalytics Error: $e');
    }
  }

  /// Fetches user service requests with optional filters.
  Future<List<HelpFeedback>> fetchServiceRequests({
    String ageFilter = 'all',
    String roleFilter = 'all',
    String subFilter = 'all',
  }) async {
    try {
      final params = <String, String>{};
      if (ageFilter != 'all') params['age'] = ageFilter;
      if (roleFilter != 'all') params['role'] = roleFilter;
      if (subFilter != 'all') params['subscription'] = subFilter;

      final data = await _analyticsService.getServiceRequests(params);
      return data.map((json) => HelpFeedback.fromJson(json)).toList();
    } catch (e) {
      debugPrint('ServiceRequests Error: $e');
      return [];
    }
  }
}
