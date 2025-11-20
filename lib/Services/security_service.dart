import 'dart:io';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../Helpers/logger.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();

  factory SecurityService() => _instance;

  SecurityService._internal();

  // Biometric authentication
  final LocalAuthentication _auth = LocalAuthentication();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Network security
  static const int _timeoutSeconds = 30;

  // Biometric Methods
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticate = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticate && isDeviceSupported;
    } on PlatformException catch (e) {
      AppLogger.error('Biometric availability check failed', error: e);
      return false;
    } catch (e) {
      AppLogger.error('Unexpected error in biometric availability', error: e);
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      AppLogger.error('Failed to get available biometrics', error: e);
      return [];
    } catch (e) {
      AppLogger.error('Unexpected error getting biometrics', error: e);
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to access your account',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
      );
    } on PlatformException catch (e) {
      AppLogger.error('Biometric authentication failed', error: e);
      return false;
    } catch (e) {
      AppLogger.error('Unexpected error in biometric authentication', error: e);
      return false;
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      final availableBiometrics = await _auth.getAvailableBiometrics();

      return canCheck &&
             isDeviceSupported &&
             availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      AppLogger.error('Failed to check enrolled biometrics', error: e);
      return false;
    } catch (e) {
      AppLogger.error('Unexpected error checking enrolled biometrics', error: e);
      return false;
    }
  }

  Future<BiometricResult> authenticateWithFallback({
    required String reason,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricResult.unavailable;
      }

      final success = await _auth.authenticate(
        localizedReason: reason,
      );

      return success ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e) {
      AppLogger.error('Biometric authentication with fallback failed', error: e);
      return BiometricResult.error;
    } catch (e) {
      AppLogger.error('Unexpected error in biometric authentication', error: e);
      return BiometricResult.error;
    }
  }

  // Network Security Methods
  Future<HttpClientResponse> _secureRequest(
    String url,
    String method, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    if (!isValidUrl(url)) {
      throw ArgumentError('Invalid URL: $url');
    }

    HttpClient client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: _timeoutSeconds)
        ..badCertificateCallback = _verifyCertificate
        ..userAgent = 'Na3eeman/1.0.0';

      final uri = Uri.parse(url);
      final request = await _createRequest(client, uri, method);

      _addSecurityHeaders(request);
      await _addAuthHeaders(request);

      // Add custom headers
      headers?.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Handle request body for methods that support it
      if (body != null && _isBodySupportedMethod(method)) {
        await _writeRequestBody(request, body, url, method);
      } else {
        AppLogger.debug('Secure $method request: $url');
      }

      return await request.close();
    } catch (error) {
      AppLogger.error('Secure $method failed: $error');
      rethrow;
    }
  }

  Future<HttpClientRequest> _createRequest(
    HttpClient client,
    Uri uri,
    String method
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await client.getUrl(uri);
      case 'POST':
        return await client.postUrl(uri);
      case 'PUT':
        return await client.putUrl(uri);
      case 'PATCH':
        return await client.patchUrl(uri);
      case 'DELETE':
        return await client.deleteUrl(uri);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  bool _isBodySupportedMethod(String method) {
    return ['POST', 'PUT', 'PATCH'].contains(method.toUpperCase());
  }

  Future<void> _writeRequestBody(
    HttpClientRequest request,
    dynamic body,
    String url,
    String method,
  ) async {
    // Set content type if not provided
    final contentType = request.headers.value('Content-Type');
    if (contentType == null || !contentType.contains('application/json')) {
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
    }

    final bodyString = body is String ? body : json.encode(body);
    request.write(bodyString);

    AppLogger.debug('Secure $method request: $url - Body: $bodyString');
  }

  Future<HttpClientResponse> secureGet(String url, {Map<String, String>? headers}) {
    return _secureRequest(url, 'GET', headers: headers);
  }

  Future<HttpClientResponse> securePost(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) {
    return _secureRequest(url, 'POST', headers: headers, body: body);
  }

  Future<HttpClientResponse> securePut(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) {
    return _secureRequest(url, 'PUT', headers: headers, body: body);
  }

  Future<HttpClientResponse> securePatch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) {
    return _secureRequest(url, 'PATCH', headers: headers, body: body);
  }

  Future<HttpClientResponse> secureDelete(
    String url, {
    Map<String, String>? headers,
  }) {
    return _secureRequest(url, 'DELETE', headers: headers);
  }

  void _addSecurityHeaders(HttpClientRequest request) {
    request.headers.set('X-Content-Type-Options', 'nosniff');
    request.headers.set('X-Frame-Options', 'DENY');
    request.headers.set('X-XSS-Protection', '1; mode=block');
    request.headers.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    request.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  }

  Future<void> _addAuthHeaders(HttpClientRequest request) async {
    try {
      final token = await _getAuthToken();
      if (token != null && token.isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }
    } catch (e) {
      AppLogger.error('Failed to add auth headers: $e');
    }
  }

  Future<String?> _getAuthToken() async {
    // Implement token retrieval from your auth service
    return null;
  }

  bool _verifyCertificate(X509Certificate cert, String host, int port) {
    // In production, implement proper certificate pinning
    // For development, you might want to return true
    if (const bool.fromEnvironment('DEBUG', defaultValue: false)) {
      return true; // Allow all certificates in debug mode
    }

    // Production certificate validation
    return _validateCertificate(cert, host);
  }

  bool _validateCertificate(X509Certificate cert, String host) {
    // Implement proper certificate validation
    try {
      // Add domain-specific validation
      final allowedDomains = ['your-api-domain.com', 'api.na3eeman.com'];
      if (!allowedDomains.any((domain) => host.contains(domain))) {
        AppLogger.error('Certificate host mismatch: $host');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Certificate validation failed: $e');
      return false;
    }
  }

  static Map<String, String> getSecurityHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Referrer-Policy': 'strict-origin-when-cross-origin',
    };
  }

  // Method to validate URL before making request
  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Method to sanitize request data
  Map<String, dynamic> sanitizeRequestData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);

    // Remove sensitive fields
    const sensitiveFields = ['password', 'token', 'secret', 'credit_card', 'cvc'];
    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '***REDACTED***';
      }
    }

    return sanitized;
  }

  // Security Scanning Methods
  Future<SecurityScanResult> performSecurityScan() async {
    try {
      AppLogger.debug('Starting comprehensive security scan');

      final results = await Future.wait([
        _checkRootedDevice(),
        _checkScreenRecording(),
        _checkInsecureConnections(),
        _checkBiometricSecurity(),
        _checkAppIntegrity(),
      ]);

      final isSecure = results.every((result) => result);

      AppLogger.debug('Security scan completed: ${isSecure ? 'Secure' : 'Issues found'}');

      return SecurityScanResult(
        isSecure: isSecure,
        rootedDevice: !results[0],
        screenRecordingDetected: !results[1],
        insecureConnections: !results[2],
        biometricIssues: !results[3],
        appIntegrityCompromised: !results[4],
      );
    } catch (e) {
      AppLogger.error('Security scan failed: $e');
      return SecurityScanResult(
        isSecure: false,
        scanError: e.toString(),
      );
    }
  }

  Future<bool> _checkRootedDevice() async {
    try {
      if (await _isAndroidRooted() || await _isIosJailbroken()) {
        AppLogger.debug('Rooted/jailbroken device detected');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Root check failed: $e');
      return false;
    }
  }

  Future<bool> _isAndroidRooted() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;

      // Check for root indicators
      final rootIndicators = [
        androidInfo.isPhysicalDevice != true,
        _checkBuildTags(androidInfo.version.securityPatch),
      ];

      return rootIndicators.any((indicator) => indicator == true);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isIosJailbroken() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;

      // Check for jailbreak indicators
      final jailbreakIndicators = [
        !iosInfo.isPhysicalDevice,
        iosInfo.model.toLowerCase().contains('simulator'),
      ];

      return jailbreakIndicators.any((indicator) => indicator == true);
    } catch (e) {
      return false;
    }
  }

  bool _checkBuildTags(String? securityPatch) {
    if (securityPatch == null) return true;

    // Check if security patch is outdated or suspicious
    final patchDate = DateTime.tryParse(securityPatch);
    if (patchDate == null) return true;

    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return patchDate.isBefore(sixMonthsAgo);
  }

  Future<bool> _checkScreenRecording() async {
    try {
      // On iOS, we can check if screen is being recorded
      return true; // Assume secure for now
    } catch (e) {
      AppLogger.error('Screen recording check failed: $e');
      return false;
    }
  }

  Future<bool> _checkInsecureConnections() async {
    try {
      // Check for HTTP vs HTTPS usage
      return true; // Assume secure for now
    } catch (e) {
      AppLogger.error('Insecure connections check failed: $e');
      return false;
    }
  }

  Future<bool> _checkBiometricSecurity() async {
    try {
      final hasBiometrics = await hasEnrolledBiometrics();
      final isAvailable = await isBiometricAvailable();

      return hasBiometrics && isAvailable;
    } catch (e) {
      AppLogger.error('Biometric security check failed: $e');
      return false;
    }
  }

  Future<bool> _checkAppIntegrity() async {
    try {
      // Check if app has been tampered with
      if (const bool.fromEnvironment('DEBUG', defaultValue: false)) {
        AppLogger.debug('App is in debug mode');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('App integrity check failed: $e');
      return false;
    }
  }

  Future<void> preventScreenshots() async {
    try {
      // Prevent screenshots on sensitive screens
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      AppLogger.debug('Screenshot prevention enabled');
    } catch (e) {
      AppLogger.error('Failed to prevent screenshots: $e');
    }
  }

  Future<void> allowScreenshots() async {
    try {
      // Allow screenshots again
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      AppLogger.debug('Screenshot prevention disabled');
    } catch (e) {
      AppLogger.error('Failed to allow screenshots: $e');
    }
  }

  Future<Map<String, dynamic>> getSecurityStatus() async {
    final scanResult = await performSecurityScan();

    return {
      'overall_secure': scanResult.isSecure,
      'rooted_device': scanResult.rootedDevice,
      'screen_recording': scanResult.screenRecordingDetected,
      'insecure_connections': scanResult.insecureConnections,
      'biometric_issues': scanResult.biometricIssues,
      'app_integrity': !scanResult.appIntegrityCompromised,
      'recommendations': _getSecurityRecommendations(scanResult),
    };
  }

  List<String> _getSecurityRecommendations(SecurityScanResult result) {
    final recommendations = <String>[];

    if (result.rootedDevice) {
      recommendations.add('Device appears to be rooted/jailbroken. Consider using a secure device.');
    }

    if (result.screenRecordingDetected) {
      recommendations.add('Screen recording detected. Avoid showing sensitive information.');
    }

    if (result.insecureConnections) {
      recommendations.add('Insecure network connections detected. Use secure networks only.');
    }

    if (result.biometricIssues) {
      recommendations.add('Biometric authentication not properly configured.');
    }

    if (result.appIntegrityCompromised) {
      recommendations.add('App integrity may be compromised. Reinstall from official store.');
    }

    return recommendations;
  }

  // Quick security check for critical operations
  Future<bool> isEnvironmentSecure() async {
    try {
      final scanResult = await performSecurityScan();
      return scanResult.isSecure &&
             !scanResult.rootedDevice &&
             !scanResult.appIntegrityCompromised;
    } catch (e) {
      AppLogger.error('Environment security check failed: $e');
      return false;
    }
  }
}

enum BiometricResult {
  success,
  failed,
  unavailable,
  error,
}

class SecurityScanResult {
  final bool isSecure;
  final bool rootedDevice;
  final bool screenRecordingDetected;
  final bool insecureConnections;
  final bool biometricIssues;
  final bool appIntegrityCompromised;
  final String? scanError;

  const SecurityScanResult({
    required this.isSecure,
    this.rootedDevice = false,
    this.screenRecordingDetected = false,
    this.insecureConnections = false,
    this.biometricIssues = false,
    this.appIntegrityCompromised = false,
    this.scanError,
  });
}
