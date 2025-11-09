import '../Models/subscription_model.dart';

class SubscriptionHelper {
  static List<ShopSubscription> getSubscriptions() {
    return [
      ShopSubscription(
        id: '1',
        name: 'Basic Plan',
        description: 'Perfect for casual shoppers',
        price: 9.99,
        duration: const Duration(days: 30),
        features: [
          '10% discount on all items',
          'Free shipping on orders over \$50',
          'Early access to sales',
        ],
      ),
      ShopSubscription(
        id: '2',
        name: 'Premium Plan',
        description: 'Best value for frequent shoppers',
        price: 19.99,
        duration: const Duration(days: 30),
        features: [
          '20% discount on all items',
          'Free shipping on all orders',
          'Exclusive member-only products',
          'Priority customer support',
          'Monthly free gift',
        ],
        isPopular: true,
      ),
      ShopSubscription(
        id: '3',
        name: 'Annual Plan',
        description: 'Save big with yearly subscription',
        price: 199.99,
        duration: const Duration(days: 365),
        features: [
          '25% discount on all items',
          'Free express shipping',
          'VIP customer support',
          'Birthday bonus',
          'Quarterly surprise boxes',
        ],
      ),
      ShopSubscription(
        id: '4',
        name: 'Family Plan',
        description: 'Share benefits with your family',
        price: 29.99,
        duration: const Duration(days: 30),
        features: [
          '15% discount for up to 4 members',
          'Family shared benefits',
          'Separate order tracking',
        ],
      ),
      ShopSubscription(
        id: '5',
        name: 'Student Plan',
        description: 'Special discount for students',
        price: 7.99,
        duration: const Duration(days: 30),
        features: [
          '15% student discount',
          'Free shipping on orders over \$30',
          'Extended return period',
        ],
      ),
    ];
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String getPricePerMonth(double price, Duration duration) {
    final months = duration.inDays / 30;
    final monthlyPrice = price / months;
    return '\$${monthlyPrice.toStringAsFixed(2)}/month';
  }
}

