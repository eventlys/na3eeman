import 'dart:convert';

import '../../Helpers/config.dart';
import '../../Helpers/logger.dart';
import '../../Models/salon/review_model.dart';
import '../api/api_interceptor_service.dart';
import '../api/api_service.dart';
import '../security_service.dart';
import 'loyalty_repository.dart';

/// Repository for review backend access.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class ReviewRepository {
  final ApiService _apiService;
  final ApiInterceptorService _logger;
  final SecurityService _networkSecurity;
  final LoyaltyRepository _loyaltyRepository;

  ReviewRepository({
    ApiService? apiService,
    ApiInterceptorService? logger,
    SecurityService? networkSecurity,
    LoyaltyRepository? loyaltyRepository,
  }) : _apiService = apiService ?? ApiService(),
       _logger = logger ?? ApiInterceptorService(ApiService()),
       _networkSecurity = networkSecurity ?? SecurityService(),
       _loyaltyRepository = loyaltyRepository ?? LoyaltyRepository();

  static String get _baseUrl => AppConfig.baseUrl;

  Future<Review> createReview({
    required int customerId,
    required int salonId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  }) async {
    try {
      _logger.logRequest('POST', '$_baseUrl/reviews/', {
        'customer': customerId,
        'salon': salonId,
        'rating': rating,
        'comment': comment,
        'appointment': appointmentId,
        'photos': photos,
      });

      final response = await _networkSecurity.securePost(
        '$_baseUrl/reviews/',
        headers: await _getAuthHeaders(),
        body: json.encode({
          'customer': customerId,
          'salon': salonId,
          'rating': rating,
          'comment': comment,
          'appointment': appointmentId,
          'photos': photos ?? [],
        }),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      _logger.logResponse(response.statusCode, responseBody);

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        await _loyaltyRepository.awardReviewPoints(customerId, data['id']);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (error) {
      AppLogger.error('Error creating review: $error');
      rethrow;
    }
  }

  Future<List<Review>> getSalonReviews(int salonId) async {
    try {
      final response = await _apiService.get('/salons/$salonId/reviews');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching salon reviews: $e');
      return [];
    }
  }

  // ============ HELPER METHODS ============

  Future<Map<String, String>> _getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _getToken()}',
    };
  }

  Future<String> _getToken() async {
    // Implement token retrieval from your auth service
    return ''; // Replace with actual token retrieval
  }
}
