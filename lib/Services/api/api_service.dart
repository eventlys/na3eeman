import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../../Helpers/config.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/loyalty/points_balance_model.dart';
import '../../Models/staff/barber.dart';
import '../storage_service.dart';
import '../security_service.dart';
import 'endpoints.dart';

/// Refactored API Service with automatic token refresh and clean endpoint management
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Duration timeout = AppConfig.apiTimeout;
  final int maxRetries = AppConfig.maxRetries;
  final UnifiedStorageService _storage = UnifiedStorageService();
  final SecurityService _security = SecurityService();

  // Token refresh lock to prevent multiple simultaneous refresh attempts
  bool _isRefreshing = false;
  final List<Completer<String>> _refreshCompleters = [];

  // ==================== CORE HTTP METHODS ====================

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
  }) async {
    return _request(
      'GET',
      endpoint,
      queryParams: queryParams,
      customHeaders: customHeaders,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
  }) async {
    return _request(
      'POST',
      endpoint,
      data: data,
      customHeaders: customHeaders,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
  }) async {
    return _request(
      'PUT',
      endpoint,
      data: data,
      customHeaders: customHeaders,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
  }) async {
    return _request(
      'PATCH',
      endpoint,
      data: data,
      customHeaders: customHeaders,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
  }) async {
    return _request(
      'DELETE',
      endpoint,
      customHeaders: customHeaders,
      requiresAuth: requiresAuth,
    );
  }

  // ==================== REQUEST HANDLER ====================

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Map<String, String>? customHeaders,
    bool requiresAuth = true,
    int retryCount = 0,
  }) async {
    try {
      // Build full URL
      final uri = _buildUri(endpoint, queryParams);

      // Get headers
      final headers = await _getHeaders(
        includeAuth: requiresAuth,
        customHeaders: customHeaders,
      );

      // Make HTTP request
      final response = await _makeHttpRequest(method, uri, headers, data);

      // Handle response
      return await _handleResponse(response);
    } on AppError catch (e) {
      // If unauthorized (401), try to refresh token and retry
      if (e.type == ErrorType.authentication && requiresAuth && retryCount == 0) {
        AppLogger.debug('Got 401, attempting token refresh...');
        
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          AppLogger.debug('Token refreshed successfully, retrying request...');
          return _request(
            method,
            endpoint,
            data: data,
            queryParams: queryParams,
            customHeaders: customHeaders,
            requiresAuth: requiresAuth,
            retryCount: retryCount + 1,
          );
        } else {
          // Refresh failed, clear auth and throw
          await _clearAuthData();
          rethrow;
        }
      }
      
      // If network error and retries available, retry
      if (e.type == ErrorType.network && retryCount < maxRetries) {
        AppLogger.debug('Network error, retrying ($retryCount/$maxRetries)...');
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _request(
          method,
          endpoint,
          data: data,
          queryParams: queryParams,
          customHeaders: customHeaders,
          requiresAuth: requiresAuth,
          retryCount: retryCount + 1,
        );
      }
      
      rethrow;
    } catch (error) {
      AppLogger.error('API request failed: $method $endpoint', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    // Build full URL - baseUrl already includes /api/v1
    final String fullUrl = Endpoints.fullUrl(endpoint);
    
    final uri = Uri.parse(fullUrl);
    
    if (queryParams != null && queryParams.isNotEmpty) {
      // Filter out null values
      final cleanParams = Map<String, dynamic>.from(queryParams)
        ..removeWhere((key, value) => value == null);
      
      return uri.replace(
        queryParameters: cleanParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    
    return uri;
  }

  Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
    Map<String, String>? customHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Na3eeman-App/${AppConfig.appVersion}',
    };

    // Add auth token if required and available
    if (includeAuth) {
      final tokens = await _storage.getAuthTokens();
      final token = tokens['authToken'];
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add custom headers
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  Future<http.Response> _makeHttpRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    dynamic data,
  ) async {
    final client = http.Client();
    final body = data != null ? json.encode(data) : null;

    if (AppConfig.enableLogging) {
      AppLogger.debug('→ $method ${uri.path}${uri.query.isNotEmpty ? "?${uri.query}" : ""}');
      if (data != null) AppLogger.debug('  Body: ${json.encode(data)}');
    }

    try {
      switch (method) {
        case 'GET':
          return await client.get(uri, headers: headers).timeout(timeout);
        case 'POST':
          return await client.post(uri, headers: headers, body: body).timeout(timeout);
        case 'PUT':
          return await client.put(uri, headers: headers, body: body).timeout(timeout);
        case 'PATCH':
          return await client.patch(uri, headers: headers, body: body).timeout(timeout);
        case 'DELETE':
          return await client.delete(uri, headers: headers).timeout(timeout);
        default:
          throw AppError('Unsupported HTTP method: $method');
      }
    } on TimeoutException {
      throw AppError(
        'Request timed out',
        type: ErrorType.network,
      );
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (AppConfig.enableLogging) {
      AppLogger.debug('← ${response.statusCode}');
    }

    // Handle empty responses
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      } else {
        throw AppError('Empty response with status ${response.statusCode}');
      }
    }

    // Parse JSON
    Map<String, dynamic> responseBody;
    try {
      responseBody = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw AppError(
        'Invalid JSON response',
        type: ErrorType.server,
      );
    }

    // Handle success (2xx)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }

    // Handle errors
    final errorMessage = responseBody['message'] ?? 
                        responseBody['detail'] ?? 
                        responseBody['error'] ?? 
                        'An error occurred';

    switch (response.statusCode) {
      case 401:
        throw AppError(errorMessage, type: ErrorType.authentication);
      case 403:
        throw AppError(errorMessage, type: ErrorType.authorization);
      case 404:
        throw AppError(errorMessage, type: ErrorType.notFound);
      case 422:
        throw AppError(
          errorMessage,
          type: ErrorType.validation,
          details: responseBody['errors'] ?? responseBody['details'],
        );
      case >= 400 && < 500:
        throw AppError(errorMessage, type: ErrorType.client);
      case >= 500:
        throw AppError(errorMessage, type: ErrorType.server);
      default:
        throw AppError(errorMessage);
    }
  }

  // ==================== TOKEN REFRESH ====================

  Future<bool> _attemptTokenRefresh() async {
    // If already refreshing, wait for that to complete
    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshCompleters.add(completer);
      try {
        await completer.future;
        return true;
      } catch (e) {
        return false;
      }
    }

    _isRefreshing = true;

    try {
      final tokens = await _storage.getAuthTokens();
      final refreshToken = tokens['refreshToken'];

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.debug('No refresh token available');
        return false;
      }

      // Call refresh endpoint (don't use _request to avoid infinite loop)
      final uri = _buildUri(Endpoints.tokenRefresh, null);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final body = json.encode({'refresh': refreshToken});

      final client = http.Client();
      final response = await client
          .post(uri, headers: headers, body: body)
          .timeout(timeout);
      client.close();

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access'];
        
        if (newAccessToken != null) {
          // Save new token
          await _storage.setAuthTokens(newAccessToken, refreshToken);
          
          // Notify waiting requests
          for (var completer in _refreshCompleters) {
            completer.complete(newAccessToken);
          }
          _refreshCompleters.clear();
          
          AppLogger.debug('Token refresh successful');
          return true;
        }
      }

      // Refresh failed
      AppLogger.error('Token refresh failed: ${response.statusCode}');
      for (var completer in _refreshCompleters) {
        completer.completeError(AppError('Token refresh failed'));
      }
      _refreshCompleters.clear();
      
      return false;
    } catch (e) {
      AppLogger.error('Token refresh exception', error: e);
      for (var completer in _refreshCompleters) {
        completer.completeError(e);
      }
      _refreshCompleters.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ==================== FILE UPLOAD ====================

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    List<int> fileBytes,
    String fileName, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      final headers = await _getHeaders(customHeaders: customHeaders);
      request.headers.addAll(headers);

      // Add file
      final file = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
      );
      request.files.add(file);

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (AppConfig.enableLogging) {
        AppLogger.debug('→ POST (multipart) ${uri.path} - File: $fileName');
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return await _handleResponse(response);
    } catch (error) {
      AppLogger.error('File upload failed: $endpoint', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  // ==================== AUTH METHODS ====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    AppLogger.debug('Login attempt for: $email');

    final response = await post(
      Endpoints.login,
      data: {'email': email, 'password': password},
      requiresAuth: false,
    );

    await _saveAuthData(response);
    return response;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    AppLogger.debug('Registration attempt for: ${userData['email']}');

    final response = await post(
      Endpoints.register,
      data: userData,
      requiresAuth: false,
    );

    await _saveAuthData(response);
    return response;
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String accessToken,
  }) async {
    final response = await post(
      Endpoints.socialLogin,
      data: {
        'provider': provider,
        'access_token': accessToken,
      },
      requiresAuth: false,
    );

    await _saveAuthData(response);
    return response;
  }

  Future<User> getCurrentUser() async {
    final response = await get(Endpoints.currentUser);
    return User.fromJson(response['user'] ?? response);
  }

  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    final response = await patch(Endpoints.currentUser, data: profileData);
    return User.fromJson(response['user'] ?? response);
  }

  Future<void> logout() async {
    try {
      await post(Endpoints.logout);
    } catch (e) {
      AppLogger.error('Logout API error (continuing anyway): $e');
    } finally {
      await _clearAuthData();
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await post(
      Endpoints.passwordChange,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<void> requestPasswordReset(String email) async {
    await post(
      Endpoints.passwordReset,
      data: {'email': email},
      requiresAuth: false,
    );
  }

  // ==================== SHOP METHODS ====================

  Future<Map<String, dynamic>> getShops({
    int page = 1,
    int? pageSize,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  }) async {
    var endpoint = Endpoints.shops;
    
    if (search != null && search.isNotEmpty) {
      endpoint = Endpoints.withSearch(endpoint, search);
    }
    
    final filters = <String, dynamic>{
      if (minRating != null) 'min_rating': minRating,
      if (location != null) 'location': location,
      if (openNow != null) 'open_now': openNow,
    };
    
    if (filters.isNotEmpty) {
      endpoint = Endpoints.withFilters(endpoint, filters);
    }
    
    endpoint = Endpoints.withPagination(endpoint, page: page, pageSize: pageSize);
    
    return await get(endpoint);
  }

  Future<Map<String, dynamic>> getShopDetails(int shopId) async {
    return await get(Endpoints.shopDetails(shopId));
  }

  Future<Map<String, dynamic>> getNearbyShops({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int page = 1,
  }) async {
    final endpoint = Endpoints.getNearbyShopsUrl(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    
    return await get(Endpoints.withPagination(endpoint, page: page));
  }

  Future<List<dynamic>> getShopBarbers(int shopId) async {
    final response = await get(Endpoints.shopBarbers(shopId));
    return response['results'] ?? response['data'] ?? [];
  }

  // ==================== APPOINTMENT METHODS ====================

  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> appointmentData) async {
    return await post(Endpoints.appointments, data: appointmentData);
  }

  Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int? pageSize,
    String? status,
    int? shopId,
    int? customerId,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null) 'status': status,
      if (shopId != null) 'shop': shopId,
      if (customerId != null) 'customer': customerId,
    };

    var endpoint = Endpoints.withFilters(Endpoints.appointments, queryParams);
    endpoint = Endpoints.withPagination(endpoint, page: page, pageSize: pageSize);
    
    return await get(endpoint);
  }

  Future<Map<String, dynamic>> getAppointmentDetails(int appointmentId) async {
    return await get(Endpoints.appointmentDetails(appointmentId));
  }

  Future<Map<String, dynamic>> cancelAppointment(int appointmentId) async {
    return await post(Endpoints.appointmentCancel(appointmentId));
  }

  Future<Map<String, dynamic>> rescheduleAppointment(
    int appointmentId,
    Map<String, dynamic> newDetails,
  ) async {
    return await post(
      Endpoints.appointmentReschedule(appointmentId),
      data: newDetails,
    );
  }

  Future<Map<String, dynamic>> completeAppointment(int appointmentId) async {
    return await post(Endpoints.appointmentComplete(appointmentId));
  }

  // ==================== LOYALTY METHODS ====================

  Future<LoyaltyBalance> getLoyaltyBalance(int customerId) async {
    final response = await get(
      Endpoints.loyaltyBalance,
      queryParams: {'customer': customerId},
    );
    return LoyaltyBalance.fromJson(response);
  }

  Future<LoyaltyBalance> redeemFreeHaircut(int customerId) async {
    final response = await post(
      Endpoints.loyaltyRedeemFreeCut,
      data: {'customer': customerId},
    );
    return LoyaltyBalance.fromJson(response);
  }

  // ==================== BARBER METHODS ====================

  Future<List<Barber>> getBarbers({
    int page = 1,
    int? pageSize,
    String? search,
    int? shopId,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (shopId != null) 'shop': shopId,
      if (isActive != null) 'is_active': isActive,
    };

    var endpoint = Endpoints.withFilters(Endpoints.usersBarbers, queryParams);
    endpoint = Endpoints.withPagination(endpoint, page: page, pageSize: pageSize);

    final response = await get(endpoint);
    final List<dynamic> data = response['results'] ?? response['data'] ?? [];
    return data.map((barberData) => Barber.fromJson(barberData)).toList();
  }

  // ==================== PRIVATE HELPERS ====================

  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    // Handle different response structures from backend
    final accessToken = response['access'] ?? response['token'] ?? response['access_token'];
    final refreshToken = response['refresh'] ?? response['refresh_token'];
    final userData = response['user'];

    if (accessToken != null && refreshToken != null) {
      await _storage.setAuthTokens(accessToken, refreshToken);
      AppLogger.debug('Auth tokens saved');
    }

    if (userData != null) {
      await _storage.setUserProfile(User.fromJson(userData));
      AppLogger.debug('User profile saved');
    }
  }

  Future<void> _clearAuthData() async {
    await _storage.clearAuthData();
    AppLogger.debug('Auth data cleared');
  }
}
