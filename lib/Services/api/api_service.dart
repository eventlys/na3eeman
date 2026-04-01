import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../Helpers/config.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/loyalty/points_balance_model.dart';
import '../../Models/staff/barber.dart';
import '../../Models/shop/category_model.dart';
import '../storage_service.dart';
import '../security_service.dart';
import 'endpoints.dart';
import 'dart:io';

enum RefreshResult { success, networkError, authError }

/// Refactored API Service with automatic token refresh and clean endpoint management
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Duration timeout = AppConfig.apiTimeout;
  final int maxRetries = AppConfig.maxRetries;
  final UnifiedStorageService _storage = UnifiedStorageService();
  final SecurityService _security = SecurityService();
  final Connectivity _connectivity = Connectivity();

  // Enum to handle different refresh outcomes
  static const String _authClearKey = 'auth_clearing_in_progress';

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
    // Basic connectivity check
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw AppError('No internet connection', type: ErrorType.network);
    }

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

      // Update Inactivity timer for "session maintained"
      _storage.setPreference('last_activity', DateTime.now().toIso8601String());

      // Handle response
      return await _handleResponse(response);
    } on AppError catch (e) {
      // If unauthorized (401), try to refresh token and retry
      if (e.type == ErrorType.authentication &&
          requiresAuth &&
          retryCount == 0) {
        AppLogger.debug('Got 401, attempting token refresh...');

        final refreshResult = await _attemptTokenRefresh();
        
        if (refreshResult == RefreshResult.success) {
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
        } else if (refreshResult == RefreshResult.authError) {
          // Refresh failed due to invalid token - logout
          AppLogger.error('Auth failure during refresh, clearing session.');
          await _clearAuthData();
          rethrow;
        } else {
          // Network Error or other transient error - DO NOT clear session
          AppLogger.warning('Network error during refresh, keeping session as is.');
          throw AppError('Network unavailable for token refresh', type: ErrorType.network);
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
      AppLogger.debug(
        '→ $method ${uri.path}${uri.query.isNotEmpty ? "?${uri.query}" : ""}',
      );
      if (data != null) AppLogger.debug('  Body: ${json.encode(data)}');
    }

    try {
      switch (method) {
        case 'GET':
          return await client.get(uri, headers: headers).timeout(timeout);
        case 'POST':
          return await client
              .post(uri, headers: headers, body: body)
              .timeout(timeout);
        case 'PUT':
          return await client
              .put(uri, headers: headers, body: body)
              .timeout(timeout);
        case 'PATCH':
          return await client
              .patch(uri, headers: headers, body: body)
              .timeout(timeout);
        case 'DELETE':
          return await client.delete(uri, headers: headers).timeout(timeout);
        default:
          throw AppError('Unsupported HTTP method: $method');
      }
    } on TimeoutException {
      throw AppError('Request timed out after ${timeout.inSeconds}s', type: ErrorType.network);
    } on SocketException catch (e) {
      throw AppError('Connection refused or network unavailable: $e', type: ErrorType.network);
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
    dynamic responseBody;
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      throw AppError('Invalid JSON response', type: ErrorType.server);
    }

    // Wrap List body to Map with 'results' key to keep clients aligned
    if (responseBody is List) {
      final Map<String, dynamic> wrapped = {};
      wrapped['results'] = responseBody;
      responseBody = wrapped;
    }

    // Handle success (2xx)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody as Map<String, dynamic>;
    }

    // Handle errors
    final mapBody = responseBody as Map<String, dynamic>;
    String errorMessage = mapBody['message'] ??
        mapBody['detail'] ??
        mapBody['error'] ??
        '';

    if (errorMessage.isEmpty) {
      final buffer = StringBuffer();
      mapBody.forEach((key, value) {
        if (value is List) {
          buffer.write('$key: ${value.join(", ")}. ');
        } else if (value is Map) {
          buffer.write('$key: ${value.toString()}. ');
        } else {
          buffer.write('$key: $value. ');
        }
      });
      errorMessage = buffer.toString().trim();
    }

    if (errorMessage.isEmpty) {
      errorMessage = 'An error occurred';
    }

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
          details: mapBody['errors'] ?? mapBody['details'],
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

  Future<RefreshResult> _attemptTokenRefresh() async {
    // If already refreshing, wait for that to complete
    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshCompleters.add(completer);
      try {
        await completer.future;
        return RefreshResult.success;
      } catch (e) {
        return RefreshResult.authError;
      }
    }

    _isRefreshing = true;

    try {
      final tokens = await _storage.getAuthTokens();
      final refreshToken = tokens['refreshToken'];

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.debug('No refresh token available');
        return RefreshResult.authError;
      }

      // Call refresh endpoint 
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
        final newAccessToken = data['access'] ?? data['token'];

        if (newAccessToken != null) {
          await _storage.setAuthTokens(newAccessToken, refreshToken);
          
          for (var completer in _refreshCompleters) {
            completer.complete(newAccessToken);
          }
          _refreshCompleters.clear();

          AppLogger.debug('Token refresh successful');
          return RefreshResult.success;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        AppLogger.error('Refresh token is invalid/expired (401/403)');
        return RefreshResult.authError;
      }

      AppLogger.error('Token refresh failed with code: ${response.statusCode}');
      return RefreshResult.authError;
    } on SocketException {
      AppLogger.warning('Network error during refresh attempt');
      return RefreshResult.networkError;
    } on TimeoutException {
      AppLogger.warning('Timeout durante refresh attempt');
      return RefreshResult.networkError;
    } catch (e) {
      AppLogger.error('Token refresh exception', error: e);
      return RefreshResult.authError;
    } finally {
      _isRefreshing = false;
      for (var completer in _refreshCompleters) {
        if (!completer.isCompleted) {
          completer.completeError(AppError('Token refresh final failure'));
        }
      }
      _refreshCompleters.clear();
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
      data: {'provider': provider, 'access_token': accessToken},
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
      data: {'old_password': oldPassword, 'new_password': newPassword},
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
    bool? openNow, required int limit,
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

    endpoint = Endpoints.withPagination(
      endpoint,
      page: page,
      pageSize: pageSize,
    );

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

  // ==================== CATEGORY METHODS ====================

  Future<List<Category>> getCategories() async {
    final response = await get(Endpoints.categories);
    final List<dynamic> data = response['results'] ?? response['data'] ?? [];
    return data.map((cat) => Category.fromJson(cat)).toList();
  }

  Future<List<dynamic>> getAdsByCategory(int categoryId) async {
    final response = await get(
      Endpoints.allCampaigns,
      queryParams: {'category': categoryId},
    );
    return response['results'] ?? response['data'] ?? [];
  }

  Future<List<dynamic>> getOffersByCategory(int categoryId) async {
    final response = await get(
      Endpoints.allOffers,
      queryParams: {'category': categoryId},
    );
    return response['results'] ?? response['data'] ?? [];
  }

  Future<Map<String, dynamic>> getNearbySalonsByCategory({
    required double latitude,
    required double longitude,
    required int categoryId,
    int page = 1,
  }) async {
    final endpoint = Endpoints.getNearbyShopsByCategoryUrl(
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
    );
    return await get(Endpoints.withPagination(endpoint, page: page));
  }

  // ==================== APPOINTMENT METHODS ====================

  Future<Map<String, dynamic>> bookAppointment(
    Map<String, dynamic> appointmentData,
  ) async {
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
    endpoint = Endpoints.withPagination(
      endpoint,
      page: page,
      pageSize: pageSize,
    );

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
  // ==================== LOYALTY BALANCE ====================
  // Temporarily mocking loyalty balance and favorites to prevent 404 errors causing Flutter exceptions
  Future<LoyaltyBalance> getLoyaltyBalance(int customerId) async {
    try {
      final response = await get(
        Endpoints.loyaltyBalance,
        queryParams: {'customer': customerId},
      );
      return LoyaltyBalance.fromJson(response);
    } catch (e) {
      AppLogger.debug('Backend returned 404 for loyalty balance. Returning 0 points.');
      return LoyaltyBalance.fromJson({
        'id': 0,
        'customer': customerId,
        'points': 0,
        'free_haircut_counter': 0,
        'free_haircuts_available': 0,
        'free_haircut_progress': '0/0',
        'transactions': [],
      });
    }
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
    endpoint = Endpoints.withPagination(
      endpoint,
      page: page,
      pageSize: pageSize,
    );

    final response = await get(endpoint);
    final List<dynamic> data = response['results'] ?? response['data'] ?? [];
    return data.map((barberData) => Barber.fromJson(barberData)).toList();
  }

  // ==================== ADDITIONAL METHODS ====================

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await post(
      Endpoints.tokenRefresh,
      data: {'refresh': refreshToken},
      requiresAuth: false,
    );
  }

  Future<Map<String, dynamic>> getShopServices(int shopId) async {
    return await get('/shops/$shopId/services/');
  }

  Future<Map<String, dynamic>> fetchHomeData() async {
    return await get('/barber/home/');
  }

  Future<Map<String, dynamic>> fetchTodayWorkingHours(int shopId) async {
    return await get('/shops/$shopId/working-hours/today/');
  }

  Future<Map<String, dynamic>> fetchPendingConfirmations(int shopId) async {
    return await get('/shops/$shopId/pending-confirmations/');
  }

  Future<Map<String, dynamic>> confirmCashPayment(int appointmentId) async {
    return await post('/appointments/$appointmentId/confirm-cash-payment/');
  }

  Future<Map<String, dynamic>> awardPoints({
    required int customerId,
    required int points,
    required String source, Map<String, dynamic>? metadata,
  }) async {
    return await post(
      '/loyalty/award/',
      data: {'customer': customerId, 'points': points, 'source': source},
    );
  }

  Future<Map<String, dynamic>> addToFavorites(int shopId) async {
    try {
      return await post('/favorites/$shopId/');
    } catch (e) {
      return {'success': true}; // Assume success
    }
  }

  Future<Map<String, dynamic>> removeFromFavorites(int shopId) async {
    try {
      return await delete('/favorites/$shopId/');
    } catch (e) {
      return {'success': true}; // Assume success
    }
  }

  Future<Map<String, dynamic>> getUserFavorites() async {
    try {
      return await get('/favorites/');
    } catch (e) {
      return {'results': []}; // Mock empty favorites
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    // Handle different response structures from backend
    final accessToken =
        response['access'] ?? response['token'] ?? response['access_token'];
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

  // ==================== DASHBOARD & ANALYTICS ====================

  /// Fetches a retail snapshot for the specified shop (Owner Studio+).
  Future<Map<String, dynamic>> getRetailSnapshot(int shopId) async {
    return get(Endpoints.shopRetailSnapshot(shopId));
  }

  /// Fetches the employee leaderboard for the specified shop (Owner Studio+).
  Future<List<dynamic>> getTeamLeaderboard(int shopId) async {
    final response = await get(Endpoints.shopTeamLeaderboard(shopId));
    if (response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }
    if (response is List) return response as List<dynamic>;
    return [];
  }

  /// Fetches daily earnings (cash vs card) for the specified shop (Owner).
  Future<Map<String, dynamic>> getDailyEarnings(int shopId) async {
    try {
      return await get(Endpoints.shopDailyEarnings(shopId));
    } catch (e) {
      return {'cash': 0.0, 'card': 0.0, 'total': 0.0};
    }
  }

  /// Fetches the intern activity feed (Intern Role).
  Future<Map<String, dynamic>> getInternActivity() async {
    return get(Endpoints.internActivity);
  }

  // ==================== NOTIFICATIONS ====================

  /// Fetches list of system notifications for the current user.
  Future<List<dynamic>> getNotifications() async {
    final response = await get(Endpoints.notifications);
    if (response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }
    return [];
  }

  /// Marks a specific notification as read.
  Future<void> markNotificationRead(int id) async {
    await post(Endpoints.notificationMarkRead(id));
  }

  /// Marks all notifications for current user as read.
  Future<void> markAllNotificationsRead() async {
    await post(Endpoints.notificationsMarkAllRead);
  }

  // ==================== CAMPAIGNS ====================

  /// Fetches all offers for a shop.
  Future<List<dynamic>> getShopOffers(int shopId) async {
    final response = await get(Endpoints.shopOffers(shopId));
    if (response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }
    return [];
  }

  /// Creates a new offer.
  Future<Map<String, dynamic>> createOffer(int shopId, Map<String, dynamic> data) async {
    return post(Endpoints.shopOffers(shopId), data: data);
  }

  /// Deletes an offer.
  Future<void> deleteOffer(int shopId, int offerId) async {
    await delete('${Endpoints.shopOffers(shopId)}$offerId/');
  }

  /// Fetches all ad campaigns for a shop.
  Future<List<dynamic>> getShopAdCampaigns(int shopId) async {
    final response = await get(Endpoints.shopAdCampaigns(shopId));
    if (response.containsKey('results')) {
      return response['results'] as List<dynamic>;
    }
    return [];
  }

  /// Creates a new ad campaign.
  Future<Map<String, dynamic>> createAdCampaign(int shopId, Map<String, dynamic> data) async {
    return post(Endpoints.shopAdCampaigns(shopId), data: data);
  }

  /// Deletes an ad campaign.
  Future<void> deleteAdCampaign(int shopId, int campaignId) async {
    await delete('${Endpoints.shopAdCampaigns(shopId)}$campaignId/');
  }
}
