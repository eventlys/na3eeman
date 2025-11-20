import 'api_interceptor_service.dart';

class ApiThrottler {
  static final ApiThrottler _instance = ApiThrottler._internal();

  factory ApiThrottler() => _instance;

  ApiThrottler._internal();

  final RateLimiter _generalLimiter = RateLimiter(
    timeWindow: const Duration(minutes: 1),
    maxRequests: 60,
  );

  final RateLimiter _authLimiter = RateLimiter(
    timeWindow: const Duration(minutes: 1),
    maxRequests: 10,
  );

  final RateLimiter _uploadLimiter = RateLimiter(
    timeWindow: const Duration(minutes: 1),
    maxRequests: 5,
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
    '/auth/forgot-password': RateLimiter(
      timeWindow: const Duration(minutes: 1),
      maxRequests: 3,
    ),
    '/appointments/book': RateLimiter(
      timeWindow: const Duration(seconds: 30),
      maxRequests: 10,
    ),
    '/payments/process': RateLimiter(
      timeWindow: const Duration(seconds: 30),
      maxRequests: 15,
    ),
    '/reviews': RateLimiter(
      timeWindow: const Duration(minutes: 1),
      maxRequests: 10,
    ),
  };

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

    // Check upload endpoints
    if ((endpoint.contains('/upload') || endpoint.contains('/files')) && 
        !_uploadLimiter.canMakeRequest('upload')) {
      return false;
    }

    return true;
  }

  Duration getWaitTime(String endpoint) {
    final generalWait = _generalLimiter.getTimeUntilNextRequest('general');
    final endpointLimiter = _endpointLimiters[endpoint];
    final endpointWait = endpointLimiter?.getTimeUntilNextRequest(endpoint) ?? Duration.zero;
    final authWait = endpoint.startsWith('/auth') ? 
        _authLimiter.getTimeUntilNextRequest('auth') : Duration.zero;
    final uploadWait = (endpoint.contains('/upload') || endpoint.contains('/files')) ? 
        _uploadLimiter.getTimeUntilNextRequest('upload') : Duration.zero;

    final waits = [generalWait, endpointWait, authWait, uploadWait];
    waits.sort((a, b) => b.compareTo(a)); // Sort descending

    return waits.first;
  }

  void recordRequest(String endpoint) {
    _generalLimiter.canMakeRequest('general'); // This records the request
    
    final endpointLimiter = _endpointLimiters[endpoint];
    if (endpointLimiter != null) {
      endpointLimiter.canMakeRequest(endpoint);
    }

    if (endpoint.startsWith('/auth')) {
      _authLimiter.canMakeRequest('auth');
    }

    if (endpoint.contains('/upload') || endpoint.contains('/files')) {
      _uploadLimiter.canMakeRequest('upload');
    }
  }

  void reset() {
    _generalLimiter.resetAll();
    _authLimiter.resetAll();
    _uploadLimiter.resetAll();
    _endpointLimiters.forEach((key, value) => value.resetAll());
  }

  // Get throttling statistics
  Map<String, dynamic> getThrottlingStats(String endpoint) {
    return {
      'endpoint': endpoint,
      'general_limiter': _generalLimiter.getUsageStats('general'),
      'auth_limiter': _authLimiter.getUsageStats('auth'),
      'upload_limiter': _uploadLimiter.getUsageStats('upload'),
      'endpoint_limiter': _endpointLimiters[endpoint]?.getUsageStats(endpoint),
      'can_call_endpoint': canCallEndpoint(endpoint),
      'wait_time': getWaitTime(endpoint),
    };
  }

  // Check if endpoint is rate limited
  bool isEndpointRateLimited(String endpoint) {
    return !canCallEndpoint(endpoint);
  }

  // Get all rate limited endpoints
  List<String> getRateLimitedEndpoints() {
    final limitedEndpoints = <String>[];

    if (!_generalLimiter.canMakeRequest('general')) {
      limitedEndpoints.add('general');
    }

    if (!_authLimiter.canMakeRequest('auth')) {
      limitedEndpoints.add('auth_endpoints');
    }

    if (!_uploadLimiter.canMakeRequest('upload')) {
      limitedEndpoints.add('upload_endpoints');
    }

    _endpointLimiters.forEach((endpoint, limiter) {
      if (!limiter.canMakeRequest(endpoint)) {
        limitedEndpoints.add(endpoint);
      }
    });

    return limitedEndpoints;
  }
}
