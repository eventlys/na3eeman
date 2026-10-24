// lib/Services/repositories/salon_repository.dart
import '../../Models/salon/review_model.dart';
import '../../Models/salon/salons_model.dart' hide Review;
import '../api/api_service.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/salon/salon_service_model.dart';
import '../../Models/salon/salon_schedule_model.dart';
import '../../core/types/result.dart';

class SalonRepository {
  final ApiService _apiService;

  SalonRepository(this._apiService);

  /// Wraps a throwing repository call in a [Result]: success values become
  /// [Success], [AppError]s pass through as [Failure], and anything else is
  /// normalized through [ErrorHandler.handleException].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on AppError catch (error) {
      return Failure(error);
    } catch (error, stackTrace) {
      return Failure(ErrorHandler.handleException(error, stackTrace));
    }
  }

  Future<List<Salon>> getSalons({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  }) async {
    try {
      final response = await _apiService.getSalons(
        page: page,
        limit: limit,
        search: search,
        minRating: minRating,
        location: location,
        openNow: openNow,
      );

      final List<dynamic> data = response is List
          ? response
          : (response['results'] ?? response['data'] ?? []);
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
  }) async {
    try {
      final response = await _apiService.get(
        '/salons/$salonId/reviews',
        queryParams: {'page': page.toString(), 'limit': limit.toString()},
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
  }) async {
    try {
      final response = await _apiService.post(
        '/reviews',
        data: {
          'salon': salonId,
          'customer': customerId,
          'rating': rating,
          'comment': comment,
          'appointment': appointmentId,
          'photos': photos,
        },
      );

      return Review.fromJson(response['data']);
    } catch (error) {
      AppLogger.error('Submit review failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Salon>> searchSalons(String query) async {
    try {
      final response = await _apiService.get(
        '/salons/search',
        queryParams: {'q': query},
      );
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Salon.fromJson(json)).toList();
    } catch (error) {
      AppLogger.error('Search salons failed', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Salon>> getNearbySalons(
    double lat,
    double lng,
    double radiusKm,
  ) async {
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

  // ---------------------------------------------------------------------------
  // Result-returning variants (Phase 4.1)
  //
  // These mirror the throwing methods above but surface errors through the
  // [Result] channel instead of throwing. They delegate to the originals so
  // request/parsing logic stays in one place. Callers migrate incrementally.
  // ---------------------------------------------------------------------------

  Future<Result<List<Salon>>> getSalonsSafe({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  }) {
    return _guard(
      () => getSalons(
        page: page,
        limit: limit,
        search: search,
        minRating: minRating,
        location: location,
        openNow: openNow,
      ),
    );
  }

  Future<Result<Salon>> getSalonDetailsSafe(int salonId) {
    return _guard(() => getSalonDetails(salonId));
  }

  Future<Result<List<SalonService>>> getSalonServicesSafe(int salonId) {
    return _guard(() => getSalonServices(salonId));
  }

  Future<Result<SalonScheduleData>> getSalonScheduleSafe(
    int salonId,
    DateTime date,
  ) {
    return _guard(() => getSalonSchedule(salonId, date));
  }

  Future<Result<List<Review>>> getSalonReviewsSafe({
    required int salonId,
    int page = 1,
    int limit = 20,
  }) {
    return _guard(
      () => getSalonReviews(salonId: salonId, page: page, limit: limit),
    );
  }

  Future<Result<ReviewStats>> getSalonReviewStatsSafe(int salonId) {
    return _guard(() => getSalonReviewStats(salonId));
  }

  Future<Result<Review>> submitReviewSafe({
    required int salonId,
    required int customerId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  }) {
    return _guard(
      () => submitReview(
        salonId: salonId,
        customerId: customerId,
        rating: rating,
        comment: comment,
        appointmentId: appointmentId,
        photos: photos,
      ),
    );
  }

  Future<Result<List<Salon>>> searchSalonsSafe(String query) {
    return _guard(() => searchSalons(query));
  }

  Future<Result<List<Salon>>> getNearbySalonsSafe(
    double lat,
    double lng,
    double radiusKm,
  ) {
    return _guard(() => getNearbySalons(lat, lng, radiusKm));
  }

  Future<Result<void>> toggleFavoriteSafe(int salonId) {
    return _guard(() => toggleFavorite(salonId));
  }

  Future<Result<List<Salon>>> getFavoriteSalonsSafe() {
    return _guard(getFavoriteSalons);
  }
}
