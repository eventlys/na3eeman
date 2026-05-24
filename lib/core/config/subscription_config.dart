import '../enums/owner_enums.dart';

/// Central, immutable configuration for all subscription tiers.
///
/// This is the **single source of truth** for:
/// - Staff limits per tier
/// - Enabled features per tier
/// - Dashboard widgets per tier
/// - Branch limits per tier
///
/// UI and business logic MUST NOT hardcode tier capabilities inline.
/// Instead, call [SubscriptionConfig.forTier] or use [FeatureAccessService].
class SubscriptionConfig {
  SubscriptionConfig._(); // purely static — do not instantiate

  // ---------------------------------------------------------------------------
  // TIER DEFINITIONS
  // ---------------------------------------------------------------------------

  static final Map<OwnerSubscriptionTier, TierConfig> _configs = {
    OwnerSubscriptionTier.artisan: const TierConfig(
      tier: OwnerSubscriptionTier.artisan,
      displayName: 'Artisan',
      tagline: 'Solo practitioner, personal tools',
      monthlyPrice: 0, // free / base
      yearlyPrice: 0,
      trialDays: 14,
      maxStaff: 1,
      maxBranches: 1,
      enabledFeatures: {
        FeatureKey.staffLimit,
        FeatureKey.viewStaffList,
        FeatureKey.inventoryBasic,
        FeatureKey.widgetTodayTimeline,
        FeatureKey.widgetDailyEarnings,
        FeatureKey.widgetKitMaintenance,
        FeatureKey.widgetQuickBook,
        FeatureKey.reportsBasic,
        FeatureKey.paymentManagement,
      },
      dashboardWidgets: [
        DashboardWidgetKey.todayTimeline,
        DashboardWidgetKey.dailyEarnings,
        DashboardWidgetKey.kitMaintenance,
        DashboardWidgetKey.quickBook,
        DashboardWidgetKey.revenueOverview,
      ],
    ),

    OwnerSubscriptionTier.studio: const TierConfig(
      tier: OwnerSubscriptionTier.studio,
      displayName: 'Studio Sync',
      tagline: 'Small team salon, grow together',
      monthlyPrice: 29.99,
      yearlyPrice: 287.99, // 20% off
      trialDays: 7,
      maxStaff: 6,
      maxBranches: 1,
      enabledFeatures: {
        // All Artisan features +
        FeatureKey.staffLimit,
        FeatureKey.addStaff,
        FeatureKey.removeStaff,
        FeatureKey.viewStaffList,
        FeatureKey.inventoryBasic,
        FeatureKey.inventoryRetail,
        FeatureKey.reportsBasic,
        FeatureKey.loyaltySystem,
        FeatureKey.retailSales,
        FeatureKey.practitionerModeToggle,
        FeatureKey.widgetTodayTimeline,
        FeatureKey.widgetDailyEarnings,
        FeatureKey.widgetKitMaintenance,
        FeatureKey.widgetQuickBook,
        FeatureKey.widgetTeamLeaderboard,
        FeatureKey.widgetRetailSnapshot,
        FeatureKey.widgetLowStockAlert,
      },
      dashboardWidgets: [
        DashboardWidgetKey.teamLeaderboard,
        DashboardWidgetKey.retailSnapshot,
        DashboardWidgetKey.lowStockAlert,
        DashboardWidgetKey.revenueOverview,
        DashboardWidgetKey.voucherSystem,
      ],
    ),

    OwnerSubscriptionTier.elite: const TierConfig(
      tier: OwnerSubscriptionTier.elite,
      displayName: 'Elite Wellness',
      tagline: 'Full-service clinic, unlimited scale',
      monthlyPrice: 79.99,
      yearlyPrice: 767.99, // 20% off
      trialDays: 7,
      maxStaff: -1, // -1 = unlimited
      maxBranches: 3,
      enabledFeatures: {
        // All Studio features +
        FeatureKey.staffLimit,
        FeatureKey.addStaff,
        FeatureKey.removeStaff,
        FeatureKey.viewStaffList,
        FeatureKey.inventoryBasic,
        FeatureKey.inventoryRetail,
        FeatureKey.inventoryConsumables,
        FeatureKey.reportsBasic,
        FeatureKey.reportsAdvanced,
        FeatureKey.loyaltySystem,
        FeatureKey.retailSales,
        FeatureKey.resourceBooking,
        FeatureKey.complianceForms,
        FeatureKey.whatsappIntegration,
        FeatureKey.commissionCalculator,
        FeatureKey.profitAndLoss,
        FeatureKey.consumableWasteMeter,
        FeatureKey.practitionerModeToggle,
        FeatureKey.widgetTodayTimeline,
        FeatureKey.widgetDailyEarnings,
        FeatureKey.widgetKitMaintenance,
        FeatureKey.widgetQuickBook,
        FeatureKey.widgetTeamLeaderboard,
        FeatureKey.widgetRetailSnapshot,
        FeatureKey.widgetLowStockAlert,
        FeatureKey.widgetResourceOccupancy,
        FeatureKey.widgetCommissionCalc,
        FeatureKey.widgetComplianceTracker,
      },
      dashboardWidgets: [
        DashboardWidgetKey.resourceOccupancy,
        DashboardWidgetKey.consumableWasteMeter,
        DashboardWidgetKey.commissionCalculator,
        DashboardWidgetKey.complianceTracker,
      ],
    ),

    OwnerSubscriptionTier.empire: const TierConfig(
      tier: OwnerSubscriptionTier.empire,
      displayName: 'Empire',
      tagline: 'Multi-branch, global command',
      monthlyPrice: 199.99,
      yearlyPrice: 1919.99, // 20% off
      trialDays: 0,
      maxStaff: -1, // unlimited
      maxBranches: -1, // unlimited
      enabledFeatures: {
        // All Elite features +
        FeatureKey.staffLimit,
        FeatureKey.addStaff,
        FeatureKey.removeStaff,
        FeatureKey.viewStaffList,
        FeatureKey.inventoryBasic,
        FeatureKey.inventoryRetail,
        FeatureKey.inventoryConsumables,
        FeatureKey.inventoryWarehouse,
        FeatureKey.reportsBasic,
        FeatureKey.reportsAdvanced,
        FeatureKey.reportsGlobal,
        FeatureKey.loyaltySystem,
        FeatureKey.multiBranch,
        FeatureKey.interBranchTransfers,
        FeatureKey.resourceBooking,
        FeatureKey.complianceForms,
        FeatureKey.retailSales,
        FeatureKey.whatsappIntegration,
        FeatureKey.commissionCalculator,
        FeatureKey.profitAndLoss,
        FeatureKey.globalAnalytics,
        FeatureKey.consumableWasteMeter,
        FeatureKey.practitionerModeToggle,
        FeatureKey.widgetTodayTimeline,
        FeatureKey.widgetDailyEarnings,
        FeatureKey.widgetKitMaintenance,
        FeatureKey.widgetQuickBook,
        FeatureKey.widgetTeamLeaderboard,
        FeatureKey.widgetRetailSnapshot,
        FeatureKey.widgetLowStockAlert,
        FeatureKey.widgetResourceOccupancy,
        FeatureKey.widgetCommissionCalc,
        FeatureKey.widgetComplianceTracker,
        FeatureKey.widgetBranchMap,
        FeatureKey.widgetGlobalStock,
        FeatureKey.widgetProfitAndLoss,
      },
      dashboardWidgets: [
        DashboardWidgetKey.branchComparisonMap,
        DashboardWidgetKey.globalStockValue,
        DashboardWidgetKey.interBranchTransfers,
        DashboardWidgetKey.unifiedProfitLoss,
      ],
    ),
  };

  // ---------------------------------------------------------------------------
  // PUBLIC API
  // ---------------------------------------------------------------------------

  /// Get the full config for a given tier.
  static TierConfig forTier(OwnerSubscriptionTier tier) {
    return _configs[tier]!;
  }

  /// Returns true when [tier] has access to [feature].
  static bool tierHasFeature(OwnerSubscriptionTier tier, FeatureKey feature) {
    return _configs[tier]!.enabledFeatures.contains(feature);
  }

  /// Returns the max staff count for a tier. Returns `-1` for unlimited.
  static int maxStaffFor(OwnerSubscriptionTier tier) {
    return _configs[tier]!.maxStaff;
  }

  /// Returns true if staff is still under the tier limit.
  /// Always returns true when [maxStaff] == -1 (unlimited).
  static bool canAddStaff(OwnerSubscriptionTier tier, int currentStaffCount) {
    final max = maxStaffFor(tier);
    if (max == -1) return true;
    return currentStaffCount < max;
  }

  /// All tiers ordered by rank (lowest first).
  static List<TierConfig> get allTiers =>
      OwnerSubscriptionTier.values.map(forTier).toList();

  /// Upgrade path: tiers above [current].
  static List<OwnerSubscriptionTier> upgradeOptions(
    OwnerSubscriptionTier current,
  ) {
    return OwnerSubscriptionTier.values
        .where((t) => t.index > current.index)
        .toList();
  }
}

// ---------------------------------------------------------------------------
// DASHBOARD WIDGET KEYS
// ---------------------------------------------------------------------------

/// Identifies individual dashboard widget slots.
/// Used to drive modular, tier-aware widget rendering.
enum DashboardWidgetKey {
  // Artisan
  todayTimeline,
  dailyEarnings,
  kitMaintenance,
  quickBook,

  // Studio
  teamLeaderboard,
  retailSnapshot,
  lowStockAlert,
  switchViewToggle,

  // Elite
  resourceOccupancy,
  consumableWasteMeter,
  commissionCalculator,
  complianceTracker,

  // Empire
  branchComparisonMap,
  globalStockValue,
  interBranchTransfers,
  unifiedProfitLoss,

  // Revenue & AI
  revenueOverview,
  voucherSystem,
  noShowRiskAlert,
}

// ---------------------------------------------------------------------------
// TIER CONFIG MODEL
// ---------------------------------------------------------------------------

/// Immutable data object representing all capabilities of one subscription tier.
class TierConfig {
  final OwnerSubscriptionTier tier;
  final String displayName;
  final String tagline;
  final double monthlyPrice;
  final double yearlyPrice;
  final int trialDays;

  /// Max staff members. `-1` = unlimited.
  final int maxStaff;

  /// Max branches. `-1` = unlimited.
  final int maxBranches;

  /// Set of features enabled for this tier.
  final Set<FeatureKey> enabledFeatures;

  /// Dashboard widget slots to show on the home screen.
  final List<DashboardWidgetKey> dashboardWidgets;

  const TierConfig({
    required this.tier,
    required this.displayName,
    required this.tagline,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.trialDays,
    required this.maxStaff,
    required this.maxBranches,
    required this.enabledFeatures,
    required this.dashboardWidgets,
  });

  bool hasFeature(FeatureKey key) => enabledFeatures.contains(key);

  bool get isUnlimitedStaff => maxStaff == -1;
  bool get isUnlimitedBranches => maxBranches == -1;
  bool get hasTrial => trialDays > 0;

  String get staffLimitLabel =>
      maxStaff == -1 ? 'Unlimited' : '$maxStaff staff';

  String get branchLimitLabel =>
      maxBranches == -1 ? 'Unlimited' : '$maxBranches branches';

  double get yearlySavings => (monthlyPrice * 12) - yearlyPrice;

  double get yearlySavingsPercentage =>
      monthlyPrice > 0 ? (yearlySavings / (monthlyPrice * 12)) * 100 : 0;
}
