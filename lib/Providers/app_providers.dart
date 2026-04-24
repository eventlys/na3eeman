import 'package:flutter/material.dart';
import '../Packages/Core/constants/app_roles.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/colors.dart';
import '../core/enums/app_enums.dart';
import '../Packages/Core/utils/helpers/themes_helpers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME PROVIDER
// Manages brightness (light/dark).
// Persists via shared_preferences if available; gracefully falls back.
// ─────────────────────────────────────────────────────────────────────────────

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({
    Brightness brightness = Brightness.light,
    UserGender gender = UserGender.male,
  }) : _brightness = brightness,
       _gender = gender;

  Brightness _brightness;
  UserGender _gender;

  Brightness get brightness => _brightness;
  bool get isDark => _brightness == Brightness.dark;
  UserGender get gender => _gender;

  /// The active ThemeData.
  ThemeData get currentTheme => AppTheme.getGenderTheme(_gender, isDark);

  void setGender(UserGender gender) {
    if (_gender == gender) return;
    _gender = gender;
    notifyListeners();
  }

  /// Switch between light and dark mode.
  void toggleBrightness() {
    _brightness = isDark ? Brightness.light : Brightness.dark;
    notifyListeners();
  }

  /// Explicitly set brightness.
  void setBrightness(Brightness brightness) {
    if (_brightness == brightness) return;
    _brightness = brightness;
    notifyListeners();
  }

  /// Convenience: returns the active primary colour for use outside BuildContext.
  Color get accentColor => AppColors.blue;
}

// ─────────────────────────────────────────────────────────────────────────────
// RBAC PROVIDER
// Holds the current user's role and subscription tier.
// Provides permission checking helpers consumed by widgets.
// ─────────────────────────────────────────────────────────────────────────────

class RBACProvider extends ChangeNotifier {
  RBACProvider({
    UserRole role = UserRole.customer,
    SubscriptionTier tier = SubscriptionTier.basic,
  }) : _role = role,
       _tier = tier;

  UserRole _role;
  SubscriptionTier _tier;

  UserRole get role => _role;
  SubscriptionTier get tier => _tier;

  /// Update when a user logs in.
  void setUser({required UserRole role, required SubscriptionTier tier}) {
    _role = role;
    _tier = tier;
    notifyListeners();
  }

  /// Reset on logout.
  void clear() {
    _role = UserRole.customer;
    _tier = SubscriptionTier.basic;
    notifyListeners();
  }

  // ── Permission helpers ────────────────────────────────────────────────────

  bool can(AppPermission permission) => _role.can(permission);

  bool hasSubscription(SubscriptionTier required) => _tier.meets(required);

  bool get isSuperAdmin => _role == UserRole.superAdmin;
  bool get isOwner => _role == UserRole.owner || _role == UserRole.ownerEmployee || _role == UserRole.ownerOwner;
  bool get isManager => _role == UserRole.manager;
  bool get isStaff => _role.isStaff;
  bool get isCustomer => _role == UserRole.customer;

  /// Returns true if the user can see any admin UI at all.
  bool get canAccessAdmin =>
      _role == UserRole.superAdmin ||
      _role == UserRole.owner ||
      _role == UserRole.ownerEmployee ||
      _role == UserRole.ownerOwner ||
      _role == UserRole.manager;
}
