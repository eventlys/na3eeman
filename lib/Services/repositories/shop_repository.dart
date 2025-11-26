// lib/Services/repositories/shop_repository.dart
import '../../Models/shop/review_model.dart';
import '../../Models/shop/shops_model.dart' hide Review;
import '../api/api_service.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/shop/shop_service_model.dart';
import '../../Models/shop/shop_schedule_model.dart';

class ShopRepository {
  final ApiService _apiService;

  ShopRepository(this._apiService);

  Future<List<Shop>> getShops({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  })
  async {
    try {
      final response = await _apiService.getShops(
        page: page,
        limit: limit,
        search: search,
        minRating: minRating,
        location: location,
        openNow: openNow,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Shop.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get shops failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Shop> getShopDetails(int shopId) async {
    try {
      final response = await _apiService.get('/shops/$shopId');
      return Shop.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Get shop details failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<ShopService>> getShopServices(int shopId) async {
    try {
      final response = await _apiService.getShopServices(shopId);
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ShopService.fromMap(json)).toList();
    } catch (error) {
      AppLogger.error('Get shop services failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<ShopScheduleData> getShopSchedule(int shopId, DateTime date) async {
    try {
      final response = await _apiService.get(
        '/shops/$shopId/schedule',
        queryParams: {'date': date.toIso8601String().split('T')[0]},
      );
      return ShopScheduleData.fromMap(response['data']);
    } catch (error) {
      AppLogger.error('Get shop schedule failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Review>> getShopReviews({
    required int shopId,
    int page = 1,
    int limit = 20,
  })
  async {
    try {
      final response = await _apiService.get(
        '/shops/$shopId/reviews',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get shop reviews failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<ReviewStats> getShopReviewStats(int shopId) async {
    try {
      final response = await _apiService.get('/shops/$shopId/review-stats');
      return ReviewStats.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Get shop review stats failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Review> submitReview({
    required int shopId,
    required int customerId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  })
  async {
    try {
      final response = await _apiService.post('/reviews', data: {
        'shop': shopId,
        'customer': customerId,
        'rating': rating,
        'comment': comment,
        'appointment': appointmentId,
        'photos': photos,
      });

      return Review.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Submit review failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Shop>> searchShops(String query) async {
    try {
      final response = await _apiService.get('/shops/search', queryParams: {'q': query});
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Shop.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Search shops failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Shop>> getNearbyShops(double lat, double lng, double radiusKm) async {
    try {
      final response = await _apiService.get(
        '/shops/nearby',
        queryParams: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'radius': radiusKm.toString(),
        },
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Shop.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get nearby shops failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> toggleFavorite(int shopId) async {
    try {
      await _apiService.post('/shops/favorites', data: {'shop_id': shopId});
    } catch (error) {
      AppLogger.error('Toggle favorite failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Shop>> getFavoriteShops() async {
    try {
      final response = await _apiService.get('/shops/favorites');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Shop.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get favorite shops failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }
}
