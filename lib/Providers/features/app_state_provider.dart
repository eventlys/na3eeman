import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_roles.dart';
import '../base_provider.dart';
import '../../Helpers/analytics_helper.dart';
import '../../Helpers/cache_helper.dart';
import '../../Helpers/connectivity_helper.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/auth/expert_profile.dart';
import '../../Models/auth/owner_profile.dart';
import '../../Services/enums/gender.dart';
import '../../core/enums/app_enums.dart';
// import '../../Services/storage_service.dart';

class AppStateProvider extends BaseProvider {
  User? _user;
  ExpertProfile? _expertProfile;
  OwnerProfile? _ownerProfile;
  bool _isAuthenticated = false;
  static final AppStateProvider _instance = AppStateProvider._internal();
  factory AppStateProvider() => _instance;
  AppStateProvider._internal();

  // Add the missing properties/methods from UserProviderService
  bool get isLoggedIn => _isAuthenticated;
  bool get isExpert => _expertProfile != null;
  bool get isOwner => _ownerProfile != null;
  bool get isCustomer =>
      !isExpert && !isOwner && _isAuthenticated;

  // Initialize app state
  Future<void> initialize() async {
    setLoading(true);

    try {
      await CacheHelper().initialize();
      await ConnectivityHelper().initialize();
      await _loadCachedPreferences();
      _setAnalyticsProperties();
      await secureStorage.initialize();
      final userData = await secureStorage.getUserProfile();

      if (userData != null) {
        _user = userData;
        _isAuthenticated = true;
        await _loadUserProfiles();
      }
      setLoading(false);
    } catch (e) {
      setError('Failed to initialize user: $e');
      setLoading(false);
      AppLogger.error('User initialization failed', error: e);
    }
  }

  // Add profile update from UserProviderService
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      setLoading(true);

      if (_user == null) {
        throw Exception('No user logged in');
      }

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local user object
      _user = _user!.copyWith(
        firstName: updates['firstName'] ?? _user!.firstName,
        lastName: updates['lastName'] ?? _user!.firstName,
        phone: updates['phone'] ?? _user!.phone,
        location: updates['location'] ?? _user!.location,
        lat: updates['lat'] ?? _user!.lat,
        lng: updates['lng'] ?? _user!.lng,
      );

      // Save to local storage
      await secureStorage.saveUserData(_user!.toJson());

      setLoading(false);
      return true;
    } catch (e) {
      setError('Profile update failed: $e');
      setLoading(false);
      AppLogger.error('Profile update failed', error: e);
      return false;
    }
  }

  Future<void> _loadUserProfiles() async {
    if (_user == null) return;
    // Implementation from UserProviderService
  }

  // Current user state
  UserRole _userRole = UserRole.customer;
  Gender _userGender = Gender.male;
  bool _isLoggedIn = false;
  String? _userId;
  String? _userEmail;

  // Theme state
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // App state
  String? _currentRoute;
  Locale _currentLocale = const Locale('en', 'US');

  // Getters
  UserRole get userRole => _userRole;
  Gender get userGender => _userGender;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  String? get currentRoute => _currentRoute;
  Locale get currentLocale => _currentLocale;

  // User management
  void setUser({
    required UserRole role,
    required Gender gender,
    required String userId,
    required String email,
    bool shouldCache = true,
  }) {
    _userRole = role;
    _userGender = gender;
    _userId = userId;
    _userEmail = email;
    _isLoggedIn = true;

    if (shouldCache) {
      _cacheUserPreferences();
    }

    _setAnalyticsProperties();
    notifyListeners();
  }

  void logout() {
    _userRole = UserRole.customer;
    _userGender = Gender.male;
    _userId = null;
    _userEmail = null;
    _isLoggedIn = false;
    _clearCachedPreferences();
    notifyListeners();
  }

  // Theme management
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    _cacheThemePreferences();
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _isDarkMode = _themeMode == ThemeMode.dark;
    _cacheThemePreferences();
    notifyListeners();
  }

  // Navigation state
  void setCurrentRoute(String route) {
    _currentRoute = route;
  }

  // Locale management
  void setLocale(Locale locale) {
    _currentLocale = locale;
    _cacheLocalePreferences();
    notifyListeners();
  }

  // Permission checks
  bool canAccessSalonManagement() {
    return _userRole == UserRole.owner || 
           _userRole == UserRole.ownerExpert || 
           _userRole == UserRole.owner;
  }

  // Private methods
  Future<void> _loadCachedPreferences() async {
    try {
      final cachedUser = CacheHelper().retrieve('user_preferences');
      if (cachedUser != null) {
        _userRole = UserRoleExtension.fromString(
          cachedUser['role'] ?? 'customer',
        );
        _userGender = GenderExtension.fromString(
          cachedUser['gender'] ?? 'male',
        );
        _isLoggedIn = cachedUser['isLoggedIn'] ?? false;
        _userId = cachedUser['userId'];
        _userEmail = cachedUser['userEmail'];
      }

      final cachedTheme = CacheHelper().retrieve('theme_preferences');
      if (cachedTheme != null) {
        _themeMode = ThemeMode.values[cachedTheme['themeMode'] ?? 0];
        _isDarkMode = cachedTheme['isDarkMode'] ?? false;
      }

      final cachedLocale = CacheHelper().retrieve('locale_preferences');
      if (cachedLocale != null) {
        _currentLocale = Locale(
          cachedLocale['languageCode'] ?? 'en',
          cachedLocale['countryCode'] ?? 'US',
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _cacheUserPreferences() {
    CacheHelper().store('user_preferences', {
      'role': _userRole.value,
      'gender': _userGender.value,
      'isLoggedIn': _isLoggedIn,
      'userId': _userId,
      'userEmail': _userEmail,
    }, duration: const Duration(days: 30));
  }

  void _cacheThemePreferences() {
    CacheHelper().store('theme_preferences', {
      'themeMode': _themeMode.index,
      'isDarkMode': _isDarkMode,
    }, duration: const Duration(days: 30));
  }

  void _cacheLocalePreferences() {
    CacheHelper().store('locale_preferences', {
      'languageCode': _currentLocale.languageCode,
      'countryCode': _currentLocale.countryCode,
    }, duration: const Duration(days: 30));
  }

  void _clearCachedPreferences() {
    CacheHelper().remove('user_preferences');
  }

  void _setAnalyticsProperties() {
    if (_isLoggedIn && _userId != null) {
      AnalyticsHelper.setUserProperties(
        userId: int.tryParse(_userId!),
        userRole: _userRole.value,
        email: _userEmail,
      );
    }
  }
}
