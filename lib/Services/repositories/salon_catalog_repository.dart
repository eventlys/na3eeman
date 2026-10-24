import '../../Helpers/logger.dart';
import '../../Models/salon/salons_model.dart' hide Review;
import '../../Models/staff/expert.dart';
import '../api/api_service.dart';

/// Repository for salon catalog access (listing, details, experts, pricing).
///
/// Distinct from the older `SalonRepository` in `salon_repository.dart`,
/// which is a separate class used elsewhere; this one holds the salon methods
/// extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class SalonCatalogRepository {
  final ApiService _apiService;

  SalonCatalogRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<Salon>> getSalons({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
    double? lat,
    double? lng,
    double? radius,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (location != null) queryParams['location'] = location;
      if (openNow != null) queryParams['open_now'] = openNow.toString();
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lng != null) queryParams['lng'] = lng.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final response = await _apiService.get(
        '/salons',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Salon.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching salons: $e');
      return [];
    }
  }

  Future<Salon> getSalonDetails(int salonId) async {
    try {
      final response = await _apiService.get('/salons/$salonId');
      return Salon.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error fetching salon details: $e');
      rethrow;
    }
  }

  Future<List<Expert>> getSalonExperts(int salonId) async {
    try {
      final response = await _apiService.get('/salons/$salonId/experts');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => Expert.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching salon experts: $e');
      return [];
    }
  }

  Future<double> calculateAppointmentTotal(String appointmentId) async {
    try {
      final response = await _apiService.get(
        '/salons/calculate-total/$appointmentId',
      );
      return (response['data']['total'] as num).toDouble();
    } catch (e) {
      AppLogger.error('Error calculating appointment total: $e');
      rethrow;
    }
  }
}
