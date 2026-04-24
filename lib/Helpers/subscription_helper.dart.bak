import '../Models/subscriptions/subscription.dart';
// import '../Models/subscriptions/subscription_model.dart';
import '../Services/business_service.dart';

class SubscriptionHelper {
  static final BusinessService _subscriptionService = BusinessService();

  // Get available subscription plans from the service
  static Future<List<SalonSubscription>> getSubscriptions() async {
    try {
      final plans = await _subscriptionService.getAvailablePlans();

      // Convert SubscriptionPlan to SalonSubscription
      return plans.map((plan) => SalonSubscription(
        id: plan.id,
        name: plan.name,
        description: plan.description,
        price: plan.price,
        duration: plan.duration,
        features: plan.features,
        isPopular: plan.isPopular,
        salonId: null, // This can be set based on your business logic
      )).toList();

    } catch (e) {
      print('Error fetching subscriptions from service: $e');
      // Fallback to mock data if service fails
      return _getMockSubscriptions();
    }
  }

  // Get subscription tiers from the service
  static Future<List<Object>> getSubscriptionTiers() async {
    try {
      return await _subscriptionService.getAvailablePlans();
    } catch (e) {
      print('Error fetching subscription tiers: $e');
      return [];
    }
  }

  // Get current user subscription details
  static Future<Subscription?> getCurrentSubscription() async {
    try {
      return await _subscriptionService.getSubscriptionDetails();
    } catch (e) {
      print('Error fetching current subscription: $e');
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
    final daysRemaining = subscription.endDate!.difference(DateTime.now()).inDays;
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

  // Mock data fallback (keep your existing mock data)
  static List<SalonSubscription> _getMockSubscriptions() {
    return [
      SalonSubscription(
        id: '1',
        name: 'Basic Plan',
        description: 'Perfect for casual salonpers',
        price: 9.99,
        duration: 'MONTHLY',
        features: [
          '10% discount on all items',
          'Free shipping on orders over \$50',
          'Early access to sales',
        ],
      ),
      SalonSubscription(
        id: '2',
        name: 'Premium Plan',
        description: 'Best value for frequent salonpers',
        price: 19.99,
        duration: 'MONTHLY',
        features: [
          '20% discount on all items',
          'Free shipping on all orders',
          'Exclusive member-only products',
          'Priority customer support',
          'Monthly free gift',
        ],
        isPopular: true,
      ),
      SalonSubscription(
        id: '3',
        name: 'Annual Plan',
        description: 'Save big with yearly subscription',
        price: 199.99,
        duration: 'YEARLY',
        features: [
          '25% discount on all items',
          'Free express shipping',
          'VIP customer support',
          'Birthday bonus',
          'Quarterly surprise boxes',
        ],
      ),
      SalonSubscription(
        id: '4',
        name: 'Family Plan',
        description: 'Share benefits with your family',
        price: 29.99,
        duration: 'MONTHLY',
        features: [
          '15% discount for up to 4 members',
          'Family shared benefits',
          'Separate order tracking',
        ],
      ),
      SalonSubscription(
        id: '5',
        name: 'Student Plan',
        description: 'Special discount for students',
        price: 7.99,
        duration: 'MONTHLY',
        features: [
          '15% student discount',
          'Free shipping on orders over \$30',
          'Extended return period',
        ],
      ),
    ];
  }

  // Get featured/popular subscriptions
  static Future<List<SalonSubscription>> getFeaturedSubscriptions() async {
    final allSubscriptions = await getSubscriptions();
    return allSubscriptions.where((sub) => sub.isPopular).toList();
  }

  // Get subscriptions by duration type
  static Future<List<SalonSubscription>> getSubscriptionsByDuration(String duration) async {
    final allSubscriptions = await getSubscriptions();
    return allSubscriptions
        .where((sub) => sub.duration.toUpperCase() == duration.toUpperCase())
        .toList();
  }

  // Find subscription by ID
  static Future<SalonSubscription?> getSubscriptionById(String id) async {
    final allSubscriptions = await getSubscriptions();
    return allSubscriptions.firstWhere(
      (sub) => sub.id == id,
      orElse: () => _getMockSubscriptions().firstWhere((sub) => sub.id == id),
    );
  }
}
