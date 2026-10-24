// import 'package:flutter/material.dart';
import '../base_provider.dart';
import '../../Services/api/api_service.dart';
import '../../Services/storage_service.dart';
import '../../Helpers/logger.dart';

class FavoritesProvider extends BaseProvider {
  final ApiService _apiService;
  final UnifiedStorageService _storageService;

  FavoritesProvider({
    ApiService? apiService,
    UnifiedStorageService? storageService,
  }) : _apiService = apiService ?? ApiService(),
       _storageService = storageService ?? UnifiedStorageService();

  List<Map<String, dynamic>> _favoriteSalons = [];
  bool _hasLoaded = false;

  // Getters
  List<Map<String, dynamic>> get favoriteSalons => _favoriteSalons;
  bool get hasLoaded => _hasLoaded;
  int get favoritesCount => _favoriteSalons.length;

  // Check if a salon is favorited
  bool isSalonFavorited(String salonId) {
    return _favoriteSalons.any(
      (salon) => (salon['id'] ?? salon['_id']).toString() == salonId.toString(),
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

  // Add salon to favorites
  Future<bool> addToFavorites(Map<String, dynamic> salonData) async {
    try {
      setLoading(true);

      final salonId = (salonData['id'] ?? salonData['_id']).toString();

      // Check if already favorited
      if (isSalonFavorited(salonId)) {
        return true; // Already in favorites
      }

      // Add to local list immediately for instant UI feedback
      _favoriteSalons.add(salonData);
      notifyListeners();

      // Save to cache
      await _saveFavoritesToCache();

      // Call API to add to favorites
      final response = await _apiService.addToFavorites(int.parse(salonId));

      if (response['success'] == true) {
        AppLogger.info('Salon added to favorites', extra: {'salonId': salonId});
        return true;
      } else {
        // Rollback if API call failed
        _favoriteSalons.removeWhere(
          (salon) => (salon['id'] ?? salon['_id']).toString() == salonId,
        );
        notifyListeners();
        await _saveFavoritesToCache();
        throw Exception(response['message'] ?? 'Failed to add to favorites');
      }
    } catch (e) {
      // Rollback on error
      final salonId = (salonData['id'] ?? salonData['_id']).toString();
      _favoriteSalons.removeWhere(
        (salon) => (salon['id'] ?? salon['_id']).toString() == salonId,
      );
      notifyListeners();
      await _saveFavoritesToCache();

      setError('Failed to add to favorites: $e');
      AppLogger.error(
        'Failed to add to favorites',
        error: e,
        extra: {'salonId': salonId},
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Remove salon from favorites
  Future<bool> removeFromFavorites(String salonId) async {
    try {
      setLoading(true);

      // Remove from local list immediately for instant UI feedback
      final removedSalon = _favoriteSalons.firstWhere(
        (salon) => (salon['id'] ?? salon['_id']).toString() == salonId,
        orElse: () => {},
      );

      _favoriteSalons.removeWhere(
        (salon) => (salon['id'] ?? salon['_id']).toString() == salonId,
      );
      notifyListeners();

      // Save to cache
      await _saveFavoritesToCache();

      // Call API to remove from favorites
      final response = await _apiService.removeFromFavorites(
        int.parse(salonId),
      );

      if (response['success'] == true) {
        AppLogger.info(
          'Salon removed from favorites',
          extra: {'salonId': salonId},
        );
        return true;
      } else {
        // Rollback if API call failed
        if (removedSalon.isNotEmpty) {
          _favoriteSalons.add(removedSalon);
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
        extra: {'salonId': salonId},
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Map<String, dynamic> salonData) async {
    final salonId = (salonData['id'] ?? salonData['_id']).toString();

    if (isSalonFavorited(salonId)) {
      return await removeFromFavorites(salonId);
    } else {
      return await addToFavorites(salonData);
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favoriteSalons.clear();
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
        _favoriteSalons = List<Map<String, dynamic>>.from(cachedFavorites);
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warning('Failed to load favorites from cache', error: e);
    }
  }

  Future<void> _loadFavoritesFromApi() async {
    try {
      final response = await _apiService.getUserFavorites();
      _favoriteSalons = List<Map<String, dynamic>>.from(response);
      await _saveFavoritesToCache();
      notifyListeners();
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
      await _storageService.setPreference('user_favorites', _favoriteSalons);
    } catch (e) {
      AppLogger.error('Failed to save favorites to cache', error: e);
    }
  }
}
