import 'package:flutter/material.dart';
import '../Helpers/customized/points_tracker_helpers.dart';
import '../Helpers/logger.dart';
import '../Models/subscriptions/subscription.dart';
import '../Services/api/api_service.dart';
import '../Services/api/auth_service.dart';
import '../Services/enums/gender.dart';
import '../Services/enums/staff_role.dart';
import '../Services/repositories/auth_repository.dart';
import '../Services/storage_service.dart';
import '../Services/enums/user_role.dart';
import '../Services/enums/appointment_status.dart';
import '../Models/auth/user_model.dart';
import '../Models/auth/barber_profile.dart';
import '../Models/auth/owner_profile.dart';
import '../Models/appointments/shop_appointments_model.dart';
import '../Models/commerce/cart_model.dart';
import '../Models/shop/shop_service_model.dart';
import '../Models/shop/shops_model.dart';
import '../Models/shop/branch_model.dart';
import '../Models/inventory/inventory_item.dart';
import '../Models/staff/staff_member.dart';
import '../Models/staff/barber.dart';
import '../Models/subscriptions/subscription_model.dart';
import '../Models/settings/app_settings_model.dart';
import '../Helpers/analytics_helper.dart';
import '../Helpers/cache_helper.dart';
import '../Helpers/connectivity_helper.dart';

abstract class BaseProvider extends ChangeNotifier {
  final UnifiedStorageService  _secureStorage = UnifiedStorageService ();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clearError();
    super.dispose();
  }
}

class AppStateProvider extends BaseProvider {
  User? _user;
  BarberProfile? _barberProfile;
  OwnerProfile? _ownerProfile;
  bool _isAuthenticated = false;
  static final AppStateProvider _instance = AppStateProvider._internal();
  factory AppStateProvider() => _instance;
  AppStateProvider._internal();

    // Add the missing properties/methods from UserProviderService
  bool get isLoggedIn => _isAuthenticated;
  bool get isBarber => _barberProfile != null;
  bool get isOwner => _ownerProfile != null;

  // Initialize app state
  Future<void> initialize() async {
    setLoading(true);

    try {
      await CacheHelper().initialize();
      await ConnectivityHelper().initialize();
      await _loadCachedPreferences();
      _setAnalyticsProperties();
      await _secureStorage.initialize();
      final userData = await _secureStorage.getUserProfile();

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
        lastName: updates['lastName'] ?? _user!.lastName,
        phone: updates['phone'] ?? _user!.phone,
        location: updates['location'] ?? _user!.location,
        lat: updates['lat'] ?? _user!.lat,
        lng: updates['lng'] ?? _user!.lng,
      );

      // Save to local storage
      await _secureStorage.saveUserData(_user!.toJson());

      setLoading(false);
      return true;
    } catch (e) {
      setError('Profile update failed: $e');
      setLoading(false);
      AppLogger.error('Profile update failed', error: e);
      return false;
    }
  }

  // Keep existing methods and add missing ones...
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
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
  bool canAccessShopManagement() {
    return _userRole == UserRole.owner;
  }

  // bool canAccessAdminPanel() {
  //   return _userRole == UserRole.admin;
  // }

  // Private methods
  Future<void> _loadCachedPreferences() async {
    try {
      final cachedUser = CacheHelper().retrieve('user_preferences');
      if (cachedUser != null) {
        _userRole = UserRoleExtension.fromString(cachedUser['role'] ?? 'customer');
        _userGender = GenderExtension.fromString(cachedUser['gender'] ?? 'male');
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
        _currentLocale = Locale(cachedLocale['languageCode'] ?? 'en', cachedLocale['countryCode'] ?? 'US');
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

class AuthProvider extends BaseProvider {
  User? _user;
  BarberProfile? _barberProfile;
  OwnerProfile? _ownerProfile;
  bool _isAuthenticated = false;
  final AuthService _authService;

  // Initialize AuthService with required dependencies
  AuthProvider({AuthRepository? authRepository})
      : _authService = AuthService(authRepository ?? AuthRepository(ApiService()));

  // Getters
  User? get user => _user;
  BarberProfile? get barberProfile => _barberProfile;
  OwnerProfile? get ownerProfile => _ownerProfile;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userType => _user?.role;
  Gender? get userGender => _user?.gender;

  // Role-based convenience getters
  bool get isCustomer => _user?.isCustomer ?? false;
  bool get isBarber => _user?.isBarber ?? false;
  bool get isOwner => _user?.isOwner ?? false;

  // Profile completion status
  bool get hasBarberProfile => _barberProfile != null;
  bool get hasOwnerProfile => _ownerProfile != null;

  // Combined role checks
  bool get canManageShop => isOwner || (isBarber && _barberProfile?.hasAccess == true);
  bool get canManageAppointments => isBarber || isOwner;

  void _setCustomerUser() {
    _user = User(
      id: 1,
      email: 'customer@example.com',
      username: 'john_doe',
      firstName: 'John',
      lastName: 'Doe',
      role: UserRole.customer,
      gender: Gender.male,
      location: 'Amman, Jordan',
      lat: 31.963158,
      lng: 35.930359,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _setBarberUser() {
    _user = User(
      id: 2,
      email: 'barber@example.com',
      username: 'mike_barber',
      firstName: 'Mike',
      lastName: 'Johnson',
      role: UserRole.barber,
      gender: Gender.male,
      location: 'Amman, Jordan',
      lat: 31.963158,
      lng: 35.930359,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _barberProfile = BarberProfile(
      id: 1,
      barberId: 2,
      bio: 'Professional barber with 5 years experience',
      specialties: 'Haircuts, Beard Trims, Shaves',
      contactPhone: '+962791234567',
      hasAccess: true,
      avgRating: 4.5,
    );
  }

  void _setOwnerUser() {
    _user = User(
      id: 3,
      email: 'owner@example.com',
      username: 'sarah_owner',
      firstName: 'Sarah',
      lastName: 'Wilson',
      role: UserRole.owner,
      gender: Gender.female,
      location: 'Amman, Jordan',
      lat: 31.963158,
      lng: 35.930359,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _barberProfile = BarberProfile(
      id: 2,
      barberId: 3,
      bio: 'Shop owner and master barber',
      specialties: 'All Services',
      contactPhone: '+962791234568',
      hasAccess: true,
      avgRating: 4.8,
    );

    _ownerProfile = OwnerProfile(
      id: 1,
      barberProfileId: 2,
      isOwner: true,
      isWorker: true,
      isSubscribed: true,
      hasBranches: true,
      hasOffers: true,
      avgRating: 4.8,
      subscriptionTier: 'PREMIUM',
      subscriptionStartDate: DateTime.now().subtract(const Duration(days: 30)),
      subscriptionEndDate: DateTime.now().add(const Duration(days: 335)),
    );
  }

  // Enhanced login method combining both
  Future<bool> login({
    String? email,
    String? password,
    String? socialProvider,
    Map<String, dynamic>? socialData,
  })
  async {
    try {
      setLoading(true);
      clearError();

      if (socialProvider != null && socialData != null) {
        // Handle social login
        return await _handleSocialLogin(socialProvider, socialData);
      } else if (email != null && password != null) {
        // Handle email/password login
        return await _handleEmailLogin(email, password);
      } else {
        throw Exception('Invalid login parameters');
      }
    } catch (e) {
      setError('Login failed: $e');
      setLoading(false);
      AppLogger.error('Login failed', error: e);
      return false;
    }
  }

  Future<bool> _handleEmailLogin(String email, String password) async {
    try {
      // Use the actual AuthService for login
      final response = await _authService.login(email, password);

      if (response['success'] == true) {
        await _updateUserFromResponse(response);
        _isAuthenticated = true;

        // Save to local storage
        await _secureStorage.saveUserData(_user!.toJson());
        await _secureStorage.setAuthToken(response['token'] ?? 'jwt_token_${_user!.id}');

        setLoading(false);
        return true;
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Fallback to mock login for development
      AppLogger.warning('API login failed, using mock login: $e');
      return await _mockEmailLogin(email, password);
    }
  }

  // Mock login for development (fallback)
  Future<bool> _mockEmailLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication - replace with real implementation
    if (email.contains('owner')) {
      _setOwnerUser();
    } else if (email.contains('barber')) {
      _setBarberUser();
    } else {
      _setCustomerUser();
    }

    await _secureStorage.saveUserData(_user!.toJson());
    await _secureStorage.setAuthToken('mock_jwt_token_${_user!.id}');

    _isAuthenticated = true;
    return true;
  }

  Future<bool> _handleSocialLogin(String provider, Map<String, dynamic> socialData) async {
    try {
      // Use the unified social authentication
      final response = await _authService.handleSocialAuthentication(
        provider: provider,
        socialData: socialData,
      );

      if (response['success'] == true) {
        await _updateUserFromResponse(response);
        _isAuthenticated = true;

        // Save to local storage
        await _secureStorage.saveUserData(_user!.toJson());
        await _secureStorage.setAuthToken(response['token'] ?? 'social_token_${_user!.id}');

        setLoading(false);
        return true;
      } else {
        throw Exception(response['message'] ?? 'Social login failed');
      }
    } catch (e) {
      setError('Social login failed: $e');
      setLoading(false);
      return false;
    }
  }

  /// Update user data from API response
  Future<void> _updateUserFromResponse(Map<String, dynamic> response) async {
    final userData = response['user'];

    _user = User.fromJson(userData);

    // Update additional profiles based on role
    if (_user?.isBarber == true || _user?.isOwner == true) {
      _barberProfile = BarberProfile.fromJson(userData['barber_profile'] ?? {});
    }

    if (_user?.isOwner == true) {
      _ownerProfile = OwnerProfile.fromJson(userData['owner_profile'] ?? {});
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      setLoading(true);
      clearError();

      final result = await _authService.forgotPassword(email);

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('Failed to send OTP: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.'
      };
    }
  }

  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  })
  async {
    try {
      setLoading(true);
      clearError();

      final result = await _authService.verifyPasswordResetOtp(
        email: email,
        otp: otp,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('OTP verification failed: $e');
      return {
        'success': false,
        'message': 'OTP verification failed. Please try again.'
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  })
  async {
    try {
      setLoading(true);
      clearError();

      final result = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );

      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError('Password reset failed: $e');
      return {
        'success': false,
        'message': 'Password reset failed. Please try again.'
      };
    }
  }

  // Enhanced logout combining both
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      AppLogger.error('Logout service error: $e');
    } finally {
      _user = null;
      _barberProfile = null;
      _ownerProfile = null;
      _isAuthenticated = false;

      await _secureStorage.clearAuthData();
      clearError();
      notifyListeners();
    }
  }

  /// Check if user exists with social credentials
  Future<bool> checkSocialUserExists(String provider, String socialId) async {
    // Implement API call to check if social user exists
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Mock implementation
  }

  Future<void> updateProfile(User updatedUser) async {
    _user = updatedUser;
    notifyListeners();
  }

  bool hasAccessTo(String feature) {
    switch (feature) {
      case 'shop_management':
        return isOwner;
      case 'appointment_management':
        return isBarber || isOwner;
      case 'staff_management':
        return isOwner;
      default:
        return false;
    }
  }

  // Additional helper methods
  Future<bool> refreshUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Refresh user data failed: $e');
      return false;
    }
  }
}

class ShopProvider extends BaseProvider {
  List<Shop> _shops = [];
  List<Branch> _branches = [];
  List<ShopService> _services = [];
  List<InventoryItem> _inventory = [];
  Shop? _selectedShop;
  Branch? _selectedBranch;
  AuthProvider? _authProvider;

  // Getters
  List<Shop> get shops => _shops;
  List<Branch> get branches => _branches;
  List<ShopService> get services => _services;
  List<InventoryItem> get inventory => _inventory;
  Shop? get selectedShop => _selectedShop;
  Branch? get selectedBranch => _selectedBranch;

  List<Shop> get manageableShops {
    if (_authProvider?.isOwner != true) return [];
    return _shops.where((shop) => shop.ownerId == _authProvider?.user?.id).toList();
  }

  List<ShopService> get availableServices {
    if (_selectedShop != null) {
      return _services.where((service) => service.shopId == _selectedShop?.id).toList();
    }
    return _services;
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      loadShopData();
    }
  }

  Future<void> loadShopData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([
        loadShops(),
        loadBranches(),
        loadServices(),
        loadInventory(),
      ]);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadShops() async {
    await Future.delayed(const Duration(seconds: 1));
    _shops = [
      Shop(
        id: 1,
        shopName: 'Modern Cuts Barbershop',
        shopPhonNum: '+962791234567',
        shopDescription: 'Premium barbershop offering modern haircuts and grooming services',
        location: 'Abdali, Amman, Jordan',
        lat: 31.9539,
        lng: 35.9106,
        openingTime: '09:00',
        closingTime: '20:00',
        shopSeats: 5,
        shopStaff: 3,
        confirmedPhone: true,
        ownerId: _authProvider?.user?.id ?? 1,
        avgRating: 4.5,
      ),
    ];
  }

  Future<void> loadBranches() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _branches = [
      Branch(
        id: 1,
        name: 'Modern Cuts - Abdali',
        address: 'Abdali Mall, Level 2, Amman, Jordan',
        phone: '+962791234567',
        isOpen: true,
        todayAppointments: 15,
        todayRevenue: 450.0,
        manager: 'Sarah Wilson',
        monthlyRevenue: 13500.0,
        totalSales: 450,
        lowStockItems: 3,
        email: 'abdali@moderncuts.com',
        openingDate: DateTime(2023, 1, 15),
        totalEmployees: 5,
        shopId: 1,
        openingTime: '09:00',
        closingTime: '20:00',
        seats: 5,
        staffCount: 3,
        lat: 31.9539,
        lng: 35.9106,
      ),
    ];
  }

  Future<void> loadServices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _services = [
      ShopService(
        name: 'Classic Haircut',
        price: '25.00',
        duration: '30min',
        type: 'OPTION',
        id: 1,
        description: 'Traditional haircut with scissor and clipper work',
        shopId: 1,
      ),
    ];
  }

  Future<void> loadInventory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _inventory = [
      InventoryItem(
        id: '1',
        productId: 1,
        shopId: 1,
        quantityInStock: 15,
        lastUpdated: DateTime.now(),
        productName: 'Hair Styling Gel',
        productDescription: 'Premium hold styling gel',
        productPrice: 12.99,
      ),
    ];
  }

  Future<void> selectShop(Shop shop) async {
    _selectedShop = shop;
    _selectedBranch = null;
    await loadShopSpecificData();
    notifyListeners();
  }

  Future<void> selectBranch(Branch branch) async {
    _selectedBranch = branch;
    notifyListeners();
  }

  Future<void> loadShopSpecificData() async {
    if (_selectedShop != null) {
      await Future.wait([
        loadServices(),
        loadInventory(),
      ]);
    }
  }
}

class AppointmentProvider extends BaseProvider {
  final List<ShopAppointment> _appointments = [];
  AuthProvider? _authProvider;
  Map<String, dynamic>? _soonestAppointment;
  User? _user;

  User? get user => _user;
  // Getters
  List<ShopAppointment> get appointments => _appointments;
  Map<String, dynamic>? get soonestAppointment => _soonestAppointment;

  bool get hasError => error != null;

  List<ShopAppointment> get myAppointments {
    if (_authProvider?.isBarber == true) {
      return _appointments.where((appt) => appt.barberId == _authProvider?.user?.id).toList();
    } else if (_authProvider?.isCustomer == true) {
      return _appointments.where((appt) => appt.customerId == _authProvider?.user?.id).toList();
    }
    return _appointments;
  }


  Future<Map<String, dynamic>?> getSoonestAppointment(int customerId) async {
    await loadSoonestAppointment();
    return _soonestAppointment;
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      loadAppointments();
      loadSoonestAppointment();
    }
  }

  Future<void> loadAppointments() async {
    try {
      setLoading(true);
      clearError();

      await _mockLoadAppointments();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadSoonestAppointment() async {
    try {
      if (_authProvider?.user?.id == null) return;

      // Convert mock data to map format for the widget
      final mockAppointment = _mockSoonestAppointment();
      _soonestAppointment = mockAppointment;
      notifyListeners();
    } catch (e) {
      print('Error loading soonest appointment: $e');
    }
  }

  Future<void> rescheduleAppointment(String appointmentId, DateTime newStartTime, DateTime newEndTime) async {
    try {
      setLoading(true);

      // Update the soonest appointment if it matches the ID
      if (_soonestAppointment != null && _soonestAppointment!['id'] == appointmentId) {
        _soonestAppointment = Map<String, dynamic>.from(_soonestAppointment!)
          ..['dateTime'] = newStartTime.toIso8601String();
      }

      // Also update in the appointments list
      final appointmentIndex = _appointments.indexWhere((appt) => appt.id == appointmentId);
      if (appointmentIndex != -1) {
        final updatedAppointment = ShopAppointment(
          id: _appointments[appointmentIndex].id,
          customerId: _appointments[appointmentIndex].customerId,
          shopId: _appointments[appointmentIndex].shopId,
          barberId: _appointments[appointmentIndex].barberId,
          startTime: newStartTime,
          endTime: newEndTime,
          status: _appointments[appointmentIndex].status,
          createdAt: _appointments[appointmentIndex].createdAt,
          services: _appointments[appointmentIndex].services,
        );
        _appointments[appointmentIndex] = updatedAppointment;
      }

      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _mockLoadAppointments() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_authProvider?.isCustomer == true) {
      _loadCustomerAppointments();
    } else if (_authProvider?.isBarber == true) {
      _loadBarberAppointments();
    } else if (_authProvider?.isOwner == true) {
      _loadOwnerAppointments();
    }
  }

  Map<String, dynamic> _mockSoonestAppointment() {
    return {
      'id': '1',
      'customerId': _authProvider?.user?.id ?? 1,
      'shopId': 1,
      'barberId': 1,
      'dateTime': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      'totalPrice': 45.00,
      'shopName': 'Premium Barber Shop',
      'shopPhoneNumber': '+1234567890',
      'services': ['Haircut', 'Beard Trim', 'Shave'],
    };
  }

  void _loadCustomerAppointments() {
    _appointments.addAll([
      ShopAppointment(
        id: '2',
        customerId: _authProvider?.user?.id ?? 1,
        shopId: 1,
        barberId: 1,
        startTime: DateTime.now().add(const Duration(hours: 4)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  void _loadBarberAppointments() {
    _appointments.addAll([
      ShopAppointment(
        id: '1',
        customerId: 1,
        shopId: 1,
        barberId: _authProvider?.user?.id,
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  void _loadOwnerAppointments() {
    _appointments.addAll([
      ShopAppointment(
        id: '1',
        customerId: 1,
        shopId: 1,
        barberId: 2,
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        status: AppointmentStatus.scheduled,
        createdAt: DateTime.now(),
        services: [],
      ),
    ]);
  }

  Future<void> createAppointment(ShopAppointment appointment) async {
    try {
      setLoading(true);
      clearError();

      _appointments.add(appointment);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}


class PointsProvider with ChangeNotifier {
  final ApiService _loyaltyService;
  int _currentBalance = 0;
  bool _isLoading = false;

  PointsProvider(this._loyaltyService);

  int get currentBalance => _currentBalance;
  bool get isLoading => _isLoading;

  Future<void> loadBalance(int customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final balance = await _loyaltyService.getLoyaltyBalance(customerId);
      _currentBalance = balance.points;
    } catch (error) {
      // Handle error appropriately
      debugPrint('Error loading balance: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPoints({
    required int customerId,
    required PointsType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final points = _getPointsValue(type);
      final source = _getSourceString(type);

      final balance = await _loyaltyService.awardPoints(
        customerId: customerId,
        points: points,
        source: source,
        metadata: metadata,
      );

      _currentBalance = balance.points;
      notifyListeners();
    } catch (error) {
      debugPrint('Error adding points: $error');
      rethrow;
    }
  }

  Future<void> inviteFriend({
    required int customerId,
    String? friendName,
  }) async {
    final metadata = friendName != null ? {'friend_name': friendName} : null;

    await addPoints(
      customerId: customerId,
      type: PointsType.referral,
      metadata: metadata,
    );
  }

  Future<void> submitAppFeedback({
    required int customerId,
    String? feedback,
  }) async {
    final metadata = feedback != null ? {'feedback': feedback} : null;

    await addPoints(
      customerId: customerId,
      type: PointsType.other, // Using 'other' for app feedback
      metadata: metadata,
    );
  }

  Future<void> rateApp({
    required int customerId,
    int? rating,
  }) async {
    final metadata = rating != null ? {'rating': rating} : null;

    await addPoints(
      customerId: customerId,
      type: PointsType.reviewWrite, // Using reviewWrite for app rating
      metadata: metadata,
    );
  }

  // Helper methods to map PointsType to values
  int _getPointsValue(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return 50;
      case PointsType.reviewWrite:
        return 25;
      case PointsType.referral:
        return 100;
      case PointsType.rewardRedeem:
        return 0; // Redeeming costs points, doesn't add
      case PointsType.other:
        return 10;
    }
  }

  String _getSourceString(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return 'appointment_complete';
      case PointsType.reviewWrite:
        return 'review_write';
      case PointsType.referral:
        return 'referral';
      case PointsType.rewardRedeem:
        return 'reward_redeem';
      case PointsType.other:
        return 'other';
    }
  }
}

class FavoritesProvider extends BaseProvider {
  final ApiService _apiService = ApiService();
  final UnifiedStorageService _storageService = UnifiedStorageService();

  List<Map<String, dynamic>> _favoriteShops = [];
  bool _hasLoaded = false;

  // Getters
  List<Map<String, dynamic>> get favoriteShops => _favoriteShops;
  bool get hasLoaded => _hasLoaded;
  int get favoritesCount => _favoriteShops.length;

  // Check if a shop is favorited
  bool isShopFavorited(String shopId) {
    return _favoriteShops.any((shop) => shop['id'].toString() == shopId.toString());
  }

  // Load favorites from cache first, then API
  Future<void> loadFavorites({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;

    setLoading(true);
    clearError();

    try {
      // Try to load from cache first for instant UI
      await _loadFavoritesFromCache();

      // Then load from API to get latest data
      await _loadFavoritesFromApi();

      _hasLoaded = true;
    } catch (e) {
      setError('Failed to load favorites: $e');
      AppLogger.error('Failed to load favorites', error: e);
    } finally {
      setLoading(false);
    }
  }

  // Add shop to favorites
  Future<bool> addToFavorites(Map<String, dynamic> shopData) async {
    try {
      setLoading(true);

      final shopId = shopData['id'].toString();

      // Check if already favorited
      if (isShopFavorited(shopId)) {
        return true; // Already in favorites
      }

      // Add to local list immediately for instant UI feedback
      _favoriteShops.add(shopData);
      notifyListeners();

      // Save to cache
      await _saveFavoritesToCache();

      // Call API to add to favorites
      final response = await _apiService.addToFavorites(shopId);

      if (response['success'] == true) {
        AppLogger.info('Shop added to favorites', extra: {'shopId': shopId});
        return true;
      } else {
        // Rollback if API call failed
        _favoriteShops.removeWhere((shop) => shop['id'].toString() == shopId);
        notifyListeners();
        await _saveFavoritesToCache();
        throw Exception(response['message'] ?? 'Failed to add to favorites');
      }
    } catch (e) {
      // Rollback on error
      final shopId = shopData['id'].toString();
      _favoriteShops.removeWhere((shop) => shop['id'].toString() == shopId);
      notifyListeners();
      await _saveFavoritesToCache();

      setError('Failed to add to favorites: $e');
      AppLogger.error('Failed to add to favorites', error: e, extra: {'shopId': shopData['id']});
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Remove shop from favorites
  Future<bool> removeFromFavorites(String shopId) async {
    try {
      setLoading(true);

      // Remove from local list immediately for instant UI feedback
      final removedShop = _favoriteShops.firstWhere(
        (shop) => shop['id'].toString() == shopId,
        orElse: () => {},
      );

      _favoriteShops.removeWhere((shop) => shop['id'].toString() == shopId);
      notifyListeners();

      // Save to cache
      await _saveFavoritesToCache();

      // Call API to remove from favorites
      final response = await _apiService.removeFromFavorites(shopId);

      if (response['success'] == true) {
        AppLogger.info('Shop removed from favorites', extra: {'shopId': shopId});
        return true;
      } else {
        // Rollback if API call failed
        if (removedShop.isNotEmpty) {
          _favoriteShops.add(removedShop);
          notifyListeners();
          await _saveFavoritesToCache();
        }
        throw Exception(response['message'] ?? 'Failed to remove from favorites');
      }
    } catch (e) {
      setError('Failed to remove from favorites: $e');
      AppLogger.error('Failed to remove from favorites', error: e, extra: {'shopId': shopId});
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Map<String, dynamic> shopData) async {
    final shopId = shopData['id'].toString();

    if (isShopFavorited(shopId)) {
      return await removeFromFavorites(shopId);
    } else {
      return await addToFavorites(shopData);
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favoriteShops.clear();
    await _storageService.removePreference('user_favorites');
    notifyListeners();
  }

  // Private methods
  Future<void> _loadFavoritesFromCache() async {
    try {
      final cachedFavorites = await _storageService.getPreference('user_favorites');
      if (cachedFavorites != null && cachedFavorites is List) {
        _favoriteShops = List<Map<String, dynamic>>.from(cachedFavorites);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warning('Failed to load favorites from cache', error: e);
    }
  }

  Future<void> _loadFavoritesFromApi() async {
    try {
      final response = await _apiService.getUserFavorites();
      if (response['success'] == true) {
        final favorites = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _favoriteShops = favorites;
        await _saveFavoritesToCache();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warning('Failed to load favorites from API, using cache', error: e);
      // If API fails, we'll use the cached version loaded earlier
    }
  }

  Future<void> _saveFavoritesToCache() async {
    try {
      await _storageService.setPreference('user_favorites', _favoriteShops);
    } catch (e) {
      AppLogger.error('Failed to save favorites to cache', error: e);
    }
  }
}

class CartProvider extends BaseProvider {
  final List<CartItem> _items = [];
  AuthProvider? _authProvider;

  // Getters
  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isCartEmpty => _items.isEmpty;

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      clearCart();
    }
  }

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addService(ShopService service) {
    final cartItem = CartItem(
      id: '${service.type}_${service.id}',
      name: service.name,
      price: double.parse(service.price.replaceAll('\$', '')),
      type: service.type,
      itemId: service.id,
      duration: service.duration,
      description: service.description,
    );

    addItem(cartItem);
  }
}

class StaffProvider extends BaseProvider {
  List<StaffMember> _staff = [];
  List<Barber> _barbers = [];
  AuthProvider? _authProvider;
  StaffMember? _selectedStaff;

  // Getters
  List<StaffMember> get staff => _staff;
  List<Barber> get barbers => _barbers;
  StaffMember? get selectedStaff => _selectedStaff;

  List<StaffMember> get manageableStaff {
    if (_authProvider?.isOwner != true) return [];
    return _staff.where((member) => member.shopId == _authProvider?.ownerProfile?.barberProfileId).toList();
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true && _authProvider?.isOwner == true) {
      loadStaffData();
    }
  }

  Future<void> loadStaffData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([
        loadStaff(),
        loadBarbers(),
      ]);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadStaff() async {
    await Future.delayed(const Duration(seconds: 1));
    _staff = [
      StaffMember(
        id: '1',
        userId: 2,
        name: 'Mike Johnson',
        email: 'mike@barbershop.com',
        phone: '+962791234567',
        role: StaffRole.barber,
        joinDate: DateTime.now().subtract(const Duration(days: 365)),
        profileImage: 'https://example.com/mike.jpg',
        shopId: 1,
        isActive: true,
        hourlyRate: 25.0,
        specialties: ['Haircuts', 'Beard Trims', 'Shaves'],
        performanceMetrics: {
          'rating': 4.5,
          'totalAppointments': 150,
          'totalEarnings': 3750.0,
        },
      ),
    ];
  }

  Future<void> loadBarbers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _barbers = [
      Barber.fromUserAndProfile(
        user: User(
          id: 2,
          email: 'mike@barbershop.com',
          username: 'mike_barber',
          firstName: 'Mike',
          lastName: 'Johnson',
          role: UserRole.barber,
          gender: Gender.male,
          location: 'Amman, Jordan',
          lat: 31.963158,
          lng: 35.930359,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        profile: BarberProfile(
          id: 1,
          barberId: 2,
          bio: 'Professional barber with 5 years experience',
          specialties: 'Haircuts, Beard Trims, Shaves, Styling',
          contactPhone: '+962791234567',
          hasAccess: true,
          avgRating: 4.5,
        ),
        rating: 4.5,
        totalAppointments: 150,
        totalEarnings: 3750.0,
        specialties: ['Haircuts', 'Beard Trims', 'Shaves'],
        servicesCount: {
          'Haircut': 80,
          'Beard Trim': 45,
          'Shave': 25,
        },
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        hourlyRate: 25.0,
        shopId: 1,
      ),
    ];
  }

  void selectStaff(StaffMember? staff) {
    _selectedStaff = staff;
    notifyListeners();
  }
}

class SubscriptionProvider extends BaseProvider {
  List<SubscriptionPlan> _plans = [];
  Subscription? _currentSubscription;
  AuthProvider? _authProvider;

  // Getters
  List<SubscriptionPlan> get plans => _plans;
  Subscription? get currentSubscription => _currentSubscription;
  bool get hasActiveSubscription => _currentSubscription?.isActive == true;

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      loadSubscriptionData();
    }
  }

  Future<void> loadSubscriptionData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([
        loadPlans(),
        loadCurrentSubscription(),
      ]);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadPlans() async {
    await Future.delayed(const Duration(seconds: 1));
    _plans = [
      SubscriptionPlan(
        id: '1',
        name: 'Starter',
        description: 'Perfect for individual barbers starting out',
        price: 29.99,
        duration: 'MONTHLY',
        features: [
          '1 Branch',
          '3 Staff Members',
          'Basic Analytics',
          'Email Support',
          'Appointment Management',
        ],
        isPopular: false,
        maxBranches: 1,
        maxStaff: 3,
        analyticsEnabled: true,
        premiumSupport: false,
        trialDays: 7,
      ),
    ];
  }

  Future<void> loadCurrentSubscription() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_authProvider?.ownerProfile?.isSubscribed == true) {
      _currentSubscription = Subscription(
        id: 'sub_123456',
        customerId: _authProvider?.user?.id ?? 1,
        shopId: 1,
        planName: 'Professional Plan',
        subscriptionType: 'MONTHLY',
        price: 79.99,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 305)),
        status: 'Active',
        isActive: true,
        autoRenew: true,
        features: [
          '3 Branches',
          '10 Staff Members',
          'Advanced Analytics',
          'Priority Support',
          'Inventory Management',
          'Marketing Tools',
          'Custom Branding',
        ],
      );
    }
  }
}

class SettingsProvider extends BaseProvider {
  AppSettings _settings = AppSettings.defaultSettings;

  // Getters
  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  String get languageCode => _settings.languageCode;

  Future<void> loadSettings() async {
    try {
      setLoading(true);
      clearError();

      await _mockLoadSettings();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _mockLoadSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      setLoading(true);
      clearError();

      _settings = newSettings;
      await _mockSaveSettings();

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _mockSaveSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> toggleDarkMode() async {
    final newSettings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await updateSettings(newSettings);
  }
}
