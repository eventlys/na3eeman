import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/subscription/subscription_model.dart';
import '../../Models/subscription/subscription_plan_model.dart';
import '../../Services/business_service.dart';
import '../../Services/api/api_service.dart';

class SubscriptionProvider extends BaseProvider {
  final ApiService _apiService;
  final SubscriptionService _subscriptionService;

  List<SubscriptionPlan> _plans = [];
  Subscription? _currentSubscription;
  AuthProvider? _authProvider;

  // Getters
  List<SubscriptionPlan> get plans => _plans;
  Subscription? get currentSubscription => _currentSubscription;
  bool get hasActiveSubscription => _currentSubscription?.isActive == true;

  SubscriptionProvider({
    required SubscriptionService subscriptionService,
    ApiService? apiService,
  }) : _subscriptionService = subscriptionService,
       _apiService = apiService ?? ApiService();

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      loadSubscriptionData();
    }
  }

  Future<void> loadSubscriptionData() async {
    setLoading(true);
    notifyListeners();

    try {
      // 1. Load available plans
      await loadPlans();

      // 2. Load current subscription if user is owner
      if (_authProvider?.user?.isOwner == true) {
        await loadCurrentSubscription();
      }

      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadPlans() async {
    try {
      final List<dynamic> data = await _apiService.getSubscriptionPlans();
      _plans = data.map((json) => SubscriptionPlan.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading plans: $e');
      rethrow;
    }
  }

  /// Fetch the raw subscription plan list (pure delegate, no state change).
  /// Used by widgets that need the plans without mutating provider state.
  Future<List<dynamic>> getSubscriptionPlans() =>
      _apiService.getSubscriptionPlans();

  Future<void> loadCurrentSubscription() async {
    try {
      // Assuming Endpoint exists for current user subscription
      final response = await _apiService.get('/salons/subscriptions/current/');
      if (response != null && response['data'] != null) {
        _currentSubscription = Subscription.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Error loading current subscription: $e');
      // Non-fatal, user might not have one yet
    }
  }

  Future<void> upgradeToEnterprise() async {
    setLoading(true);
    try {
      await _subscriptionService.upgradeSubscription('enterprise');
      await loadSubscriptionData();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> upgradeToPremium() async {
    setLoading(true);
    try {
      await _subscriptionService.upgradeSubscription('premium');
      await loadSubscriptionData();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
