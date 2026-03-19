import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/subscription/subscription_model.dart';
import '../../Models/subscription/subscription_plan_model.dart';
import '../../Services/business_service.dart';
import '../../Services/api/api_service.dart';

class SubscriptionProvider extends BaseProvider {
  List<SubscriptionPlan> _plans = [];
  Subscription? _currentSubscription;
  AuthProvider? _authProvider;

  // Getters
  List<SubscriptionPlan> get plans => _plans;
  Subscription? get currentSubscription => _currentSubscription;
  bool get hasActiveSubscription => _currentSubscription?.isActive == true;
  final SubscriptionService _subscriptionService;
  SubscriptionProvider({required SubscriptionService subscriptionService})
    : _subscriptionService = subscriptionService;

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
      await _subscriptionService.getSubscriptionDetails();
      _currentSubscription = _subscriptionService.currentSubscription;
      final errorMsg = _subscriptionService.error;
      if (errorMsg != null) setError(errorMsg);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadPlans() async {
    await Future.delayed(const Duration(seconds: 1));
    _plans = [
      SubscriptionPlan(
        id: '1',
        name: 'Starter',
        description: 'Perfect for individual barbers starting out',
        price: 29.99,
        duration: 'MONTHLY',
        features: [
          '1 Branch',
          '3 Staff Members',
          'Basic Analytics',
          'Email Support',
          'Appointment Management',
        ],
        isPopular: false,
        maxBranches: 1,
        maxStaff: 3,
        analyticsEnabled: true,
        premiumSupport: false,
        trialDays: 7,
      ),
    ];
  }

  Future<void> loadCurrentSubscription() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_authProvider?.ownerProfile?.isSubscribed == true) {
      _currentSubscription = Subscription(
        id: 'sub_123456',
        customerId: _authProvider?.user?.id ?? 1,
        shopId: 1,
        planName: 'Professional Plan',
        subscriptionType: 'MONTHLY',
        price: 79.99,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 305)),
        status: 'Active',
        isActive: true,
        autoRenew: true,
        features: [
          '3 Branches',
          '10 Staff Members',
          'Advanced Analytics',
          'Priority Support',
          'Inventory Management',
          'Marketing Tools',
          'Custom Branding',
        ],
      );
    }
  }

  Future<void> upgradeToEnterprise() async {
    await _subscriptionService.upgradeSubscription('enterprise');
    await loadSubscriptionData();
  }

  Future<void> upgradeToPremium() async {
    await _subscriptionService.upgradeSubscription('premium');
    await loadSubscriptionData();
  }
}
