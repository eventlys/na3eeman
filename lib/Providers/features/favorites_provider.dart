// import 'package:flutter/material.dart';
import '../base_provider.dart';
import '../../Services/api/api_service.dart';
import '../../Services/storage_service.dart';
import '../../Helpers/logger.dart';

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
    return _favoriteShops.any(
      (shop) => shop['id'].toString() == shopId.toString(),
    );
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
      final response = await _apiService.addToFavorites(int.parse(shopId));

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
      AppLogger.error(
        'Failed to add to favorites',
        error: e,
        extra: {'shopId': shopData['id']},
      );
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
      final response = await _apiService.removeFromFavorites(int.parse(shopId));

      if (response['success'] == true) {
        AppLogger.info(
          'Shop removed from favorites',
          extra: {'shopId': shopId},
        );
        return true;
      } else {
        // Rollback if API call failed
        if (removedShop.isNotEmpty) {
          _favoriteShops.add(removedShop);
          notifyListeners();
          await _saveFavoritesToCache();
        }
        throw Exception(
          response['message'] ?? 'Failed to remove from favorites',
        );
      }
    } catch (e) {
      setError('Failed to remove from favorites: $e');
      AppLogger.error(
        'Failed to remove from favorites',
        error: e,
        extra: {'shopId': shopId},
      );
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
      final cachedFavorites = await _storageService.getPreference(
        'user_favorites',
      );
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
        final favorites = List<Map<String, dynamic>>.from(
          response['data'] ?? [],
        );
        _favoriteShops = favorites;
        await _saveFavoritesToCache();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to load favorites from API, using cache',
        error: e,
      );
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
