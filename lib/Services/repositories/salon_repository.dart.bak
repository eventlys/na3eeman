// lib/Services/repositories/salon_repository.dart
import '../../Models/salon/review_model.dart';
import '../../Models/salon/salons_model.dart' hide Review;
import '../api/api_service.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/salon/salon_service_model.dart';
import '../../Models/salon/salon_schedule_model.dart';

class SalonRepository {
  final ApiService _apiService;

  SalonRepository(this._apiService);

  Future<List<Salon>> getSalons({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  })
  async {
    try {
      final response = await _apiService.getSalons(
        page: page,
        limit: limit,
        search: search,
        minRating: minRating,
        location: location,
        openNow: openNow,
      );

      final List<dynamic> data = response is List ? response : (response['results'] ?? response['data'] ?? []);
      return data.map((json) => Salon.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get salons failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Salon> getSalonDetails(int salonId) async {
    try {
      final response = await _apiService.get('/salons/$salonId');
      return Salon.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Get salon details failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<SalonService>> getSalonServices(int salonId) async {
    try {
      final List<dynamic> data = await _apiService.getSalonServices(salonId);
      return data.map((json) => SalonService.fromMap(json)).toList();
    } catch (error) {
      AppLogger.error('Get salon services failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<SalonScheduleData> getSalonSchedule(int salonId, DateTime date) async {
    try {
      final response = await _apiService.get(
        '/salons/$salonId/schedule',
        queryParams: {'date': date.toIso8601String().split('T')[0]},
      );
      return SalonScheduleData.fromMap(response['data']);
    } catch (error) {
      AppLogger.error('Get salon schedule failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Review>> getSalonReviews({
    required int salonId,
    int page = 1,
    int limit = 20,
  })
  async {
    try {
      final response = await _apiService.get(
        '/salons/$salonId/reviews',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get salon reviews failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<ReviewStats> getSalonReviewStats(int salonId) async {
    try {
      final response = await _apiService.get('/salons/$salonId/review-stats');
      return ReviewStats.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Get salon review stats failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Review> submitReview({
    required int salonId,
    required int customerId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  })
  async {
    try {
      final response = await _apiService.post('/reviews', data: {
        'salon': salonId,
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

  Future<List<Salon>> searchSalons(String query) async {
    try {
      final response = await _apiService.get('/salons/search', queryParams: {'q': query});
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Salon.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Search salons failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Salon>> getNearbySalons(double lat, double lng, double radiusKm) async {
    try {
      final response = await _apiService.get(
        '/salons/nearby',
        queryParams: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'radius': radiusKm.toString(),
        },
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Salon.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get nearby salons failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> toggleFavorite(int salonId) async {
    try {
      await _apiService.post('/salons/favorites', data: {'salon_id': salonId});
    } catch (error) {
      AppLogger.error('Toggle favorite failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Salon>> getFavoriteSalons() async {
    try {
      final response = await _apiService.get('/salons/favorites');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Salon.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Get favorite salons failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }
}
