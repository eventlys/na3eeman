// lib/Services/storage/unified_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../Helpers/logger.dart';
import '../../Models/appointments/booking_group_model.dart';
import '../../Models/appointments/shop_appointments_model.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/loyalty/points_balance_model.dart';
import '../../Models/shop/shops_model.dart';
import 'api/api_service.dart';

class UnifiedStorageService {
  static final UnifiedStorageService _instance = UnifiedStorageService._internal();

  factory UnifiedStorageService() => _instance;

  UnifiedStorageService._internal();

  // Storage instances
  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Box _hiveShopsBox;
  late Box _hiveAppointmentsBox;
  late Box _hiveUserDataBox;
  late Box _hiveOfflineActionsBox;

  // Configuration
  static const Duration _defaultCacheDuration = Duration(minutes: 10);

  // Hive box names
  static const String _shopsBoxName = 'shops';
  static const String _appointmentsBoxName = 'appointments';
  static const String _userDataBoxName = 'user_data';
  static const String _offlineActionsBoxName = 'offline_actions';

  // Secure storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _pinCodeKey = 'pin_code';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Memory cache
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Initialization
  Future<void> initialize() async {
    await _initSharedPreferences();
    await _initHive();
    AppLogger.info('Unified storage service initialized');
  }

  Future<void> _initSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.debug('Shared preferences initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize shared preferences: $e');
      rethrow;
    }
  }

  Future<void> _initHive() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    _hiveShopsBox = await Hive.openBox(_shopsBoxName);
    _hiveAppointmentsBox = await Hive.openBox(_appointmentsBoxName);
    _hiveUserDataBox = await Hive.openBox(_userDataBoxName);
    _hiveOfflineActionsBox = await Hive.openBox(_offlineActionsBoxName);
    AppLogger.debug('Hive storage initialized');
  }

  // ============ MEMORY CACHE ============
  void setMemoryCache(String key, dynamic value, {Duration? duration}) {
    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now().add(duration ?? _defaultCacheDuration);
    AppLogger.debug('Memory cache set: $key');
  }

  dynamic getMemoryCache(String key) {
    _cleanExpiredMemoryCache();
    if (_memoryCache.containsKey(key)) {
      AppLogger.debug('Memory cache hit: $key');
      return _memoryCache[key];
    }
    AppLogger.debug('Memory cache miss: $key');
    return null;
  }

  bool hasMemoryCache(String key) {
    _cleanExpiredMemoryCache();
    return _memoryCache.containsKey(key);
  }

  void removeMemoryCache(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    AppLogger.debug('Memory cache removed: $key');
  }

  void clearMemoryCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    AppLogger.info('Memory cache cleared');
  }

  void _cleanExpiredMemoryCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamps.entries
        .where((entry) => entry.value.isBefore(now))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      AppLogger.debug('Cleaned ${expiredKeys.length} expired memory cache entries');
    }
  }

  // ============ SHARED PREFERENCES ============
  Future<bool> setPreference(String key, dynamic value) async {
    try {
      if (value is String) return await _prefs.setString(key, value);
      if (value is bool) return await _prefs.setBool(key, value);
      if (value is int) return await _prefs.setInt(key, value);
      if (value is double) return await _prefs.setDouble(key, value);
      if (value is List<String>) return await _prefs.setStringList(key, value);
      return false;
    } catch (e) {
      AppLogger.error('Failed to set preference: $key - $e');
      return false;
    }
  }

  dynamic getPreference(String key) {
    try {
      return _prefs.get(key);
    } catch (e) {
      AppLogger.error('Failed to get preference: $key - $e');
      return null;
    }
  }

  Future<bool> removePreference(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      AppLogger.error('Failed to remove preference: $key - $e');
      return false;
    }
  }

  // ============ SECURE STORAGE ============
  Future<void> setSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // ============ HIVE STORAGE ============
  Future<void> setHive(String boxName, String key, dynamic value) async {
    final box = _getHiveBox(boxName);
    await box.put(key, value);
  }

  dynamic getHive(String boxName, String key, {dynamic defaultValue}) {
    final box = _getHiveBox(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  Future<void> removeHive(String boxName, String key) async {
    final box = _getHiveBox(boxName);
    await box.delete(key);
  }

  Box _getHiveBox(String boxName) {
    switch (boxName) {
      case _shopsBoxName: return _hiveShopsBox;
      case _appointmentsBoxName: return _hiveAppointmentsBox;
      case _userDataBoxName: return _hiveUserDataBox;
      case _offlineActionsBoxName: return _hiveOfflineActionsBox;
      default: throw ArgumentError('Unknown box name: $boxName');
    }
  }

  // ============ AUTHENTICATION STORAGE ============
  Future<void> setAuthTokens(String authToken, String refreshToken) async {
    await setSecure(_authTokenKey, authToken);
    await setSecure(_refreshTokenKey, refreshToken);
  }

  Future<Map<String, String?>> getAuthTokens() async {
    final authToken = await getSecure(_authTokenKey);
    final refreshToken = await getSecure(_refreshTokenKey);
    return {'authToken': authToken, 'refreshToken': refreshToken};
  }

  Future<void> setUserProfile(User user) async {
    final userJson = user.toJson();
    await setPreference('user_profile', json.encode(userJson));
    await setSecure(_userIdKey, user.id.toString());
    setMemoryCache('user_profile_${user.id}', userJson);
  }

  Future<User?> getUserProfile() async {
    final data = getPreference('user_profile');
    if (data != null) {
      try {
        return User.fromJson(json.decode(data));
      } catch (e) {
        AppLogger.error('Failed to parse user profile: $e');
      }
    }
    return null;
  }

   Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userJson = json.encode(userData);
    await setPreference('user_data', userJson);
    setMemoryCache('user_data', userData);
  }

  Future<bool> isAuthenticated() async {
    final token = await getSecure(_authTokenKey);
    return token != null && token.isNotEmpty;
  }

  // Future<void> clearAuthData() async {
  //   await _secureStorage.deleteAll();
  //   await removePreference('user_profile');
  //   await removePreference('user_data');
  //   clearMemoryCache();
  //   AppLogger.info('Auth data cleared');
  // }

  // ============ MODEL-SPECIFIC STORAGE ============
  // Shops
  Future<void> setShops(List<Shop> shops, {bool persist = true}) {
    final shopsJson = shops.map((shop) => shop.toJson()).toList();
    setMemoryCache('shops_list', shopsJson);

    if (persist) {
      return setHive(_shopsBoxName, 'cached_shops', shopsJson);
    }
    return Future.value();
  }

  Future<List<Shop>?> getShops() async {
    // Try memory cache first
    final memoryData = getMemoryCache('shops_list');
    if (memoryData != null) {
      return (memoryData as List).map((item) => Shop.fromJson(item)).toList();
    }

    // Try Hive storage
    final hiveData = getHive(_shopsBoxName, 'cached_shops', defaultValue: []);
    if (hiveData.isNotEmpty) {
      final shops = (hiveData as List).map((item) => Shop.fromJson(item)).toList();
      // Populate memory cache
      setMemoryCache('shops_list', hiveData);
      return shops;
    }

    return null;
  }

  // Appointments
  Future<void> setAppointments(List<ShopAppointment> appointments, {bool persist = true}) {
    final appointmentsJson = appointments.map((a) => a.toJson()).toList();
    setMemoryCache('user_appointments', appointmentsJson);

    if (persist) {
      return setHive(_appointmentsBoxName, 'user_appointments', appointmentsJson);
    }
    return Future.value();
  }

  Future<List<ShopAppointment>?> getAppointments() async {
    // Try memory cache first
    final memoryData = getMemoryCache('user_appointments');
    if (memoryData != null) {
      return (memoryData as List).map((item) => ShopAppointment.fromJson(item)).toList();
    }

    // Try Hive storage
    final hiveData = getHive(_appointmentsBoxName, 'user_appointments', defaultValue: []);
    if (hiveData.isNotEmpty) {
      final appointments = (hiveData as List).map((item) => ShopAppointment.fromJson(item)).toList();
      // Populate memory cache
      setMemoryCache('user_appointments', hiveData);
      return appointments;
    }

    return null;
  }

  // Loyalty Balance
  Future<void> setLoyaltyBalance(LoyaltyBalance balance, {bool persist = true}) {
    final balanceJson = balance.toJson();
    setMemoryCache('loyalty_balance', balanceJson);

    if (persist) {
      return setPreference('loyalty_balance', json.encode(balanceJson));
    }
    return Future.value();
  }

  Future<LoyaltyBalance?> getLoyaltyBalance() async {
    // Try memory cache first
    final memoryData = getMemoryCache('loyalty_balance');
    if (memoryData != null) {
      return LoyaltyBalance.fromJson(memoryData);
    }

    // Try shared preferences
    final prefData = getPreference('loyalty_balance');
    if (prefData != null) {
      try {
        final balance = LoyaltyBalance.fromJson(json.decode(prefData));
        setMemoryCache('loyalty_balance', balance.toJson());
        return balance;
      } catch (e) {
        AppLogger.error('Failed to parse loyalty balance: $e');
      }
    }

    return null;
  }

  // Booking Groups
  Future<void> setBookingGroups(List<BookingGroup> groups) {
    final groupsJson = groups.map((g) => g.toJson()).toList();
    return setPreference('booking_groups', json.encode(groupsJson));
  }

  List<BookingGroup>? getBookingGroups() {
    final data = getPreference('booking_groups');
    if (data != null) {
      try {
        final list = json.decode(data) as List;
        return list.map((item) => BookingGroup.fromJson(item)).toList();
      } catch (e) {
        AppLogger.error('Failed to parse booking groups: $e');
      }
    }
    return null;
  }

  // ============ OFFLINE SYNC ============
  Future<void> queueOfflineAction(String action, dynamic data) async {
    final queue = getHive(_offlineActionsBoxName, 'action_queue', defaultValue: []);
    final actionData = {
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'attempts': 0,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    queue.add(actionData);
    await setHive(_offlineActionsBoxName, 'action_queue', queue);
    AppLogger.debug('Action queued for offline sync: $action');
  }

  Future<void> syncOfflineActions() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();

    if (result == ConnectivityResult.none) {
      AppLogger.info('No connectivity, skipping offline sync');
      return;
    }

    final queuedActions = getHive(_offlineActionsBoxName, 'action_queue', defaultValue: []);
    if (queuedActions.isEmpty) return;

    AppLogger.info('Syncing ${queuedActions.length} offline actions');

    final apiService = ApiService();
    final successfulActions = <String>[];

    for (final action in queuedActions) {
      try {
        final actionData = Map<String, dynamic>.from(action);
        final actionType = actionData['action'] as String;
        final data = actionData['data'];
        final actionId = actionData['id'] as String;

        switch (actionType) {
          case 'book_appointment':
            await apiService.post('/appointments', data: data);
            break;
          case 'confirm_payment':
            await apiService.post('/payments/confirm-cash', data: data);
            break;
          case 'submit_review':
            await apiService.post('/reviews', data: data);
            break;
        }

        successfulActions.add(actionId);
        AppLogger.debug('Successfully synced action: $actionType');
      } catch (e) {
        AppLogger.error('Failed to sync action', error: e);
        await _incrementActionAttempt(action['id'] as String);
      }
    }

    await _removeSuccessfulActions(successfulActions);
  }

  Future<void> _incrementActionAttempt(String actionId) async {
    final queue = getHive(_offlineActionsBoxName, 'action_queue', defaultValue: []);
    final updatedQueue = queue.map((action) {
      final actionData = Map<String, dynamic>.from(action);
      if (actionData['id'] == actionId) {
        final attempts = (actionData['attempts'] as int? ?? 0) + 1;
        return {...actionData, 'attempts': attempts};
      }
      return action;
    }).toList();

    await setHive(_offlineActionsBoxName, 'action_queue', updatedQueue);
  }

  Future<void> _removeSuccessfulActions(List<String> actionIds) async {
    final queue = getHive(_offlineActionsBoxName, 'action_queue', defaultValue: []);
    final updatedQueue = queue.where((action) {
      final actionData = Map<String, dynamic>.from(action);
      return !actionIds.contains(actionData['id']);
    }).toList();

    await setHive(_offlineActionsBoxName, 'action_queue', updatedQueue);
  }

  // ============ UTILITY METHODS ============
  Future<void> clearAllData() async {
    // Clear memory cache
    clearMemoryCache();

    // Clear shared preferences
    await _prefs.clear();

    // Clear secure storage
    await _secureStorage.deleteAll();

    // Clear Hive boxes
    await _hiveShopsBox.clear();
    await _hiveAppointmentsBox.clear();
    await _hiveUserDataBox.clear();
    await _hiveOfflineActionsBox.clear();

    AppLogger.info('All storage data cleared');
  }

  Future<Map<String, dynamic>> getStorageStats() async {
    return {
      'memory_cache_entries': _memoryCache.length,
      'shops_count': (getHive(_shopsBoxName, 'cached_shops', defaultValue: []) as List).length,
      'appointments_count': (getHive(_appointmentsBoxName, 'user_appointments', defaultValue: []) as List).length,
      'queued_actions_count': (getHive(_offlineActionsBoxName, 'action_queue', defaultValue: []) as List).length,
      'authenticated': await isAuthenticated(),
    };
  }

  Future<void> close() async {
    await _hiveShopsBox.close();
    await _hiveAppointmentsBox.close();
    await _hiveUserDataBox.close();
    await _hiveOfflineActionsBox.close();
  }

  // ============ AUTH TOKEN METHODS ============
  Future<String?> getAuthToken() async {
    final tokens = await getAuthTokens();
    return tokens['authToken'];
  }

  Future<String?> getRefreshToken() async {
    final tokens = await getAuthTokens();
    return tokens['refreshToken'];
  }

  Future<void> setAuthToken(String token) async {
    await setSecure(_authTokenKey, token);
  }

  Future<void> setRefreshToken(String token) async {
    await setSecure(_refreshTokenKey, token);
  }

  Future<bool> hasAuthToken() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getUserId() async {
    return await getSecure(_userIdKey);
  }

  Future<String?> getUserRole() async {
    return await getSecure(_userRoleKey);
  }

  Future<void> setUserRole(String role) async {
    await setSecure(_userRoleKey, role);
  }

  // Clear auth data method (already exists but ensure it clears all auth-related data)
  Future<void> clearAuthData() async {
    await _secureStorage.deleteAll();
    await removePreference('user_profile');
    await removePreference('user_data');
    clearMemoryCache();
    AppLogger.info('Auth data cleared');
  }
}
