/// Owner-specific enums for the na3eeman subscription / feature-gating system.
///
/// These enums replace the previous loose `String` / mismatched `SubscriptionTier`
/// values scattered across the codebase with a single, type-safe source of truth.

// ---------------------------------------------------------------------------
// OWNER SUBSCRIPTION TIER
// ---------------------------------------------------------------------------

/// The four commercial tiers available to Owner accounts.
///
/// Order matters: `index` is used for rank comparisons.
enum OwnerSubscriptionTier {
  /// Solo practitioner — max 1 staff, no reports. (was "ARTISAN")
  artisan,

  /// Small-team salon — up to 6 staff, loyalty + basic reports. (was "STUDIO")
  studio,

  /// Full-service spa/clinic — unlimited staff, rooms, medical forms. (was "ELITE")
  elite,

  /// Multi-branch enterprise — warehouse, global analytics. (was "EMPIRE")
  empire,
}

extension OwnerSubscriptionTierExtension on OwnerSubscriptionTier {
  /// Numeric rank. Higher = more capable.
  int get rank => index;

  /// Returns true if this tier satisfies [required].
  bool meets(OwnerSubscriptionTier required) => rank >= required.rank;

  /// Backend / storage string value.
  String get value {
    switch (this) {
      case OwnerSubscriptionTier.artisan:
        return 'ARTISAN';
      case OwnerSubscriptionTier.studio:
        return 'STUDIO';
      case OwnerSubscriptionTier.elite:
        return 'ELITE';
      case OwnerSubscriptionTier.empire:
        return 'EMPIRE';
    }
  }

  /// Human-readable marketing name.
  String get displayName {
    switch (this) {
      case OwnerSubscriptionTier.artisan:
        return 'Artisan';
      case OwnerSubscriptionTier.studio:
        return 'Studio Sync';
      case OwnerSubscriptionTier.elite:
        return 'Elite Wellness';
      case OwnerSubscriptionTier.empire:
        return 'Empire';
    }
  }

  /// Parse from backend string (case-insensitive, legacy-safe).
  static OwnerSubscriptionTier fromString(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ARTISAN':
      case 'BASIC':
      case 'STARTER':
        return OwnerSubscriptionTier.artisan;
      case 'STUDIO':
      case 'GOLD':
      case 'PROFESSIONAL':
        return OwnerSubscriptionTier.studio;
      case 'ELITE':
      case 'PREMIUM':
        return OwnerSubscriptionTier.elite;
      case 'EMPIRE':
      case 'ENTERPRISE':
      case 'BUSINESS':
        return OwnerSubscriptionTier.empire;
      default:
        return OwnerSubscriptionTier.artisan;
    }
  }
}

// ---------------------------------------------------------------------------
// OWNER TYPE
// ---------------------------------------------------------------------------

/// How the owner relates to their own salon operations.
enum OwnerType {
  /// Owner who also works as a practitioner (e.g., barber-owner).
  employeeOwner,

  /// Owner who manages but does not perform services.
  pureOwner,

  /// Independent solo practitioner — typically Artisan tier.
  soloFreelancer,
}

extension OwnerTypeExtension on OwnerType {
  String get value {
    switch (this) {
      case OwnerType.employeeOwner:
        return 'EMPLOYEE_OWNER';
      case OwnerType.pureOwner:
        return 'PURE_OWNER';
      case OwnerType.soloFreelancer:
        return 'SOLO_FREELANCER';
    }
  }

  String get displayName {
    switch (this) {
      case OwnerType.employeeOwner:
        return 'Owner-Practitioner';
      case OwnerType.pureOwner:
        return 'Manager-Owner';
      case OwnerType.soloFreelancer:
        return 'Solo Freelancer';
    }
  }

  static OwnerType fromString(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'EMPLOYEE_OWNER':
        return OwnerType.employeeOwner;
      case 'PURE_OWNER':
        return OwnerType.pureOwner;
      case 'SOLO_FREELANCER':
        return OwnerType.soloFreelancer;
      default:
        return OwnerType.employeeOwner;
    }
  }
}

// ---------------------------------------------------------------------------
// OWNER MODE (Practitioner Toggle)
// ---------------------------------------------------------------------------

/// Toggleable operating mode for owners who are also practitioners.
///
/// - [managerMode]     → full business visibility (default).
/// - [practitionerMode] → shows only the owner's own appointments/tips/notes.
enum OwnerMode { managerMode, practitionerMode }

extension OwnerModeExtension on OwnerMode {
  bool get isManagerMode => this == OwnerMode.managerMode;
  bool get isPractitionerMode => this == OwnerMode.practitionerMode;

  OwnerMode get toggled =>
      this == OwnerMode.managerMode
          ? OwnerMode.practitionerMode
          : OwnerMode.managerMode;

  String get displayLabel =>
      this == OwnerMode.managerMode ? 'Manager Mode' : 'My Work Mode';

  String get description =>
      this == OwnerMode.managerMode
          ? 'Full business view'
          : 'My appointments only';
}

// ---------------------------------------------------------------------------
// FEATURE KEY
// ---------------------------------------------------------------------------

/// Exhaustive list of every feature that can be gated by subscription tier.
///
/// **USAGE**: Always use `FeatureAccessService.checkAccess(FeatureKey.xxx)`.
/// Never check tier strings directly in UI code.
enum FeatureKey {
  // ── Staff ──────────────────────────────────────────────────────────────
  staffLimit,         // enforces maxStaff per tier
  addStaff,
  removeStaff,
  viewStaffList,

  // ── Inventory ──────────────────────────────────────────────────────────
  inventoryBasic,
  inventoryRetail,
  inventoryConsumables,
  inventoryWarehouse,  // Empire only

  // ── Reports ────────────────────────────────────────────────────────────
  reportsBasic,
  reportsAdvanced,
  reportsGlobal,       // Empire only

  // ── Loyalty ────────────────────────────────────────────────────────────
  loyaltySystem,

  // ── Branches ───────────────────────────────────────────────────────────
  multiBranch,
  interBranchTransfers,

  // ── Resources ──────────────────────────────────────────────────────────
  resourceBooking,     // rooms, chairs
  complianceForms,     // medical / health forms (Elite+)

  // ── Commerce / Integrations ────────────────────────────────────────────
  retailSales,
  whatsappIntegration,
  commissionCalculator,

  // ── Analytics / Finance ────────────────────────────────────────────────
  profitAndLoss,
  globalAnalytics,
  consumableWasteMeter,

  // ── Dashboard Widgets ──────────────────────────────────────────────────
  widgetTodayTimeline,
  widgetDailyEarnings,
  widgetKitMaintenance,
  widgetQuickBook,
  widgetTeamLeaderboard,
  widgetRetailSnapshot,
  widgetLowStockAlert,
  widgetResourceOccupancy,
  widgetCommissionCalc,
  widgetComplianceTracker,
  widgetBranchMap,
  widgetGlobalStock,
  widgetProfitAndLoss,

  // ── Practitioner Mode ──────────────────────────────────────────────────
  practitionerModeToggle,

  // ── Admin ──────────────────────────────────────────────────────────────
  adminCreateOwner,

  // ── Revenue & AI (NEW) ──────────────────────────────────────────────────
  paymentManagement,   // Configure deposits, CliQ, etc.
  aiNoShowRisk,        // Predict no-show probability
  vouchers,            // Prepaid packages & gift cards
}
