import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/core/config/subscription_config.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/core/services/feature_access_service.dart';

void main() {
  group('FeatureAccessService.checkAccess', () {
    test('Artisan can access basic inventory', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.artisan,
          feature: FeatureKey.inventoryBasic,
        ),
        isTrue,
      );
    });

    test('Artisan cannot access advanced reports', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.artisan,
          feature: FeatureKey.reportsAdvanced,
        ),
        isFalse,
      );
    });

    test('Studio can access loyalty system', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.studio,
          feature: FeatureKey.loyaltySystem,
        ),
        isTrue,
      );
    });

    test('Studio cannot access multi-branch', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.studio,
          feature: FeatureKey.multiBranch,
        ),
        isFalse,
      );
    });

    test('Elite can access resource booking', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.resourceBooking,
        ),
        isTrue,
      );
    });

    test('Elite cannot access warehouse inventory', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.inventoryWarehouse,
        ),
        isFalse,
      );
    });

    test('Empire can access all features', () {
      for (final feature in FeatureKey.values) {
        // No assertion — just ensure no exception thrown
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.empire,
          feature: feature,
          isSubscriptionActive: true,
        );
      }
    });

    test('Expired subscription falls back to artisan free tier', () {
      // Advanced reports should be blocked on expired Elite
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.reportsAdvanced,
          isSubscriptionActive: false,
        ),
        isFalse,
      );

      // But basic timeline should still be accessible
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.widgetTodayTimeline,
          isSubscriptionActive: false,
        ),
        isTrue,
      );
    });

    test('Higher tier satisfies lower tier feature checks (cumulative)', () {
      // Empire includes all Studio features
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.empire,
          feature: FeatureKey.loyaltySystem,
        ),
        isTrue,
      );
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.empire,
          feature: FeatureKey.inventoryBasic,
        ),
        isTrue,
      );
    });
  });

  group('FeatureAccessService.canAddStaff', () {
    test('Artisan blocks adding second staff', () {
      expect(
        FeatureAccessService.canAddStaff(
          tier: OwnerSubscriptionTier.artisan,
          currentStaffCount: 1,
        ),
        isFalse,
      );
    });

    test('Artisan allows first staff member', () {
      expect(
        FeatureAccessService.canAddStaff(
          tier: OwnerSubscriptionTier.artisan,
          currentStaffCount: 0,
        ),
        isTrue,
      );
    });

    test('Studio allows up to 6 staff', () {
      expect(
        FeatureAccessService.canAddStaff(
          tier: OwnerSubscriptionTier.studio,
          currentStaffCount: 5,
        ),
        isTrue,
      );
      expect(
        FeatureAccessService.canAddStaff(
          tier: OwnerSubscriptionTier.studio,
          currentStaffCount: 6,
        ),
        isFalse,
      );
    });

    test('Empire allows unlimited staff', () {
      expect(
        FeatureAccessService.canAddStaff(
          tier: OwnerSubscriptionTier.empire,
          currentStaffCount: 999,
        ),
        isTrue,
      );
    });

    test('Expired subscription blocks adding staff', () {
      expect(
        FeatureAccessService.canAddStaff(
          tier: OwnerSubscriptionTier.studio,
          currentStaffCount: 0,
          isSubscriptionActive: false,
        ),
        isFalse,
      );
    });
  });

  group('FeatureAccessService.getDenialReason', () {
    test('Returns null when access is granted', () {
      expect(
        FeatureAccessService.getDenialReason(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.resourceBooking,
        ),
        isNull,
      );
    });

    test('Returns tierInsufficient when tier too low', () {
      final reason = FeatureAccessService.getDenialReason(
        tier: OwnerSubscriptionTier.artisan,
        feature: FeatureKey.loyaltySystem,
      );
      expect(reason, isNotNull);
      expect(reason!.isTierTooLow, isTrue);
      expect(reason.requiredTier, equals(OwnerSubscriptionTier.studio));
    });

    test('Returns subscriptionExpired when plan lapsed', () {
      final reason = FeatureAccessService.getDenialReason(
        tier: OwnerSubscriptionTier.elite,
        feature: FeatureKey.reportsAdvanced,
        isSubscriptionActive: false,
      );
      expect(reason, isNotNull);
      expect(reason!.isExpiredPlan, isTrue);
    });
  });

  group('SubscriptionConfig', () {
    test('Artisan maxStaff is 1', () {
      expect(SubscriptionConfig.maxStaffFor(OwnerSubscriptionTier.artisan), 1);
    });

    test('Studio maxStaff is 6', () {
      expect(SubscriptionConfig.maxStaffFor(OwnerSubscriptionTier.studio), 6);
    });

    test('Elite maxStaff is -1 (unlimited)', () {
      expect(SubscriptionConfig.maxStaffFor(OwnerSubscriptionTier.elite), -1);
    });

    test('forTier returns correct TierConfig', () {
      final config = SubscriptionConfig.forTier(OwnerSubscriptionTier.empire);
      expect(config.tier, equals(OwnerSubscriptionTier.empire));
      expect(config.isUnlimitedStaff, isTrue);
      expect(config.isUnlimitedBranches, isTrue);
    });

    test('upgradeOptions returns tiers above current', () {
      final upgrades = SubscriptionConfig.upgradeOptions(
        OwnerSubscriptionTier.studio,
      );
      expect(
        upgrades,
        containsAll([
          OwnerSubscriptionTier.elite,
          OwnerSubscriptionTier.empire,
        ]),
      );
      expect(upgrades, isNot(contains(OwnerSubscriptionTier.artisan)));
      expect(upgrades, isNot(contains(OwnerSubscriptionTier.studio)));
    });

    test('dashboardWidgets returns non-empty list for all tiers', () {
      for (final tier in OwnerSubscriptionTier.values) {
        final widgets = SubscriptionConfig.forTier(tier).dashboardWidgets;
        expect(
          widgets,
          isNotEmpty,
          reason: 'Tier ${tier.value} should have dashboard widgets',
        );
      }
    });
  });

  group('OwnerSubscriptionTier enum', () {
    test('fromString handles legacy values', () {
      expect(
        OwnerSubscriptionTierExtension.fromString('PREMIUM'),
        OwnerSubscriptionTier.elite,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('ENTERPRISE'),
        OwnerSubscriptionTier.empire,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('BASIC'),
        OwnerSubscriptionTier.artisan,
      );
    });

    test('meets() rank comparison works', () {
      expect(
        OwnerSubscriptionTier.empire.meets(OwnerSubscriptionTier.artisan),
        isTrue,
      );
      expect(
        OwnerSubscriptionTier.artisan.meets(OwnerSubscriptionTier.empire),
        isFalse,
      );
      expect(
        OwnerSubscriptionTier.studio.meets(OwnerSubscriptionTier.studio),
        isTrue,
      );
    });
  });
}
