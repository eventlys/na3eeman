// import 'dart:convert';

class CacheManager {
  static final Map<String, CacheItem> _cache = {};

  static T? get<T>(String key) {
    final item = _cache[key];
    if (item == null || item.isExpired) {
      _cache.remove(key);
      return null;
    }
    return item.data as T;
  }

  static void set(String key, dynamic data, {Duration duration = const Duration(minutes: 5)}) {
    _cache[key] = CacheItem(data, duration);
  }

  static void remove(String key) {
    _cache.remove(key);
  }

  static void clear() {
    _cache.clear();
  }

  static bool contains(String key) {
    return _cache.containsKey(key) && !_cache[key]!.isExpired;
  }
}

class CacheItem {
  final dynamic data;
  final DateTime expiryTime;

  CacheItem(this.data, Duration duration)
      : expiryTime = DateTime.now().add(duration);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
