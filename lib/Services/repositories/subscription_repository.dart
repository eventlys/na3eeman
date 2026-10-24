import '../../Helpers/logger.dart';
import '../../Models/subscription/subscription_model.dart';
import '../../Models/subscription/subscription_plan_model.dart';
import '../api/api_service.dart';
import '../api/endpoints.dart';

/// Repository for subscription backend access.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class SubscriptionRepository {
  final ApiService _apiService;

  SubscriptionRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<Subscription> getSubscriptionDetails() async {
    try {
      final response = await _apiService.get('/subscription');
      return Subscription.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error fetching subscription details: $e');
      rethrow;
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await _apiService.get(
        Endpoints.platformSubscriptionPlans,
      );
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];
      return data.map((item) => SubscriptionPlan.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching subscription plans: $e');
      rethrow;
    }
  }

  Future<Subscription> subscribe({
    required String planId,
    required String paymentMethodId,
    String? couponCode,
    bool autoRenew = true,
  }) async {
    try {
      final response = await _apiService.post(
        '/subscription/subscribe',
        data: {
          'plan_id': planId,
          'payment_method_id': paymentMethodId,
          'coupon_code': couponCode,
          'auto_renew': autoRenew,
        },
      );
      return Subscription.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error subscribing to plan: $e');
      rethrow;
    }
  }
}
