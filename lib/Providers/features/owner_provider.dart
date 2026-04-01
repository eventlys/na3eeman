import '../base_provider.dart';
import '../../Services/api/api_service.dart';
import 'auth_provider.dart';
import 'package:na3eeman/Models/auth/owner_profile.dart';
import '../../core/enums/owner_enums.dart';
import '../../core/config/subscription_config.dart';
import '../../core/services/feature_access_service.dart';
import '../../Helpers/logger.dart';

/// Dedicated state provider for the Owner (Provider) module.
///
/// Responsibilities:
/// - Holds current [OwnerProfile] and derives tier/mode state
/// - Exposes [checkAccess] so widgets never inspect tier directly
/// - Manages [OwnerMode] toggle (Manager ↔ Practitioner)
/// - Validates staff/branch limits before mutations
/// - Listens to [AuthProvider] via proxy to stay in sync
///
/// ## Widget Usage
/// ```dart
/// final owner = context.watch<OwnerProvider>();
///
/// if (owner.canAccess(FeatureKey.reportsAdvanced)) {
///   // show advanced reports widget
/// }
/// ```
class OwnerProvider extends BaseProvider {
  OwnerProfile? _profile;
  OwnerMode _mode = OwnerMode.managerMode;
  AuthProvider? _auth;
  final ApiService _apiService = ApiService();
  List<dynamic> _leaderboard = [];
  Map<String, dynamic> _retailSnapshot = {};
  Map<String, dynamic> _dailyEarnings = {};
  bool _isAnalyticsLoading = false;

  // ---------------------------------------------------------------------------
  // GETTERS — Profile
  // ---------------------------------------------------------------------------

  OwnerProfile? get profile => _profile;
  bool get hasProfile => _profile != null;

  /// The typed subscription tier (safe fallback: artisan).
  OwnerSubscriptionTier get tier =>
      _profile?.effectiveTier ?? OwnerSubscriptionTier.artisan;

  /// True if the subscription (or trial) is currently active.
  bool get isSubscriptionActive => _profile?.isSubscriptionActive ?? false;

  /// The ID of the shop currently being managed.
  int? get activeShopId => _profile?.shopId;

  bool get isTrial => _profile?.isTrial ?? false;
  int? get daysRemaining => _profile?.daysRemaining;
  bool get isRenewalWarning => _profile?.isRenewalWarning ?? false;

  List<dynamic> get leaderboard => _leaderboard;
  Map<String, dynamic> get retailSnapshot => _retailSnapshot;
  Map<String, dynamic> get dailyEarnings => _dailyEarnings;
  bool get isAnalyticsLoading => _isAnalyticsLoading;

  /// The full [TierConfig] for the current effective tier.
  TierConfig get tierConfig => SubscriptionConfig.forTier(tier);

  String get tierDisplayName => tierConfig.displayName;
  int get maxStaff => _profile?.maxStaff ?? 1;
  bool get hasUnlimitedStaff => _profile?.hasUnlimitedStaff ?? false;

  /// True when the owner is also a practitioner (can toggle mode).
  bool get isPractitioner => _profile?.isPractitioner ?? false;

  // ---------------------------------------------------------------------------
  // GETTERS — Practitioner Mode
  // ---------------------------------------------------------------------------

  OwnerMode get mode => _mode;
  bool get isManagerMode => _mode.isManagerMode;
  bool get isPractitionerMode => _mode.isPractitionerMode;

  // ---------------------------------------------------------------------------
  // AUTH PROXY
  // ---------------------------------------------------------------------------

  /// Called by [ChangeNotifierProxyProvider] when [AuthProvider] updates.
  void updateAuth(AuthProvider auth) {
    _auth = auth;

    if (auth.isAuthenticated && auth.isOwner && auth.ownerProfile != null) {
      _syncFromAuthProfile(auth.ownerProfile!);
    } else {
      _profile = null;
      _mode = OwnerMode.managerMode;
      notifyListeners();
    }
  }

  void _syncFromAuthProfile(OwnerProfile profile) {
    final changed = _profile != profile;
    _profile = profile;

    // Artisan owners who are not practitioners can't enter Practitioner Mode
    if (!profile.isPractitioner) {
      _mode = OwnerMode.managerMode;
    }

    if (changed) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // FEATURE ACCESS
  // ---------------------------------------------------------------------------

  /// Primary gate for all features. Use this in every widget/action.
  bool canAccess(FeatureKey feature) {
    return FeatureAccessService.checkAccess(
      tier: tier,
      feature: feature,
      isSubscriptionActive: isSubscriptionActive,
    );
  }

  /// Returns a [FeatureDenialReason] or null if access is granted.
  /// Drive upgrade prompts from this.
  FeatureDenialReason? denialReason(FeatureKey feature) {
    return FeatureAccessService.getDenialReason(
      tier: tier,
      feature: feature,
      isSubscriptionActive: isSubscriptionActive,
    );
  }

  // ---------------------------------------------------------------------------
  // STAFF / BRANCH LIMITS
  // ---------------------------------------------------------------------------

  /// Checks if one more staff can be hired.
  bool canAddStaff(int currentCount) {
    return FeatureAccessService.canAddStaff(
      tier: tier,
      currentStaffCount: currentCount,
      isSubscriptionActive: isSubscriptionActive,
    );
  }

  /// Checks if one more branch can be opened.
  bool canAddBranch(int currentCount) {
    return FeatureAccessService.canAddBranch(
      tier: tier,
      currentBranchCount: currentCount,
      isSubscriptionActive: isSubscriptionActive,
    );
  }

  // ---------------------------------------------------------------------------
  // PRACTITIONER MODE TOGGLE
  // ---------------------------------------------------------------------------

  /// Toggles between Manager Mode and Practitioner Mode.
  /// No-op when the owner is not a practitioner (pureOwner).
  void toggleMode() {
    if (!isPractitioner) {
      AppLogger.warning('toggleMode called but owner is not a practitioner');
      return;
    }
    if (!canAccess(FeatureKey.practitionerModeToggle)) {
      AppLogger.warning('Practitioner mode requires Studio tier or above');
      return;
    }
    _mode = _mode.toggled;
    AppLogger.info('OwnerMode switched to ${_mode.displayLabel}');
    notifyListeners();
  }

  /// Force mode to Manager. Useful on logout or subscription expiry.
  void resetToManagerMode() {
    if (_mode != OwnerMode.managerMode) {
      _mode = OwnerMode.managerMode;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // SUBSCRIPTION HELPERS
  // ---------------------------------------------------------------------------

  /// Call when the backend confirms subscription upgrade.
  void onSubscriptionUpgraded(OwnerSubscriptionTier newTier) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      subscriptionTier: newTier,
      isSubscribed: true,
    );
    notifyListeners();
    AppLogger.info('Subscription upgraded to ${newTier.displayName}');
  }

  /// Call when subscription confirmed expired (API 402 / webhook).
  void onSubscriptionExpired() {
    if (_profile == null) return;
    _profile = _profile!.copyWith(isSubscribed: false);
    resetToManagerMode();
    notifyListeners();
    AppLogger.warning('Subscription expired — reverted to Artisan access');
  }

  // ---------------------------------------------------------------------------
  // ANALYTICS & DASHBOARD DATA
  // ---------------------------------------------------------------------------

  Future<void> loadDashboardAnalytics() async {
    if (activeShopId == null || _auth == null) return;
    
    _isAnalyticsLoading = true;
    notifyListeners();
    
    try {
      final results = await Future.wait([
        _apiService.getTeamLeaderboard(activeShopId!),
        _apiService.getRetailSnapshot(activeShopId!),
        _apiService.getDailyEarnings(activeShopId!),
      ]);
      
      _leaderboard = results[0] as List<dynamic>;
      _retailSnapshot = results[1] as Map<String, dynamic>;
      _dailyEarnings = results[2] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Error fetching dashboard analytics: $e');
    } finally {
      _isAnalyticsLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // DASHBOARD WIDGETS
  // ---------------------------------------------------------------------------

  /// Ordered list of [DashboardWidgetKey]s the owner dashboard should render.
  List<DashboardWidgetKey> get dashboardWidgets {
    return FeatureAccessService.dashboardWidgetsFor(
      tier: tier,
      isSubscriptionActive: isSubscriptionActive,
    );
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    _profile = null;
    _mode = OwnerMode.managerMode;
    notifyListeners();
  }
}
