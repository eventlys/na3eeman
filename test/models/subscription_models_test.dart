import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Models/subscription/subscription_model.dart';
import 'package:na3eeman/Models/subscription/subscription_plan_model.dart';

// Characterization tests for the merged subscription models.
// The two parallel folder trees (Models/subscription/ and the deleted
// Models/subscriptions/) were merged into Models/subscription/; these tests
// pin down that fromJson accepts BOTH legacy payload shapes per class.
void main() {
  group('Subscription.fromJson', () {
    test('parses the Django-FK payload shape (customer/salon keys)', () {
      final sub = Subscription.fromJson({
        'id': 12,
        'customer': 7,
        'salon': 3,
        'plan_name': 'Premium Plan',
        'subscription_type': 'BIWEEKLY',
        'price': 149.99,
        'start_date': '2026-10-01T00:00:00.000',
        'end_date': '2026-11-01T00:00:00.000',
        'status': 'Active',
        'is_active': true,
        'auto_renew': false,
        'features': ['booking', 'analytics'],
      });

      // Quirk: numeric ids are stringified via .toString().
      expect(sub.id, '12');
      expect(sub.customerId, 7);
      expect(sub.salonId, 3);
      expect(sub.planName, 'Premium Plan');
      expect(sub.subscriptionType, 'BIWEEKLY');
      expect(sub.price, 149.99);
      expect(sub.startDate, DateTime.parse('2026-10-01T00:00:00.000'));
      expect(sub.endDate, DateTime.parse('2026-11-01T00:00:00.000'));
      expect(sub.status, 'Active');
      expect(sub.isActive, isTrue);
      expect(sub.autoRenew, isFalse);
      expect(sub.features, ['booking', 'analytics']);
    });

    test('parses the Flutter-style payload shape (snake/camel id keys)', () {
      final sub = Subscription.fromJson({
        'id': 'sub_9',
        'customer_id': 7,
        'salonId': 3,
        'plan_name': 'Studio',
        'subscriptionType': 'MONTHLY',
        'price': 49,
        'startDate': '2026-10-01T00:00:00.000',
        'endDate': '2026-10-31T00:00:00.000',
        'status': 'Active',
        'is_active': true,
        'auto_renew': true,
        'features': ['booking'],
      });

      expect(sub.id, 'sub_9');
      expect(sub.customerId, 7);
      expect(sub.salonId, 3);
      expect(sub.planName, 'Studio');
      expect(sub.subscriptionType, 'MONTHLY');
      // Quirk: int price is coerced to double.
      expect(sub.price, 49.0);
      expect(sub.price, isA<double>());
      expect(sub.startDate, DateTime.parse('2026-10-01T00:00:00.000'));
      expect(sub.endDate, DateTime.parse('2026-10-31T00:00:00.000'));
    });

    test('parses a price sent as a string', () {
      final sub = Subscription.fromJson({
        'customer': 7,
        'salon': 3,
        'price': '99.50',
        'start_date': '2026-10-01T00:00:00.000',
      });
      expect(sub.price, 99.5);
    });

    test('applies defaults for missing optional fields', () {
      final sub = Subscription.fromJson({
        'customer': 7,
        'salon': 3,
        'start_date': '2026-10-01T00:00:00.000',
      });

      // Quirk: missing id becomes '', missing price becomes 0.0,
      // plan/type/status fall back to placeholder defaults.
      expect(sub.id, '');
      expect(sub.planName, 'Premium Plan');
      expect(sub.subscriptionType, 'MONTHLY');
      expect(sub.price, 0.0);
      expect(sub.endDate, isNull);
      expect(sub.status, 'Active');
      expect(sub.isActive, isTrue);
      expect(sub.autoRenew, isTrue);
      expect(sub.features, isEmpty);
    });

    test('mixed camelCase id keys parse (customerId/salonId)', () {
      final sub = Subscription.fromJson({
        'customerId': 8,
        'salonId': 4,
        'start_date': '2026-10-01T00:00:00.000',
      });
      expect(sub.customerId, 8);
      expect(sub.salonId, 4);
    });

    test('Django-FK keys win over the Flutter-style keys when both exist', () {
      final sub = Subscription.fromJson({
        'customer': 7,
        'customer_id': 99,
        'salon': 3,
        'salon_id': 88,
        'start_date': '2026-10-01T00:00:00.000',
      });
      expect(sub.customerId, 7);
      expect(sub.salonId, 3);
    });

    test('throws TypeError when start date is missing', () {
      // `startDate as String` on a missing key throws a TypeError
      // (null is not a String), not a FormatException.
      expect(
        () => Subscription.fromJson({'customer': 7, 'salon': 3}),
        throwsA(isA<TypeError>()),
      );
    });

    test('toJson round-trips through fromJson', () {
      final original = Subscription.fromJson({
        'id': 12,
        'customer': 7,
        'salon': 3,
        'plan_name': 'Premium Plan',
        'subscription_type': 'BIWEEKLY',
        'price': 149.99,
        'start_date': '2026-10-01T00:00:00.000',
        'end_date': '2026-11-01T00:00:00.000',
        'status': 'Active',
        'is_active': true,
        'auto_renew': false,
        'features': ['booking'],
      });
      final reparsed = Subscription.fromJson(original.toJson());

      // Note: toJson writes 'customer'/'salon' (the Django-FK shape), so the
      // round trip exercises that branch of the fallback chain.
      expect(reparsed.id, original.id);
      expect(reparsed.customerId, original.customerId);
      expect(reparsed.salonId, original.salonId);
      expect(reparsed.planName, original.planName);
      expect(reparsed.subscriptionType, original.subscriptionType);
      expect(reparsed.price, original.price);
      expect(reparsed.startDate, original.startDate);
      expect(reparsed.endDate, original.endDate);
      expect(reparsed.status, original.status);
      expect(reparsed.isActive, original.isActive);
      expect(reparsed.autoRenew, original.autoRenew);
      expect(reparsed.features, original.features);
    });

    test('isExpired and daysRemaining derive from endDate', () {
      Subscription withEnd(DateTime? end) => Subscription.fromJson({
        'customer': 7,
        'salon': 3,
        'start_date': '2026-10-01T00:00:00.000',
        'end_date': end?.toIso8601String(),
      });

      expect(withEnd(null).isExpired, isFalse);
      expect(withEnd(null).daysRemaining, 0);
      expect(
        withEnd(DateTime.now().subtract(const Duration(days: 1))).isExpired,
        isTrue,
      );
      expect(
        withEnd(DateTime.now().add(const Duration(days: 5))).isExpired,
        isFalse,
      );
    });
  });

  group('SalonSubscription.fromJson', () {
    test('parses a full payload', () {
      final plan = SalonSubscription.fromJson({
        'id': 5,
        'name': 'Studio',
        'description': 'Small team plan',
        'price': 29,
        'duration': 'BIWEEKLY',
        'features': ['booking'],
        'is_popular': true,
        'salon': 3,
      });

      expect(plan.id, '5'); // numeric id stringified
      expect(plan.name, 'Studio');
      expect(plan.description, 'Small team plan');
      expect(plan.price, 29.0);
      expect(plan.price, isA<double>());
      expect(plan.duration, 'BIWEEKLY');
      expect(plan.features, ['booking']);
      expect(plan.isPopular, isTrue);
      expect(plan.salonId, 3);
    });

    test('applies defaults for missing optional fields', () {
      final plan = SalonSubscription.fromJson({
        'name': 'Studio',
        'description': 'Small team plan',
        'price': 29.0,
      });
      expect(plan.id, '');
      expect(plan.duration, 'MONTHLY'); // default
      expect(plan.features, isEmpty);
      expect(plan.isPopular, isFalse);
      expect(plan.salonId, isNull);
    });

    test('formattedPrice and formattedDuration helpers', () {
      SalonSubscription withDuration(String duration) => SalonSubscription(
        id: '1',
        name: 'Plan',
        description: 'Desc',
        price: 29.5,
        duration: duration,
        features: const [],
      );

      expect(withDuration('MONTHLY').formattedPrice, '\$29.50');
      expect(withDuration('MONTHLY').formattedDuration, '1 month');
      expect(withDuration('BIWEEKLY').formattedDuration, '2 weeks');
      expect(withDuration('YEARLY').formattedDuration, 'yearly');
    });

    test('copyWith overrides only the given fields', () {
      final original = SalonSubscription.fromJson({
        'id': 'p1',
        'name': 'Studio',
        'description': 'Small team plan',
        'price': 29.0,
        'duration': 'MONTHLY',
        'features': ['booking'],
        'is_popular': false,
      });
      final copied = original.copyWith(name: 'Elite', price: 79.0);

      expect(copied.name, 'Elite');
      expect(copied.price, 79.0);
      expect(copied.id, original.id);
      expect(copied.description, original.description);
      expect(copied.duration, original.duration);
      expect(copied.features, original.features);
      expect(copied.isPopular, original.isPopular);
      expect(copied.salonId, original.salonId);
    });
  });

  group('SubscriptionPlan.fromJson', () {
    Map<String, dynamic> fullPayload() {
      return {
        'id': 2,
        'name': 'Elite',
        'description': 'Full-service clinic',
        'price': 79,
        'duration': 'MONTHLY',
        'features': ['analytics', 'support'],
        'is_popular': true,
        'max_branches': 5,
        'max_staff': 20,
        'analytics_enabled': true,
        'premium_support': true,
        'trial_days': 14,
      };
    }

    test('parses a full payload', () {
      final plan = SubscriptionPlan.fromJson(fullPayload());

      expect(plan.id, '2'); // numeric id stringified
      expect(plan.name, 'Elite');
      expect(plan.description, 'Full-service clinic');
      // Quirk: int price is coerced to double.
      expect(plan.price, 79.0);
      expect(plan.price, isA<double>());
      expect(plan.duration, 'MONTHLY');
      expect(plan.features, ['analytics', 'support']);
      expect(plan.isPopular, isTrue);
      expect(plan.maxBranches, 5);
      expect(plan.maxStaff, 20);
      expect(plan.analyticsEnabled, isTrue);
      expect(plan.premiumSupport, isTrue);
      expect(plan.trialDays, 14);
    });

    test('applies defaults for a sparse payload', () {
      final plan = SubscriptionPlan.fromJson({
        'name': 'Basic',
        'description': 'Starter',
        'price': 0,
      });

      expect(plan.id, '');
      expect(plan.duration, 'MONTHLY'); // default
      expect(plan.features, isEmpty);
      expect(plan.isPopular, isFalse);
      // Quirk: max_branches/max_staff stay null when absent (the old
      // singular-folder model defaulted them to 1/3; the merged model is
      // nullable and only the models — not callers — changed).
      expect(plan.maxBranches, isNull);
      expect(plan.maxStaff, isNull);
      expect(plan.analyticsEnabled, isFalse);
      expect(plan.premiumSupport, isFalse);
      expect(plan.trialDays, 0);
    });

    test('toJson round-trips through fromJson', () {
      final original = SubscriptionPlan.fromJson(fullPayload());
      final reparsed = SubscriptionPlan.fromJson(original.toJson());

      expect(reparsed.id, original.id);
      expect(reparsed.name, original.name);
      expect(reparsed.description, original.description);
      expect(reparsed.price, original.price);
      expect(reparsed.duration, original.duration);
      expect(reparsed.features, original.features);
      expect(reparsed.isPopular, original.isPopular);
      expect(reparsed.maxBranches, original.maxBranches);
      expect(reparsed.maxStaff, original.maxStaff);
      expect(reparsed.analyticsEnabled, original.analyticsEnabled);
      expect(reparsed.premiumSupport, original.premiumSupport);
      expect(reparsed.trialDays, original.trialDays);
    });

    test('price description helpers', () {
      SubscriptionPlan withDuration(String duration) => SubscriptionPlan(
        id: '1',
        name: 'Plan',
        description: 'Desc',
        price: 29.5,
        duration: duration,
        features: const [],
      );

      expect(withDuration('MONTHLY').formattedDuration, 'per month');
      expect(withDuration('BIWEEKLY').formattedDuration, 'every 2 weeks');
      expect(withDuration('YEARLY').formattedDuration, 'per yearly');
      expect(withDuration('MONTHLY').fullPriceDescription, '\$29.50 per month');
    });

    test('copyWith overrides only the given fields', () {
      final original = SubscriptionPlan.fromJson(fullPayload());
      final copied = original.copyWith(name: 'Empire', price: 199.0);

      expect(copied.name, 'Empire');
      expect(copied.price, 199.0);
      expect(copied.id, original.id);
      expect(copied.duration, original.duration);
      expect(copied.maxBranches, original.maxBranches);
      expect(copied.maxStaff, original.maxStaff);
      expect(copied.trialDays, original.trialDays);
    });
  });

  group('SubscriptionTier.fromJson', () {
    test('parses a full payload', () {
      final tier = SubscriptionTier.fromJson({
        'id': 4,
        'name': 'Empire',
        'description': 'Multi-branch, global command',
        'monthly_price': 199,
        'yearly_price': 1990,
        'features': ['all'],
        'max_branches': -1,
        'max_staff': -1,
        'includes_analytics': true,
        'includes_premium_support': true,
        'includes_marketing_tools': true,
      });

      expect(tier.id, '4'); // numeric id stringified
      expect(tier.name, 'Empire');
      expect(tier.description, 'Multi-branch, global command');
      expect(tier.monthlyPrice, 199.0);
      expect(tier.monthlyPrice, isA<double>());
      expect(tier.yearlyPrice, 1990.0);
      expect(tier.features, ['all']);
      expect(tier.maxBranches, -1);
      expect(tier.maxStaff, -1);
      expect(tier.includesAnalytics, isTrue);
      expect(tier.includesPremiumSupport, isTrue);
      expect(tier.includesMarketingTools, isTrue);
    });

    test('applies defaults for a sparse payload', () {
      final tier = SubscriptionTier.fromJson({
        'name': 'Artisan',
        'description': 'Solo practitioner',
        'monthly_price': 0,
        'yearly_price': 0,
      });

      expect(tier.id, '');
      expect(tier.features, isEmpty);
      expect(tier.maxBranches, 1); // default
      expect(tier.maxStaff, 3); // default
      expect(tier.includesAnalytics, isFalse);
      expect(tier.includesPremiumSupport, isFalse);
      expect(tier.includesMarketingTools, isFalse);
    });

    test('toJson round-trips through fromJson', () {
      final original = SubscriptionTier.fromJson({
        'id': 't2',
        'name': 'Studio',
        'description': 'Small team',
        'monthly_price': 29.99,
        'yearly_price': 299.0,
        'features': ['booking'],
        'max_branches': 2,
        'max_staff': 6,
        'includes_analytics': true,
      });
      final reparsed = SubscriptionTier.fromJson(original.toJson());

      expect(reparsed.id, original.id);
      expect(reparsed.name, original.name);
      expect(reparsed.monthlyPrice, original.monthlyPrice);
      expect(reparsed.yearlyPrice, original.yearlyPrice);
      expect(reparsed.features, original.features);
      expect(reparsed.maxBranches, original.maxBranches);
      expect(reparsed.maxStaff, original.maxStaff);
      expect(reparsed.includesAnalytics, original.includesAnalytics);
      expect(reparsed.includesPremiumSupport, original.includesPremiumSupport);
      expect(reparsed.includesMarketingTools, original.includesMarketingTools);
    });

    test('yearly savings getters', () {
      const tier = SubscriptionTier(
        id: 't1',
        name: 'Studio',
        description: 'Small team',
        monthlyPrice: 30,
        yearlyPrice: 300,
        features: [],
        maxBranches: 2,
        maxStaff: 6,
      );

      expect(tier.yearlySavings, 60.0);
      expect(tier.yearlySavingsPercentage, closeTo(16.67, 0.01));
    });
  });
}
