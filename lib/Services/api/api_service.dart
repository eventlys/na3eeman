import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Models/staff/barber.dart';
import '../../Helpers/config.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/loyalty/points_balance_model.dart';
import '../storage_service.dart';
import '../security_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final String baseUrl = AppConfig.baseUrl;
  final Duration timeout = const Duration(seconds: 30);
  final UnifiedStorageService _unifiedStorageService = UnifiedStorageService();
  final SecurityService _securityService = SecurityService();

  // Generic HTTP methods
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? customHeaders, Map<String, String>? headers,
  })
  async {
    return _request('GET', endpoint,
      queryParams: queryParams,
      customHeaders: customHeaders,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, String>? customHeaders, Map<String, String>? headers,
  })
  async {
    return _request('POST', endpoint,
      data: data,
      customHeaders: customHeaders,
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, String>? customHeaders, Map<String, String>? headers,
  })
  async {
    return _request('PUT', endpoint,
      data: data,
      customHeaders: customHeaders,
    );
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, String>? customHeaders,
  })
  async {
    return _request('PATCH', endpoint,
      data: data,
      customHeaders: customHeaders,
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? customHeaders, Map<String, String>? headers,
  })
  async {
    return _request('DELETE', endpoint,
      customHeaders: customHeaders,
    );
  }

  // Main request handler
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? customHeaders,
  })
  async {
    try {
      // Build URL
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams?.map((key, value) =>
          MapEntry(key, value.toString())
        ),
      );

      // Get headers
      final headers = await _getHeaders();
      if (customHeaders != null) {
        headers.addAll(customHeaders);
      }

      // Make request using standard http package (you can replace with security service methods later)
      late http.Response response;
      final body = data != null ? json.encode(data) : null;

      AppLogger.debug('API Request: $method $uri - Headers: $headers - Body: $body');

      // Using standard http package for now - you can integrate SecurityService later
      final client = http.Client();
      try {
        switch (method) {
          case 'GET':
            response = await client.get(uri, headers: headers).timeout(timeout);
            break;
          case 'POST':
            response = await client.post(uri, headers: headers, body: body).timeout(timeout);
            break;
          case 'PUT':
            response = await client.put(uri, headers: headers, body: body).timeout(timeout);
            break;
          case 'PATCH':
            response = await client.patch(uri, headers: headers, body: body).timeout(timeout);
            break;
          case 'DELETE':
            response = await client.delete(uri, headers: headers).timeout(timeout);
            break;
          default:
            throw AppError('Unsupported HTTP method: $method');
        }
      } finally {
        client.close();
      }

      return _handleResponse(response);
    } catch (error) {
      AppLogger.error('API request failed: $method $endpoint', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Na3eeman-App/1.0.0',
    };

    // Add auth token if available
    final tokens = await _unifiedStorageService.getAuthTokens();
    final token = tokens['authToken'];
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    AppLogger.debug('API Response: ${response.statusCode} - ${response.body}');

    // Handle empty responses
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      } else {
        throw AppError('Empty response with status ${response.statusCode}');
      }
    }

    Map<String, dynamic> responseBody;
    try {
      responseBody = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw AppError('Invalid JSON response format');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }
    else if (response.statusCode == 401) {
      _handleUnauthorized();
      throw AppError(
        responseBody['message'] ?? 'Authentication required',
        type: ErrorType.authentication,
      );
    } else if (response.statusCode == 403) {
      throw AppError(
        responseBody['message'] ?? 'Access forbidden',
        type: ErrorType.authorization,
      );
    } else if (response.statusCode == 404) {
      throw AppError(
        responseBody['message'] ?? 'Resource not found',
        type: ErrorType.notFound,
      );
    } else if (response.statusCode == 422) {
      throw AppError(
        responseBody['message'] ?? 'Validation failed',
        type: ErrorType.validation,
        details: responseBody['errors'],
      );
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      throw AppError(
        responseBody['message'] ?? 'Client error occurred',
        type: ErrorType.client,
      );
    } else if (response.statusCode >= 500) {
      throw AppError(
        responseBody['message'] ?? 'Server error occurred',
        type: ErrorType.server,
      );
    } else {
      throw AppError('Unexpected error occurred');
    }
  }

  void _handleUnauthorized() async {
    // Clear auth data
    await _unifiedStorageService.clearAuthData();
  }

  // File upload method
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    List<int> fileBytes,
    String fileName, {
    Map<String, String>? fields,
    Map<String, String>? customHeaders,
  })
  async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);
      if (customHeaders != null) {
        request.headers.addAll(customHeaders);
      }

      // Add file
      final file = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );
      request.files.add(file);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (error) {
      AppLogger.error('File upload failed: $endpoint', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  // ========== AUTH METHODS ==========
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      AppLogger.debug('Login attempt for: $email');

      final response = await post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        await _saveAuthData(response);
      }

      return response;
    } catch (e) {
      AppLogger.error('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      AppLogger.debug('Signup attempt for: ${userData['email']}');

      final response = await post('/auth/register', data: userData);

      if (response['success'] == true) {
        await _saveAuthData(response);
      }

      return response;
    } catch (e) {
      AppLogger.error('Signup error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String gender,
    required String password,
    required String role,
  })
  async {
    return await register({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'password': password,
      'role': role,
    });
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
  }

  Future<User> getCurrentUser() async {
    final response = await get('/auth/me');
    return User.fromJson(response['user']);
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    final response = await put('/auth/profile', data: profileData);
    return User.fromJson(response['user']);
  }

  Future<void> logout() async {
    try {
      await post('/auth/logout');
    } catch (e) {
      AppLogger.error('Logout API error: $e');
    } finally {
      await _clearAuthData();
    }
  }

  // ========== LOYALTY METHODS ==========
  Future<LoyaltyBalance> getLoyaltyBalance(int customerId) async {
    final response = await get('/loyalty/balance', queryParams: {
      'customer': customerId.toString(),
    });
    return LoyaltyBalance.fromJson(response);
  }

  Future<LoyaltyBalance> awardPoints({
    required int customerId,
    required int points,
    required String source,
    Map<String, dynamic>? metadata,
  })
  async {
    final response = await post('/loyalty/award-points', data: {
      'customer': customerId,
      'points': points,
      'source': source,
      'metadata': metadata ?? {},
    });
    return LoyaltyBalance.fromJson(response);
  }

  Future<LoyaltyBalance> redeemFreeHaircut(int customerId) async {
    final response = await post('/loyalty/redeem-free-haircut', data: {
      'customer': customerId,
    });
    return LoyaltyBalance.fromJson(response);
  }

  Future<LoyaltyBalance> incrementFreeHaircutCounter(int customerId) async {
    final response = await post('/loyalty/increment-counter/$customerId');
    return LoyaltyBalance.fromJson(response);
  }

  Future<void> awardPointsForReview(int reviewId) async {
    await post('/loyalty/award-review-points', data: {
      'review_id': reviewId,
    });
  }

  // ========== APPOINTMENT METHODS ==========
  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> appointmentData) async {
    return await post('/appointments/book', data: appointmentData);
  }

  Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int limit = 20,
    String? status,
    int? shopId,
    int? customerId,
  })
  async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status;
    if (shopId != null) queryParams['shop'] = shopId.toString();
    if (customerId != null) queryParams['customer'] = customerId.toString();

    return await get('/appointments', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> confirmCashPayment(int appointmentId, int confirmedByUserId) async {
    return await post('/appointments/$appointmentId/confirm-cash-payment', data: {
      'confirmed_by': confirmedByUserId,
    });
  }

  // ========== SHOP METHODS ==========
  Future<Map<String, dynamic>> getShops({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  })
  async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null) queryParams['search'] = search;
    if (minRating != null) queryParams['min_rating'] = minRating.toString();
    if (location != null) queryParams['location'] = location;
    if (openNow != null) queryParams['open_now'] = openNow.toString();

    return await get('/shops', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getShopServices(int shopId) async {
    return await get('/shops/$shopId/services');
  }

  // ========== STAFF METHODS ==========
  Future<Map<String, dynamic>> getStaffMembers({
    int? shopId,
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  })
  async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (shopId != null) queryParams['shop'] = shopId.toString();
    if (role != null) queryParams['role'] = role;
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    return await get('/staff', queryParams: queryParams);
  }

  // ========== PAYMENT METHODS ==========
  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    return await post('/payments/process', data: {
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_details': paymentDetails,
    });
  }

  // ========== ANALYTICS METHODS ==========
  Future<Map<String, dynamic>> logAnalyticsEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  })
  async {
    return await post('/analytics/events', data: {
      'event_name': eventName,
      'parameters': parameters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'flutter',
    });
  }

  // ========== PRIVATE AUTH METHODS ==========
  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    final token = response['token'];
    final refreshToken = response['refresh_token'];
    final user = response['user'];

    if (token != null && refreshToken != null) {
      await _unifiedStorageService.setAuthTokens(token, refreshToken);
    }
    if (user != null) {
      await _unifiedStorageService.setUserProfile(User.fromJson(user));
    }
  }

  Future<void> _clearAuthData() async {
    await _unifiedStorageService.clearAuthData();
  }

  // ========== STAFF HOME METHODS ==========
  Future<Map<String, dynamic>> fetchHomeData() async {
    return await get('/barber/home');
  }

  Future<Map<String, dynamic>> fetchTodayWorkingHours() async {
    return await get('/barber/working-hours/today');
  }

  Future<List<dynamic>> fetchPendingConfirmations() async {
    final response = await get('/barber/appointments/pending-confirmations');
    return response['data'] ?? [];
  }

  Future<List<dynamic>> getBarberAppointments({
    int page = 1,
    int limit = 20,
    String? status,
  })
  async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status;

    final response = await get('/barber/appointments', queryParams: queryParams);
    return response['data'] ?? [];
  }

  Future<Map<String, dynamic>> getBarberEarnings({
    DateTime? startDate,
    DateTime? endDate,
  })
  async {
    final queryParams = <String, dynamic>{};

    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    return await get('/barber/earnings', queryParams: queryParams);
  }

  // ========== FAVORITES METHODS ==========
  Future<Map<String, dynamic>> addToFavorites(String shopId) async {
    return await post('/favorites/add', data: {
      'shop_id': shopId,
    });
  }

  Future<Map<String, dynamic>> removeFromFavorites(String shopId) async {
    return await post('/favorites/remove', data: {
      'shop_id': shopId,
    });
  }

  Future<Map<String, dynamic>> getUserFavorites() async {
    return await get('/favorites');
  }

  Future<Map<String, dynamic>> getFavoriteShops({
    int page = 1,
    int limit = 20,
  })
  async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return await get('/favorites/shops', queryParams: queryParams);
  }


  Future<List<Barber>> getBarbers({
    int page = 1,
    int limit = 20,
    String? search,
    int? shopId,
    bool? isActive,
  })
  async {
    try {
      AppLogger.debug('Fetching barbers - page: $page, limit: $limit, shopId: $shopId');

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (shopId != null) {
        queryParams['shop'] = shopId.toString();
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final response = await _instance.get('/staff', queryParams: queryParams);

      final List<dynamic> data = response['data'] ?? [];
      return data.map((barberData) => Barber.fromJson(barberData)).toList();
    } catch (error) {
      AppLogger.error('Failed to fetch barbers', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Barber> getBarberById(String barberId) async {
    try {
      AppLogger.debug('Fetching barber details: $barberId');

      final response = await _instance.get('/staff/$barberId');
      return Barber.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to fetch barber: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Barber> createBarber(Map<String, dynamic> barberData) async {
    try {
      AppLogger.debug('Creating new barber');

      final response = await _instance.post('/staff', data: barberData);
      return Barber.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to create barber', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Barber> updateBarber(String barberId, Map<String, dynamic> barberData) async {
    try {
      AppLogger.debug('Updating barber: $barberId');

      final response = await _instance.put('/staff/$barberId', data: barberData);
      return Barber.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to update barber: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> deleteBarber(String barberId) async {
    try {
      AppLogger.debug('Deleting barber: $barberId');

      await _instance.delete('/staff/$barberId');
    } catch (error) {
      AppLogger.error('Failed to delete barber: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<Barber>> getShopBarbers(int shopId) async {
    try {
      AppLogger.debug('Fetching barbers for shop: $shopId');

      final response = await _instance.get('/shops/$shopId/staff');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((barberData) => Barber.fromJson(barberData)).toList();
    } catch (error) {
      AppLogger.error('Failed to fetch shop barbers: $shopId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<Map<String, dynamic>> getBarberStats(String barberId) async {
    try {
      AppLogger.debug('Fetching stats for barber: $barberId');

      return await _instance.get('/barber/$barberId/stats');
    } catch (error) {
      AppLogger.error('Failed to fetch barber stats: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

}
