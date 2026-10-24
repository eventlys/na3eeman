import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/core/config/subscription_config.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/core/services/feature_access_service.dart';

// Characterization tests for lib/core/services/feature_access_service.dart.
// These extend (not duplicate) test/owner/feature_access_service_test.dart,
// which covers basic checkAccess, canAddStaff, getDenialReason basics,
// SubscriptionConfig, and enum legacy parsing.
void main() {
  group('FeatureAccessService.checkAccess — full tier x feature matrix', () {
    test('active tier access mirrors SubscriptionConfig for every feature', () {
      for (final tier in OwnerSubscriptionTier.values) {
        for (final feature in FeatureKey.values) {
          expect(
            FeatureAccessService.checkAccess(tier: tier, feature: feature),
            SubscriptionConfig.forTier(tier).enabledFeatures.contains(feature),
            reason: 'tier=${tier.value} feature=$feature',
          );
        }
      }
    });

    test('some FeatureKeys are enabled on NO tier, not even Empire', () {
      // These keys exist in the enum but appear in no TierConfig.
      const orphanFeatures = {
        FeatureKey.adminCreateOwner,
        FeatureKey.aiNoShowRisk,
        FeatureKey.vouchers,
        FeatureKey.marketingAds,
        FeatureKey.analyticsElite,
        FeatureKey.ownerControls,
        FeatureKey.financialControls,
      };
      for (final feature in orphanFeatures) {
        expect(
          FeatureAccessService.checkAccess(
            tier: OwnerSubscriptionTier.empire,
            feature: feature,
          ),
          isFalse,
          reason: 'Empire unexpectedly has $feature',
        );
      }
    });

    test('Artisan includes paymentManagement and reportsBasic', () {
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.artisan,
          feature: FeatureKey.paymentManagement,
        ),
        isTrue,
      );
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.artisan,
          feature: FeatureKey.reportsBasic,
        ),
        isTrue,
      );
    });

    test('Studio cannot add multi-branch, Elite can (up to 3 branches)', () {
      // multiBranch the *feature* is Empire-only even though Elite has
      // maxBranches == 3 — the feature flag and the numeric limit differ.
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.multiBranch,
        ),
        isFalse,
      );
      expect(
        FeatureAccessService.checkAccess(
          tier: OwnerSubscriptionTier.empire,
          feature: FeatureKey.multiBranch,
        ),
        isTrue,
      );
    });
  });

  group('FeatureAccessService.checkAccess — expired subscription', () {
    // The graceful set hardcoded in _artisanOnlyAccess.
    const gracefulFeatures = {
      FeatureKey.viewStaffList,
      FeatureKey.inventoryBasic,
      FeatureKey.widgetTodayTimeline,
      FeatureKey.widgetDailyEarnings,
      FeatureKey.widgetQuickBook,
    };

    test('exactly the 5 graceful features survive expiry', () {
      for (final feature in FeatureKey.values) {
        expect(
          FeatureAccessService.checkAccess(
            tier: OwnerSubscriptionTier.empire,
            feature: feature,
            isSubscriptionActive: false,
          ),
          gracefulFeatures.contains(feature),
          reason: 'expired feature=$feature',
        );
      }
    });

    test('expiry result is identical for every tier (tier is ignored)', () {
      for (final tier in OwnerSubscriptionTier.values) {
        for (final feature in FeatureKey.values) {
          expect(
            FeatureAccessService.checkAccess(
              tier: tier,
              feature: feature,
              isSubscriptionActive: false,
            ),
            gracefulFeatures.contains(feature),
            reason: 'tier=${tier.value} feature=$feature',
          );
        }
      }
    });

    test('Artisan-only features that are NOT graceful are lost on expiry', () {
      // Quirk: reportsBasic, paymentManagement and widgetKitMaintenance are
      // Artisan-tier features but are not in the graceful set.
      for (final feature in {
        FeatureKey.reportsBasic,
        FeatureKey.paymentManagement,
        FeatureKey.widgetKitMaintenance,
        FeatureKey.staffLimit,
      }) {
        expect(
          FeatureAccessService.checkAccess(
            tier: OwnerSubscriptionTier.artisan,
            feature: feature,
            isSubscriptionActive: false,
          ),
          isFalse,
          reason: '$feature should be blocked on expired Artisan',
        );
      }
    });
  });

  group('FeatureAccessService.canAddBranch', () {
    test('Artisan allows the first branch only', () {
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.artisan,
          currentBranchCount: 0,
        ),
        isTrue,
      );
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.artisan,
          currentBranchCount: 1,
        ),
        isFalse,
      );
    });

    test('Studio is also capped at 1 branch', () {
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.studio,
          currentBranchCount: 0,
        ),
        isTrue,
      );
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.studio,
          currentBranchCount: 1,
        ),
        isFalse,
      );
    });

    test('Elite allows up to 3 branches', () {
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.elite,
          currentBranchCount: 2,
        ),
        isTrue,
      );
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.elite,
          currentBranchCount: 3,
        ),
        isFalse,
      );
    });

    test('Empire allows unlimited branches', () {
      expect(
        FeatureAccessService.canAddBranch(
          tier: OwnerSubscriptionTier.empire,
          currentBranchCount: 9999,
        ),
        isTrue,
      );
    });

    test('expired subscription blocks adding branches on every tier', () {
      for (final tier in OwnerSubscriptionTier.values) {
        expect(
          FeatureAccessService.canAddBranch(
            tier: tier,
            currentBranchCount: 0,
            isSubscriptionActive: false,
          ),
          isFalse,
          reason: 'tier=${tier.value}',
        );
      }
    });
  });

  group('FeatureAccessService.accessibleFeatures', () {
    test('filters to the tier feature set when active', () {
      final result = FeatureAccessService.accessibleFeatures(
        tier: OwnerSubscriptionTier.studio,
        isSubscriptionActive: true,
        features: {
          FeatureKey.loyaltySystem,
          FeatureKey.reportsAdvanced,
          FeatureKey.inventoryBasic,
          FeatureKey.multiBranch,
        },
      );
      expect(
        result,
        equals({FeatureKey.loyaltySystem, FeatureKey.inventoryBasic}),
      );
    });

    test('keeps only graceful features when expired', () {
      final result = FeatureAccessService.accessibleFeatures(
        tier: OwnerSubscriptionTier.empire,
        isSubscriptionActive: false,
        features: {
          FeatureKey.reportsGlobal,
          FeatureKey.widgetQuickBook,
          FeatureKey.inventoryBasic,
        },
      );
      expect(
        result,
        equals({FeatureKey.widgetQuickBook, FeatureKey.inventoryBasic}),
      );
    });

    test('empty input returns empty set', () {
      expect(
        FeatureAccessService.accessibleFeatures(
          tier: OwnerSubscriptionTier.elite,
          isSubscriptionActive: true,
          features: const {},
        ),
        isEmpty,
      );
    });
  });

  group('FeatureAccessService.dashboardWidgetsFor', () {
    test('active tier returns its configured widget list verbatim', () {
      for (final tier in OwnerSubscriptionTier.values) {
        expect(
          FeatureAccessService.dashboardWidgetsFor(tier: tier),
          equals(SubscriptionConfig.forTier(tier).dashboardWidgets),
          reason: 'tier=${tier.value}',
        );
      }
    });

    test('exact widget lists per tier', () {
      expect(
        FeatureAccessService.dashboardWidgetsFor(
          tier: OwnerSubscriptionTier.artisan,
        ),
        equals([
          DashboardWidgetKey.todayTimeline,
          DashboardWidgetKey.dailyEarnings,
          DashboardWidgetKey.kitMaintenance,
          DashboardWidgetKey.quickBook,
          DashboardWidgetKey.revenueOverview,
        ]),
      );
      expect(
        FeatureAccessService.dashboardWidgetsFor(
          tier: OwnerSubscriptionTier.empire,
        ),
        equals([
          DashboardWidgetKey.branchComparisonMap,
          DashboardWidgetKey.globalStockValue,
          DashboardWidgetKey.interBranchTransfers,
          DashboardWidgetKey.unifiedProfitLoss,
        ]),
      );
    });

    test('expired subscription always returns the Artisan widget list', () {
      final artisanWidgets = SubscriptionConfig.forTier(
        OwnerSubscriptionTier.artisan,
      ).dashboardWidgets;
      for (final tier in OwnerSubscriptionTier.values) {
        expect(
          FeatureAccessService.dashboardWidgetsFor(
            tier: tier,
            isSubscriptionActive: false,
          ),
          equals(artisanWidgets),
          reason: 'tier=${tier.value}',
        );
      }
    });
  });

  group('FeatureAccessService.getDenialReason — messages and quirks', () {
    test('tierInsufficient message embeds the minimum tier display name', () {
      final reason = FeatureAccessService.getDenialReason(
        tier: OwnerSubscriptionTier.studio,
        feature: FeatureKey.resourceBooking,
      );
      expect(reason, isNotNull);
      expect(reason!.reason, DenialReasonType.tierInsufficient);
      expect(reason.requiredTier, OwnerSubscriptionTier.elite);
      expect(
        reason.message,
        'This feature requires the Elite Wellness plan or above.',
      );
    });

    test(
      'feature on no tier yields null requiredTier and "higher" wording',
      () {
        final reason = FeatureAccessService.getDenialReason(
          tier: OwnerSubscriptionTier.empire,
          feature: FeatureKey.adminCreateOwner,
        );
        expect(reason, isNotNull);
        expect(reason!.isTierTooLow, isTrue);
        expect(reason.requiredTier, isNull);
        expect(
          reason.message,
          'This feature requires the higher plan or above.',
        );
      },
    );

    test('expired denial uses the CURRENT tier as requiredTier', () {
      // Quirk: requiredTier is set to the passed tier, not a minimum tier.
      final reason = FeatureAccessService.getDenialReason(
        tier: OwnerSubscriptionTier.studio,
        feature: FeatureKey.loyaltySystem,
        isSubscriptionActive: false,
      );
      expect(reason, isNotNull);
      expect(reason!.reason, DenialReasonType.subscriptionExpired);
      expect(reason.requiredTier, OwnerSubscriptionTier.studio);
      expect(
        reason.message,
        'Your subscription has expired. Renew to regain access to this feature.',
      );
    });

    test(
      'expired denial is returned even for graceful features that checkAccess allows',
      () {
        // Quirk: checkAccess(expired, widgetTodayTimeline) == true, yet
        // getDenialReason still reports subscriptionExpired for it.
        expect(
          FeatureAccessService.checkAccess(
            tier: OwnerSubscriptionTier.elite,
            feature: FeatureKey.widgetTodayTimeline,
            isSubscriptionActive: false,
          ),
          isTrue,
        );
        final reason = FeatureAccessService.getDenialReason(
          tier: OwnerSubscriptionTier.elite,
          feature: FeatureKey.widgetTodayTimeline,
          isSubscriptionActive: false,
        );
        expect(reason, isNotNull);
        expect(reason!.isExpiredPlan, isTrue);
      },
    );

    test('minimum tier lookup scans tiers from lowest rank upward', () {
      // reportsAdvanced is Elite+Empire, so minimum is Elite.
      final reason = FeatureAccessService.getDenialReason(
        tier: OwnerSubscriptionTier.artisan,
        feature: FeatureKey.reportsAdvanced,
      );
      expect(reason!.requiredTier, OwnerSubscriptionTier.elite);
    });

    test('FeatureDenialReason convenience getters', () {
      const expired = FeatureDenialReason(
        feature: FeatureKey.loyaltySystem,
        reason: DenialReasonType.subscriptionExpired,
        message: 'x',
      );
      expect(expired.isExpiredPlan, isTrue);
      expect(expired.isTierTooLow, isFalse);

      const lowTier = FeatureDenialReason(
        feature: FeatureKey.loyaltySystem,
        reason: DenialReasonType.tierInsufficient,
        message: 'x',
      );
      expect(lowTier.isExpiredPlan, isFalse);
      expect(lowTier.isTierTooLow, isTrue);
    });
  });

  group('OwnerTierAccessExtension.can', () {
    test('delegates to checkAccess with the same semantics', () {
      expect(
        OwnerSubscriptionTier.elite.can(FeatureKey.resourceBooking),
        isTrue,
      );
      expect(
        OwnerSubscriptionTier.studio.can(FeatureKey.resourceBooking),
        isFalse,
      );
      expect(
        OwnerSubscriptionTier.elite.can(
          FeatureKey.resourceBooking,
          isSubscriptionActive: false,
        ),
        isFalse,
      );
      expect(
        OwnerSubscriptionTier.elite.can(
          FeatureKey.widgetQuickBook,
          isSubscriptionActive: false,
        ),
        isTrue,
      );
    });
  });

  group('OwnerSubscriptionTier.meets — adjacent tier boundaries', () {
    test('every tier meets itself and all lower tiers', () {
      final tiers = OwnerSubscriptionTier.values;
      for (var i = 0; i < tiers.length; i++) {
        for (var j = 0; j < tiers.length; j++) {
          expect(
            tiers[i].meets(tiers[j]),
            i >= j,
            reason: '${tiers[i]}.meets(${tiers[j]})',
          );
        }
      }
    });

    test('adjacent boundaries are strict in the upward direction', () {
      expect(
        OwnerSubscriptionTier.artisan.meets(OwnerSubscriptionTier.studio),
        isFalse,
      );
      expect(
        OwnerSubscriptionTier.studio.meets(OwnerSubscriptionTier.elite),
        isFalse,
      );
      expect(
        OwnerSubscriptionTier.elite.meets(OwnerSubscriptionTier.empire),
        isFalse,
      );
      expect(
        OwnerSubscriptionTier.studio.meets(OwnerSubscriptionTier.artisan),
        isTrue,
      );
      expect(
        OwnerSubscriptionTier.elite.meets(OwnerSubscriptionTier.studio),
        isTrue,
      );
      expect(
        OwnerSubscriptionTier.empire.meets(OwnerSubscriptionTier.elite),
        isTrue,
      );
    });
  });

  group('OwnerSubscriptionTierExtension.fromString — edge cases', () {
    test('null and empty strings fall back to artisan', () {
      expect(
        OwnerSubscriptionTierExtension.fromString(null),
        OwnerSubscriptionTier.artisan,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString(''),
        OwnerSubscriptionTier.artisan,
      );
    });

    test('unknown strings fall back to artisan', () {
      expect(
        OwnerSubscriptionTierExtension.fromString('PLATINUM'),
        OwnerSubscriptionTier.artisan,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('not-a-tier'),
        OwnerSubscriptionTier.artisan,
      );
    });

    test('parsing is case-insensitive', () {
      expect(
        OwnerSubscriptionTierExtension.fromString('studio'),
        OwnerSubscriptionTier.studio,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('eLiTe'),
        OwnerSubscriptionTier.elite,
      );
    });

    test('all documented legacy aliases resolve', () {
      expect(
        OwnerSubscriptionTierExtension.fromString('STARTER'),
        OwnerSubscriptionTier.artisan,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('GOLD'),
        OwnerSubscriptionTier.studio,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('PROFESSIONAL'),
        OwnerSubscriptionTier.studio,
      );
      expect(
        OwnerSubscriptionTierExtension.fromString('BUSINESS'),
        OwnerSubscriptionTier.empire,
      );
    });

    test('value and displayName mappings', () {
      expect(OwnerSubscriptionTier.artisan.value, 'ARTISAN');
      expect(OwnerSubscriptionTier.studio.value, 'STUDIO');
      expect(OwnerSubscriptionTier.elite.value, 'ELITE');
      expect(OwnerSubscriptionTier.empire.value, 'EMPIRE');
      expect(OwnerSubscriptionTier.artisan.displayName, 'Artisan');
      expect(OwnerSubscriptionTier.studio.displayName, 'Studio Sync');
      expect(OwnerSubscriptionTier.elite.displayName, 'Elite Wellness');
      expect(OwnerSubscriptionTier.empire.displayName, 'Empire');
    });
  });
}
