import '../enums/owner_enums.dart';
import '../config/subscription_config.dart';

/// Global service for checking feature access based on subscription tier.
///
/// ## Usage
/// ```dart
/// // In widgets:
/// if (FeatureAccessService.checkAccess(
///       tier: ownerProvider.tier,
///       feature: FeatureKey.reportsAdvanced,
///     )) {
///   // show widget
/// }
///
/// // Convenience extension on OwnerSubscriptionTier:
/// if (tier.can(FeatureKey.reportsAdvanced)) { ... }
/// ```
///
/// **Rules**:
/// 1. UI must NEVER compare tier strings directly.
/// 2. API calls should pass through `checkAccess` before firing.
/// 3. Expired subscriptions are handled by [isSubscriptionEffective].
class FeatureAccessService {
  FeatureAccessService._(); // static-only

  // ---------------------------------------------------------------------------
  // PRIMARY GATE
  // ---------------------------------------------------------------------------

  /// Returns `true` if [tier] unlocks [feature] AND the subscription is active.
  ///
  /// [isSubscriptionActive] — pass `OwnerProfile.isSubscriptionActive`.
  /// When `false` the user is on expired/lapsed plan; only free features pass.
  static bool checkAccess({
    required OwnerSubscriptionTier tier,
    required FeatureKey feature,
    bool isSubscriptionActive = true,
  }) {
    if (!isSubscriptionActive) {
      // Expired subscriptions: only features available on the base Artisan tier
      // are accessible — prevents "forever premium" after lapse.
      return _artisanOnlyAccess(feature);
    }
    return SubscriptionConfig.tierHasFeature(tier, feature);
  }

  /// Returns true for features that remain accessible even on a lapsed plan.
  static bool _artisanOnlyAccess(FeatureKey feature) {
    const gracefulFeatures = {
      FeatureKey.viewStaffList, // read-only, no harm
      FeatureKey.inventoryBasic, // view only
      FeatureKey.widgetTodayTimeline,
      FeatureKey.widgetDailyEarnings,
      FeatureKey.widgetQuickBook,
    };
    return gracefulFeatures.contains(feature);
  }

  // ---------------------------------------------------------------------------
  // STAFF LIMIT GATE
  // ---------------------------------------------------------------------------

  /// Returns `true` if the owner can add another staff member.
  static bool canAddStaff({
    required OwnerSubscriptionTier tier,
    required int currentStaffCount,
    bool isSubscriptionActive = true,
  }) {
    if (!isSubscriptionActive) return false;
    return SubscriptionConfig.canAddStaff(tier, currentStaffCount);
  }

  // ---------------------------------------------------------------------------
  // BRANCH LIMIT GATE
  // ---------------------------------------------------------------------------

  /// Returns `true` if the owner can add another branch.
  static bool canAddBranch({
    required OwnerSubscriptionTier tier,
    required int currentBranchCount,
    bool isSubscriptionActive = true,
  }) {
    if (!isSubscriptionActive) return false;
    final max = SubscriptionConfig.forTier(tier).maxBranches;
    if (max == -1) return true;
    return currentBranchCount < max;
  }

  // ---------------------------------------------------------------------------
  // DENIAL REASON
  // ---------------------------------------------------------------------------

  /// Returns a human-readable denial reason when access is blocked,
  /// or `null` when access is granted.
  ///
  /// Use this to drive upgrade prompts / tooltips.
  static FeatureDenialReason? getDenialReason({
    required OwnerSubscriptionTier tier,
    required FeatureKey feature,
    bool isSubscriptionActive = true,
  }) {
    if (!isSubscriptionActive) {
      return FeatureDenialReason(
        feature: feature,
        reason: DenialReasonType.subscriptionExpired,
        message:
            'Your subscription has expired. Renew to regain access to this feature.',
        requiredTier: tier,
      );
    }

    if (!SubscriptionConfig.tierHasFeature(tier, feature)) {
      // Find the lowest tier that supports this feature
      final minTier = _minimumTierFor(feature);

      return FeatureDenialReason(
        feature: feature,
        reason: DenialReasonType.tierInsufficient,
        message:
            'This feature requires the ${minTier?.displayName ?? 'higher'} plan or above.',
        requiredTier: minTier,
      );
    }

    return null; // access granted
  }

  static OwnerSubscriptionTier? _minimumTierFor(FeatureKey feature) {
    for (final tier in OwnerSubscriptionTier.values) {
      if (SubscriptionConfig.tierHasFeature(tier, feature)) return tier;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // BULK CHECK (dashboard widget filtering)
  // ---------------------------------------------------------------------------

  /// Filters a list of feature keys, returning only those the tier can access.
  static Set<FeatureKey> accessibleFeatures({
    required OwnerSubscriptionTier tier,
    required bool isSubscriptionActive,
    required Set<FeatureKey> features,
  }) {
    return features
        .where(
          (f) => checkAccess(
            tier: tier,
            feature: f,
            isSubscriptionActive: isSubscriptionActive,
          ),
        )
        .toSet();
  }

  /// Returns the list of [DashboardWidgetKey]s the owner should see.
  static List<DashboardWidgetKey> dashboardWidgetsFor({
    required OwnerSubscriptionTier tier,
    bool isSubscriptionActive = true,
  }) {
    if (!isSubscriptionActive) {
      // Expired: show Artisan widgets only
      return SubscriptionConfig.forTier(
        OwnerSubscriptionTier.artisan,
      ).dashboardWidgets;
    }
    return SubscriptionConfig.forTier(tier).dashboardWidgets;
  }
}

// ---------------------------------------------------------------------------
// DENIAL REASON MODEL
// ---------------------------------------------------------------------------

enum DenialReasonType { subscriptionExpired, tierInsufficient }

class FeatureDenialReason {
  final FeatureKey feature;
  final DenialReasonType reason;
  final String message;

  /// The minimum tier required to unlock this feature.
  final OwnerSubscriptionTier? requiredTier;

  const FeatureDenialReason({
    required this.feature,
    required this.reason,
    required this.message,
    this.requiredTier,
  });

  bool get isExpiredPlan => reason == DenialReasonType.subscriptionExpired;
  bool get isTierTooLow => reason == DenialReasonType.tierInsufficient;
}

// ---------------------------------------------------------------------------
// CONVENIENCE EXTENSION
// ---------------------------------------------------------------------------

extension OwnerTierAccessExtension on OwnerSubscriptionTier {
  /// Shorthand for `FeatureAccessService.checkAccess`.
  bool can(FeatureKey feature, {bool isSubscriptionActive = true}) {
    return FeatureAccessService.checkAccess(
      tier: this,
      feature: feature,
      isSubscriptionActive: isSubscriptionActive,
    );
  }
}
