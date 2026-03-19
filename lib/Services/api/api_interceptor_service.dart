// lib/services/api/api_interceptor_service.dart
import '../storage_service.dart';
import 'api_service.dart';
import '../../Helpers/logger.dart';

class ApiInterceptorService {
  final ApiService _apiService;
  final UnifiedStorageService _secureStorage = UnifiedStorageService();

  // Rate limiting configuration
  final RateLimiter _generalLimiter = RateLimiter(
    timeWindow: const Duration(minutes: 1),
    maxRequests: 60,
  );

  final RateLimiter _authLimiter = RateLimiter(
    timeWindow: const Duration(minutes: 1),
    maxRequests: 10,
  );

  final Map<String, RateLimiter> _endpointLimiters = {
    '/auth/login': RateLimiter(
      timeWindow: const Duration(minutes: 1),
      maxRequests: 5,
    ),
    '/auth/register': RateLimiter(
      timeWindow: const Duration(minutes: 1),
      maxRequests: 3,
    ),
    '/shops': RateLimiter(
      timeWindow: const Duration(seconds: 10),
      maxRequests: 30,
    ),
  };

  ApiInterceptorService(this._apiService);

  // ========== AUTH INTERCEPTION ==========

  Future<Map<String, String>> interceptHeaders(
    Map<String, String> headers,
  ) async {
    // Add auth token
    final token = await _secureStorage.getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Add other common headers
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';
    headers['User-Agent'] = 'Na3eeman-App/1.0.0';

    return headers;
  }

  Future<bool> handleUnauthorized() async {
    try {
      // Try to refresh token
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        final response = await _apiService.refreshToken(refreshToken);

        if (response['success'] == true) {
          // Save new tokens
          final newToken = response['token'];
          final newRefreshToken = response['refresh_token'];

          if (newToken != null) {
            await _secureStorage.setAuthToken(newToken);
          }
          if (newRefreshToken != null) {
            await _secureStorage.setRefreshToken(newRefreshToken);
          }

          return true;
        }
      }
    } catch (e) {
      _logError('Token refresh failed: $e');
    }

    // If refresh fails, logout user
    await _performLogout();
    return false;
  }

  Future<void> _performLogout() async {
    try {
      // Call logout endpoint
      await _apiService.post('/auth/logout');
    } catch (e) {
      _logError('Logout API call failed: $e');
    } finally {
      // Clear local storage
      await _secureStorage.clearAuthData();
      // You might want to navigate to login screen here
    }
  }

  // Validate token expiration
  Future<bool> isTokenValid() async {
    final token = await _secureStorage.getAuthToken();
    if (token == null) return false;

    // Simple validation - in real app, you might want to decode JWT
    // and check expiration time
    return true;
  }

  // Get current auth state
  Future<Map<String, dynamic>> getAuthState() async {
    final hasToken = await _secureStorage.hasAuthToken();
    final userId = await _secureStorage.getUserId();
    final userRole = await _secureStorage.getUserRole();

    return {
      'isAuthenticated': hasToken,
      'userId': userId,
      'userRole': userRole,
    };
  }

  // ========== RATE LIMITING ==========

  bool canCallEndpoint(String endpoint) {
    // Check general limiter first
    if (!_generalLimiter.canMakeRequest('general')) {
      return false;
    }

    // Check endpoint-specific limiter if exists
    final endpointLimiter = _endpointLimiters[endpoint];
    if (endpointLimiter != null && !endpointLimiter.canMakeRequest(endpoint)) {
      return false;
    }

    // Check auth endpoints separately
    if (endpoint.startsWith('/auth') && !_authLimiter.canMakeRequest('auth')) {
      return false;
    }

    return true;
  }

  Duration getWaitTime(String endpoint) {
    final generalWait = _generalLimiter.getTimeUntilNextRequest('general');
    final endpointLimiter = _endpointLimiters[endpoint];
    final endpointWait =
        endpointLimiter?.getTimeUntilNextRequest(endpoint) ?? Duration.zero;

    return generalWait > endpointWait ? generalWait : endpointWait;
  }

  void resetRateLimiters() {
    _generalLimiter.resetAll();
    _authLimiter.resetAll();
    _endpointLimiters.forEach((key, value) => value.resetAll());
  }

  Map<String, dynamic> getRateLimitStats(String endpoint) {
    final endpointLimiter = _endpointLimiters[endpoint];
    return endpointLimiter?.getUsageStats(endpoint) ?? {};
  }

  // ========== LOGGING ==========

  void logRequest(String method, String url, dynamic data) {
    AppLogger.debug('API Request: $method $url - Data: $data');
  }

  void logResponse(int statusCode, String body) {
    AppLogger.debug('API Response: $statusCode - $body');
  }

  void _logError(dynamic error) {
    AppLogger.error('API Error', error: error);
  }

  // Enhanced method for structured logging
  void logApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required int durationMs,
    dynamic requestData,
    dynamic responseData,
    String? error,
  }) {
    AppLogger.info(
      'API Call: $method $endpoint',
      extra: {
        'status_code': statusCode,
        'duration_ms': durationMs,
        'request_data': requestData,
        'response_data': responseData,
        'error': error,
      },
    );
  }

  // Domain-specific logging methods
  void logAppointmentApiCall({
    required String action,
    required String appointmentId,
    required int statusCode,
    dynamic additionalData,
  }) {
    AppLogger.debug(
      'Appointment API: $action',
      extra: {
        'appointment_id': appointmentId,
        'status_code': statusCode,
        'additional_data': additionalData,
      },
    );
  }

  void logPaymentApiCall({
    required String action,
    required String paymentId,
    required int statusCode,
    required double amount,
    String? method,
  }) {
    AppLogger.debug(
      'Payment API: $action',
      extra: {
        'payment_id': paymentId,
        'status_code': statusCode,
        'amount': amount,
        'method': method,
      },
    );
  }

  void logLoyaltyApiCall({
    required String action,
    required int customerId,
    required int points,
    required String source,
  }) {
    AppLogger.debug(
      'Loyalty API: $action',
      extra: {'customer_id': customerId, 'points': points, 'source': source},
    );
  }

  // ========== COMPOSED METHODS ==========

  /// Comprehensive method to handle API calls with all interceptors
  Future<Map<String, dynamic>> executeApiCall({
    required String endpoint,
    required String method,
    required dynamic data,
    Map<String, String>? headers,
    bool requireAuth = true,
    bool checkRateLimit = true,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check rate limiting
      if (checkRateLimit && !canCallEndpoint(endpoint)) {
        final waitTime = getWaitTime(endpoint);
        throw Exception(
          'Rate limit exceeded. Try again in ${waitTime.inSeconds} seconds',
        );
      }

      // Prepare headers
      var finalHeaders = headers ?? <String, String>{};
      if (requireAuth) {
        finalHeaders = await interceptHeaders(finalHeaders);
      }

      // Log request
      logRequest(method, endpoint, data);

      // Execute API call
      dynamic response;
      switch (method.toLowerCase()) {
        case 'get':
          response = await _apiService.get(endpoint);
          break;
        case 'post':
          response = await _apiService.post(endpoint, data: data);
          break;
        case 'put':
          response = await _apiService.put(endpoint, data: data);
          break;
        case 'delete':
          response = await _apiService.delete(endpoint);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Log response
      final durationMs = stopwatch.elapsedMilliseconds;
      logApiCall(
        endpoint: endpoint,
        method: method,
        statusCode: 200, // Assuming success
        durationMs: durationMs,
        requestData: data,
        responseData: response,
      );

      return {'success': true, 'data': response};
    } catch (error) {
      final durationMs = stopwatch.elapsedMilliseconds;

      // Log error
      logApiCall(
        endpoint: endpoint,
        method: method,
        statusCode: _extractStatusCode(error),
        durationMs: durationMs,
        requestData: data,
        error: error.toString(),
      );

      // Handle unauthorized errors
      if (_isUnauthorizedError(error) && requireAuth) {
        final refreshed = await handleUnauthorized();
        if (refreshed) {
          // Retry the request once with new token
          return executeApiCall(
            endpoint: endpoint,
            method: method,
            data: data,
            headers: headers,
            requireAuth: requireAuth,
            checkRateLimit: false, // Don't check rate limit for retry
          );
        }
      }

      return {'success': false, 'error': error.toString()};
    }
  }

  // ========== PRIVATE HELPERS ==========

  int _extractStatusCode(dynamic error) {
    if (error is Exception && error.toString().contains('401')) return 401;
    if (error is Exception && error.toString().contains('403')) return 403;
    if (error is Exception && error.toString().contains('404')) return 404;
    if (error is Exception && error.toString().contains('429')) return 429;
    if (error is Exception && error.toString().contains('500')) return 500;
    return 0;
  }

  bool _isUnauthorizedError(dynamic error) {
    return error.toString().contains('401') ||
        error.toString().contains('unauthorized') ||
        error.toString().contains('Invalid token');
  }
}

// RateLimiter class remains the same but is now nested within the same file
class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  final Duration _timeWindow;
  final int _maxRequests;

  RateLimiter({required Duration timeWindow, required int maxRequests})
    : _timeWindow = timeWindow,
      _maxRequests = maxRequests;

  bool canMakeRequest(String endpoint) {
    _cleanOldRequests(endpoint);

    final now = DateTime.now();
    final endpointRequests = _requests[endpoint] ?? [];

    if (endpointRequests.length >= _maxRequests) {
      return false;
    }

    endpointRequests.add(now);
    _requests[endpoint] = endpointRequests;

    return true;
  }

  Duration getTimeUntilNextRequest(String endpoint) {
    _cleanOldRequests(endpoint);

    final endpointRequests = _requests[endpoint] ?? [];
    if (endpointRequests.length < _maxRequests) {
      return Duration.zero;
    }

    final oldestRequest = endpointRequests.first;
    final nextAvailableTime = oldestRequest.add(_timeWindow);
    final now = DateTime.now();

    return nextAvailableTime.isAfter(now)
        ? nextAvailableTime.difference(now)
        : Duration.zero;
  }

  void _cleanOldRequests(String endpoint) {
    final now = DateTime.now();
    final endpointRequests = _requests[endpoint] ?? [];

    _requests[endpoint] = endpointRequests
        .where((timestamp) => now.difference(timestamp) < _timeWindow)
        .toList();
  }

  void resetEndpoint(String endpoint) {
    _requests.remove(endpoint);
  }

  void resetAll() {
    _requests.clear();
  }

  // Get current usage statistics
  Map<String, dynamic> getUsageStats(String endpoint) {
    _cleanOldRequests(endpoint);
    final endpointRequests = _requests[endpoint] ?? [];

    return {
      'current_requests': endpointRequests.length,
      'max_requests': _maxRequests,
      'time_window_seconds': _timeWindow.inSeconds,
      'can_make_request': endpointRequests.length < _maxRequests,
    };
  }
}
