import 'dart:convert';
import 'package:hive/hive.dart';
import 'logger.dart';

// Predefined cache keys - moved outside CacheHelper
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String salonsList = 'salons_list';
  static const String categoriesList = 'categories_list';
  static const String appointments = 'user_appointments';
  static const String loyaltyBalance = 'loyalty_balance';
  static const String salonDetailsPrefix = 'salon_details_';
  static const String expertDetailsPrefix = 'expert_details_';
  static const String serviceListPrefix = 'services_';
}

// Cache duration presets - moved outside CacheHelper
class CacheDurations {
  static const Duration short = Duration(minutes: 15);
  static const Duration medium = Duration(hours: 1);
  static const Duration long = Duration(hours: 6);
  static const Duration veryLong = Duration(days: 1);
}

class CacheHelper {
  static final CacheHelper _instance = CacheHelper._internal();

  factory CacheHelper() => _instance;

  CacheHelper._internal();

  static const String _cacheBoxName = 'app_cache';
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  late Box _cacheBox;
  bool _isInitialized = false;

  // In-process listeners notified on [store], keyed by cache key.
  final Map<String, List<void Function(dynamic)>> _listeners = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cacheBox = await Hive.openBox(_cacheBoxName);
      _isInitialized = true;

      // Clean up expired cache entries
      await _cleanExpiredCache();

      AppLogger.debug('Cache helper initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize cache helper', error: e);
      rethrow;
    }
  }

  /// Publishes [data] to registered listeners. Used by the provider layer
  /// for stale-while-revalidate: it registers a listener, emits the cached
  /// value instantly, then emits the fresh network value. Listeners are
  /// keyed per [key] and receive every [store] for that key.
  void _publish(String key, dynamic data) {
    final listeners = _listeners[key];
    if (listeners == null) return;
    for (final listener in List<void Function(dynamic)>.of(listeners)) {
      listener(data);
    }
  }

  /// Registers [listener] for cache-key updates. Returns an unsubscribe
  /// function; callers must invoke it (e.g. on provider dispose).
  void Function() addListener(String key, void Function(dynamic) listener) {
    (_listeners[key] ??= []).add(listener);
    return () => removeListener(key, listener);
  }

  void removeListener(String key, void Function(dynamic) listener) {
    _listeners[key]?.remove(listener);
  }

  // Store data in cache
  Future<void> store(
    String key,
    dynamic data, {
    Duration duration = _defaultCacheDuration,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final cacheEntry = {
        'data': data,
        'expires_at': DateTime.now().add(duration).toIso8601String(),
        'stored_at': DateTime.now().toIso8601String(),
      };

      await _cacheBox.put(key, cacheEntry);
      _publish(key, data);

      AppLogger.debug(
        'Data cached: $key (expires in ${duration.inMinutes} minutes)',
      );
    } catch (e) {
      AppLogger.error('Failed to store data in cache: $key', error: e);
    }
  }

  // Retrieve data from cache
  dynamic retrieve(String key) {
    if (!_isInitialized) {
      // Startup race: a provider may read before AppStateProvider.initialize()
      // completes. Treat as a cache miss (revalidate over network) rather than
      // warning — the data will be cached once initialized.
      return null;
    }

    try {
      final cacheEntry = _cacheBox.get(key);

      if (cacheEntry == null) {
        AppLogger.debug('Cache miss: $key');
        return null;
      }

      // Check if cache entry is expired
      final expiresAt = DateTime.parse(cacheEntry['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        // Remove expired entry
        _cacheBox.delete(key);
        AppLogger.debug('Cache expired: $key');
        return null;
      }

      AppLogger.debug('Cache hit: $key');
      return cacheEntry['data'];
    } catch (e) {
      AppLogger.error('Failed to retrieve data from cache: $key', error: e);
      return null;
    }
  }

  // Remove data from cache
  Future<void> remove(String key) async {
    if (!_isInitialized) await initialize();

    try {
      await _cacheBox.delete(key);
      AppLogger.debug('Cache removed: $key');
    } catch (e) {
      AppLogger.error('Failed to remove data from cache: $key', error: e);
    }
  }

  // Check if cache contains key
  bool contains(String key) {
    if (!_isInitialized) return false;

    try {
      return _cacheBox.containsKey(key) && retrieve(key) != null;
    } catch (e) {
      AppLogger.error('Failed to check cache contains: $key', error: e);
      return false;
    }
  }

  // Clear all cache
  Future<void> clearAll() async {
    if (!_isInitialized) await initialize();

    try {
      await _cacheBox.clear();
      AppLogger.info('All cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear all cache', error: e);
    }
  }

  // Clear cache by prefix
  Future<void> clearByPrefix(String prefix) async {
    if (!_isInitialized) await initialize();

    try {
      final keysToRemove = _cacheBox.keys
          .where((key) => key.toString().startsWith(prefix))
          .toList();

      for (final key in keysToRemove) {
        await _cacheBox.delete(key);
      }

      AppLogger.debug(
        'Cache cleared for prefix: $prefix (${keysToRemove.length} items)',
      );
    } catch (e) {
      AppLogger.error('Failed to clear cache by prefix: $prefix', error: e);
    }
  }

  // Get cache statistics
  Map<String, dynamic> getStats() {
    if (!_isInitialized) return {'initialized': false};

    try {
      final keys = _cacheBox.keys.toList();
      final validEntries = keys.where((key) => contains(key.toString())).length;
      final expiredEntries = keys.length - validEntries;
      final totalSize = _calculateCacheSize();

      return {
        'initialized': true,
        'total_entries': keys.length,
        'valid_entries': validEntries,
        'expired_entries': expiredEntries,
        'total_size_bytes': totalSize,
        'total_size_human': _formatBytes(totalSize),
      };
    } catch (e) {
      AppLogger.error('Failed to get cache stats', error: e);
      return {'initialized': true, 'error': e.toString()};
    }
  }

  // Store user profile
  Future<void> storeUserProfile(Map<String, dynamic> profile) async {
    await store(CacheKeys.userProfile, profile, duration: CacheDurations.long);
  }

  // Retrieve user profile
  Map<String, dynamic>? retrieveUserProfile() {
    return retrieve(CacheKeys.userProfile);
  }

  // Store salons list
  Future<void> storeSalonsList(List<dynamic> salons) async {
    await store(CacheKeys.salonsList, salons, duration: CacheDurations.medium);
  }

  // Retrieve salons list
  List<dynamic>? retrieveSalonsList() {
    return retrieve(CacheKeys.salonsList);
  }

  // Store categories list (parsed maps as returned by the provider layer)
  Future<void> storeCategoriesList(List<dynamic> categories) async {
    await store(
      CacheKeys.categoriesList,
      categories,
      duration: CacheDurations.long,
    );
  }

  // Retrieve categories list
  List<dynamic>? retrieveCategoriesList() {
    return retrieve(CacheKeys.categoriesList);
  }

  // Store salon details
  Future<void> storeSalonDetails(
    int salonId,
    Map<String, dynamic> details, {
    Duration duration = CacheDurations.medium,
  }) async {
    await store(
      '${CacheKeys.salonDetailsPrefix}$salonId',
      details,
      duration: duration,
    );
  }

  // Retrieve salon details
  Map<String, dynamic>? retrieveSalonDetails(int salonId) {
    return retrieve('${CacheKeys.salonDetailsPrefix}$salonId');
  }

  // Store appointments
  Future<void> storeAppointments(List<dynamic> appointments) async {
    await store(
      CacheKeys.appointments,
      appointments,
      duration: CacheDurations.short,
    );
  }

  // Retrieve appointments
  List<dynamic>? retrieveAppointments() {
    return retrieve(CacheKeys.appointments);
  }

  // Store loyalty balance
  Future<void> storeLoyaltyBalance(Map<String, dynamic> balance) async {
    await store(
      CacheKeys.loyaltyBalance,
      balance,
      duration: CacheDurations.medium,
    );
  }

  // Retrieve loyalty balance
  Map<String, dynamic>? retrieveLoyaltyBalance() {
    return retrieve(CacheKeys.loyaltyBalance);
  }

  // Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    try {
      final keys = _cacheBox.keys.toList();
      int removedCount = 0;

      for (final key in keys) {
        final cacheEntry = _cacheBox.get(key);
        if (cacheEntry != null) {
          final expiresAt = DateTime.parse(cacheEntry['expires_at']);
          if (DateTime.now().isAfter(expiresAt)) {
            await _cacheBox.delete(key);
            removedCount++;
          }
        }
      }

      if (removedCount > 0) {
        AppLogger.debug('Cleaned $removedCount expired cache entries');
      }
    } catch (e) {
      AppLogger.error('Failed to clean expired cache', error: e);
    }
  }

  // Calculate total cache size
  int _calculateCacheSize() {
    try {
      int totalSize = 0;
      final keys = _cacheBox.keys.toList();

      for (final key in keys) {
        final value = _cacheBox.get(key);
        if (value != null) {
          final jsonString = json.encode(value);
          totalSize += jsonString.length;
        }
      }

      return totalSize;
    } catch (e) {
      AppLogger.error('Failed to calculate cache size', error: e);
      return 0;
    }
  }

  // Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Get cache keys by pattern
  List<String> getKeysByPattern(String pattern) {
    if (!_isInitialized) return [];

    try {
      return _cacheBox.keys
          .where((key) => key.toString().contains(pattern))
          .map((key) => key.toString())
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get keys by pattern: $pattern', error: e);
      return [];
    }
  }

  // Preload common data
  Future<void> preloadCommonData() async {
    if (!_isInitialized) await initialize();

    // This method can be used to preload frequently accessed data
    // Implementation depends on your app's specific needs
    AppLogger.debug('Common data preloading completed');
  }

  void dispose() {
    if (_isInitialized) {
      _cacheBox.close();
      _isInitialized = false;
    }
  }
}
