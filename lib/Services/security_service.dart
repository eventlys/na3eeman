import 'dart:io';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:safe_device/safe_device.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';

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
        persistAcrossBackgrounding: true,
        biometricOnly: true,
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
        persistAcrossBackgrounding: true,
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

  // Network Security Methods - Used by ApiService
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

  // Security Scanning Methods
  Future<SecurityScanResult> performSecurityScan() async {
    try {
      AppLogger.debug('Starting comprehensive security scan');

      // Check current debug mode
      final bool isDebug = const bool.fromEnvironment('dart.vm.product') == false;

      final results = await Future.wait([
        SafeDevice.isJailBroken,
        SafeDevice.isRealDevice,
        SafeDevice.isOnExternalStorage,
        SafeDevice.isDevelopmentModeEnable,
      ]);

      final bool isJailBroken = results[0];
      final bool isRealDevice = results[1];
      final bool isOnExternalStorage = results[2];
      final bool isDevMode = results[3];

      // Screen recording check (iOS only, for Android use FlutterWindowManager)
      bool screenRecordingDetected = false;
      if (Platform.isIOS) {
        // iOS specific check if needed
      }

      final isSecure = !isJailBroken && (isRealDevice || isDebug);

      AppLogger.debug('Security scan completed: ${isSecure ? 'Secure' : 'Issues found'}');

      return SecurityScanResult(
        isSecure: isSecure,
        rootedDevice: isJailBroken,
        screenRecordingDetected: screenRecordingDetected,
        isEmulator: !isRealDevice,
        devModeEnabled: isDevMode,
      );
    } catch (e) {
      AppLogger.error('Security scan failed: $e');
      return SecurityScanResult(
        isSecure: false,
        scanError: e.toString(),
      );
    }
  }

  Future<void> preventScreenshots() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
        AppLogger.debug('Screenshot prevention enabled (Android)');
      } catch (e) {
        AppLogger.error('Failed to prevent screenshots: $e');
      }
    }
    // Note: iOS handles FLAG_SECURE equivalent differently (mostly system managed)
  }

  Future<void> allowScreenshots() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
        AppLogger.debug('Screenshot prevention disabled (Android)');
      } catch (e) {
        AppLogger.error('Failed to allow screenshots: $e');
      }
    }
  }

  Future<Map<String, dynamic>> getSecurityStatus() async {
    final scanResult = await performSecurityScan();

    return {
      'overall_secure': scanResult.isSecure,
      'rooted_device': scanResult.rootedDevice,
      'is_emulator': scanResult.isEmulator,
      'dev_mode': scanResult.devModeEnabled,
      'recommendations': _getSecurityRecommendations(scanResult),
    };
  }

  List<String> _getSecurityRecommendations(SecurityScanResult result) {
    final recommendations = <String>[];

    if (result.rootedDevice) {
      recommendations.add('Device appears to be rooted/jailbroken. This app may not function properly for security reasons.');
    }

    if (result.isEmulator && const bool.fromEnvironment('dart.vm.product')) {
      recommendations.add('App is running on an emulator in production mode. This is restricted.');
    }

    if (result.devModeEnabled) {
      recommendations.add('Developer mode is enabled. Consider disabling it for better security.');
    }

    return recommendations;
  }

  // Quick security check for critical operations
  Future<bool> isEnvironmentSecure() async {
    try {
      final scanResult = await performSecurityScan();
      final bool isDebug = const bool.fromEnvironment('dart.vm.product') == false;
      
      return scanResult.isSecure && (isDebug || !scanResult.rootedDevice);
    } catch (e) {
      AppLogger.error('Environment security check failed: $e');
      return false;
    }
  }

  // Secure Network Methods for low-level requests
  final HttpClient _httpClient = HttpClient();

  Future<HttpClientResponse> secureGet(String url, {Map<String, String>? headers}) async {
    final request = await _httpClient.getUrl(Uri.parse(url));
    headers?.forEach((key, value) => request.headers.add(key, value));
    return await request.close();
  }

  Future<HttpClientResponse> securePost(String url, {Map<String, String>? headers, String? body}) async {
    final request = await _httpClient.postUrl(Uri.parse(url));
    headers?.forEach((key, value) => request.headers.add(key, value));
    if (body != null) {
      request.write(body);
    }
    return await request.close();
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
  final bool isEmulator;
  final bool devModeEnabled;
  final String? scanError;

  const SecurityScanResult({
    required this.isSecure,
    this.rootedDevice = false,
    this.screenRecordingDetected = false,
    this.isEmulator = false,
    this.devModeEnabled = false,
    this.scanError,
  });
}
