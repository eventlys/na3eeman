import '../Models/subscriptions/subscription.dart';
// import '../Models/subscriptions/subscription_model.dart';
import '../Services/business_service.dart';
import 'package:na3eeman/Helpers/logger.dart';

class SubscriptionHelper {
  static final BusinessService _subscriptionService = BusinessService();

  // Get available subscription plans from the service
  static Future<List<SalonSubscription>> getSubscriptions() async {
    try {
      final plans = await _subscriptionService.getAvailablePlans();

      // Convert SubscriptionPlan to SalonSubscription
      return plans
          .map(
            (plan) => SalonSubscription(
              id: plan.id,
              name: plan.name,
              description: plan.description,
              price: plan.price,
              duration: plan.duration,
              features: plan.features,
              isPopular: plan.isPopular,
              salonId: null, // This can be set based on your business logic
            ),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching subscriptions from service: $e');
      rethrow;
    }
  }

  // Get subscription tiers from the service
  static Future<List<Object>> getSubscriptionTiers() async {
    try {
      return await _subscriptionService.getAvailablePlans();
    } catch (e) {
      AppLogger.error('Error fetching subscription tiers: $e');
      return [];
    }
  }

  // Get current user subscription details
  static Future<Subscription?> getCurrentSubscription() async {
    try {
      return await _subscriptionService.getSubscriptionDetails();
    } catch (e) {
      AppLogger.error('Error fetching current subscription: $e');
      return null;
    }
  }

  // Format price with currency symbol
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Calculate and format price per month based on duration
  static String getPricePerMonth(double price, String duration) {
    double monthlyPrice = price;

    switch (duration.toUpperCase()) {
      case 'BIWEEKLY':
        monthlyPrice = price * 2; // 2 times per month
        break;
      case 'YEARLY':
      case 'ANNUAL':
        monthlyPrice = price / 12;
        break;
      case 'QUARTERLY':
        monthlyPrice = price / 3;
        break;
      // 'MONTHLY' is already the monthly price
    }

    return '\$${monthlyPrice.toStringAsFixed(2)}/month';
  }

  // Calculate savings percentage for annual vs monthly plans
  static double calculateAnnualSavings(double monthlyPrice) {
    final annualPrice = monthlyPrice * 12;
    final discountedAnnualPrice = annualPrice * 0.8; // 20% discount for annual
    return ((annualPrice - discountedAnnualPrice) / annualPrice) * 100;
  }

  // Get duration in readable format
  static String getReadableDuration(String duration) {
    switch (duration.toUpperCase()) {
      case 'MONTHLY':
        return 'per month';
      case 'BIWEEKLY':
        return 'every 2 weeks';
      case 'QUARTERLY':
        return 'per quarter';
      case 'YEARLY':
      case 'ANNUAL':
        return 'per year';
      default:
        return duration.toLowerCase();
    }
  }

  // Check if subscription is about to expire (within 7 days)
  static bool isSubscriptionExpiringSoon(Subscription subscription) {
    if (subscription.endDate == null) return false;
    final daysRemaining = subscription.endDate!
        .difference(DateTime.now())
        .inDays;
    return daysRemaining <= 7 && daysRemaining > 0;
  }

  // Get subscription status badge text
  static String getStatusBadgeText(Subscription subscription) {
    if (!subscription.isActive) return 'Inactive';
    if (subscription.isExpired) return 'Expired';
    if (isSubscriptionExpiringSoon(subscription)) return 'Expiring Soon';
    return 'Active';
  }

  // Get subscription status color (for UI)
  static String getStatusColor(Subscription subscription) {
    if (!subscription.isActive || subscription.isExpired) return 'red';
    if (isSubscriptionExpiringSoon(subscription)) return 'orange';
    return 'green';
  }

  // Get featured/popular subscriptions
  static Future<List<SalonSubscription>> getFeaturedSubscriptions() async {
    final allSubscriptions = await getSubscriptions();
    return allSubscriptions.where((sub) => sub.isPopular).toList();
  }

  // Get subscriptions by duration type
  static Future<List<SalonSubscription>> getSubscriptionsByDuration(
    String duration,
  ) async {
    final allSubscriptions = await getSubscriptions();
    return allSubscriptions
        .where((sub) => sub.duration.toUpperCase() == duration.toUpperCase())
        .toList();
  }

  // Find subscription by ID
  static Future<SalonSubscription?> getSubscriptionById(String id) async {
    final allSubscriptions = await getSubscriptions();
    try {
      return allSubscriptions.firstWhere((sub) => sub.id == id);
    } catch (e) {
      return null;
    }
  }
}
