import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'logger.dart';

class DeviceInfoHelper {
  static final DeviceInfoHelper _instance = DeviceInfoHelper._internal();

  factory DeviceInfoHelper() => _instance;

  DeviceInfoHelper._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  PackageInfo? _packageInfo;

  // Get comprehensive device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfo = <String, dynamic>{};

      // Get platform-specific device info
      try {
        if (Platform.isAndroid) {
          final androidInfo = await _deviceInfo.androidInfo;
          deviceInfo.addAll(_getAndroidInfo(androidInfo));
        } else if (Platform.isIOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          deviceInfo.addAll(_getIosInfo(iosInfo));
        }
      } catch (e) {
        AppLogger.error('Error getting platform device info', error: e);
      }

      // Get package info
      try {
        _packageInfo ??= await PackageInfo.fromPlatform();
        deviceInfo.addAll(_getPackageInfo(_packageInfo!));
      } catch (e) {
        AppLogger.error('Error getting package info', error: e);
      }

      // Add platform info
      deviceInfo.addAll(_getPlatformInfo());

      AppLogger.debug('Device info collected: ${deviceInfo.length} items');
      return deviceInfo;
    } catch (e) {
      AppLogger.error('Error getting device information', error: e);
      return {};
    }
  }

  // Get device ID for analytics
  Future<String?> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting device ID', error: e);
      return null;
    }
  }

  // Check device capabilities
  Future<Map<String, bool>> getDeviceCapabilities() async {
    final capabilities = <String, bool>{};

    try {
      // Check platform
      capabilities['is_android'] = Platform.isAndroid;
      capabilities['is_ios'] = Platform.isIOS;
      // capabilities['is_web'] = Platform.isWeb;
      // capabilities['is_desktop'] = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
      capabilities['is_mobile'] = Platform.isAndroid || Platform.isIOS;

      // Get more specific capabilities based on device info
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        capabilities['has_biometrics'] =
            androidInfo.version.sdkInt >= 23; // Android 6.0+
        capabilities['is_tablet'] = _isAndroidTablet(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        capabilities['has_biometrics'] =
            iosInfo.model.contains('iPhone') || iosInfo.model.contains('iPad');
        capabilities['is_tablet'] = iosInfo.model.toLowerCase().contains(
          'ipad',
        );
      }

      // General capabilities
      capabilities['has_camera'] = await _checkCameraCapability();
      capabilities['has_internet'] = await _checkInternetCapability();
      capabilities['has_storage'] = await _checkStorageCapability();

      AppLogger.debug('Device capabilities: $capabilities');
      return capabilities;
    } catch (e) {
      AppLogger.error('Error getting device capabilities', error: e);
      return capabilities;
    }
  }

  // Get app version information
  Future<Map<String, String>> getAppVersionInfo() async {
    try {
      _packageInfo ??= await PackageInfo.fromPlatform();

      return {
        'app_name': _packageInfo!.appName,
        'package_name': _packageInfo!.packageName,
        'version': _packageInfo!.version,
        'build_number': _packageInfo!.buildNumber,
      };
    } catch (e) {
      AppLogger.error('Error getting app version info', error: e);
      return {};
    }
  }

  // Check if device is a tablet
  Future<bool> isTablet() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return _isAndroidTablet(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model.toLowerCase().contains('ipad');
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking if device is tablet', error: e);
      return false;
    }
  }

  // Check if device is low-end (for performance optimization)
  Future<bool> isLowEndDevice() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.sdkInt <= 23 || // Android 6.0 or below
            androidInfo.systemFeatures.length < 10; // Limited features
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model.contains('iPhone6') ||
            iosInfo.model.contains('iPhone7') ||
            iosInfo.model.contains('iPad4') ||
            iosInfo.model.contains('iPad5');
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking if device is low-end', error: e);
      return false;
    }
  }

  // Get screen size category
  String getScreenSizeCategory(double width, double height) {
    final screenSize = width * height;

    if (screenSize > 2000000) return 'xlarge'; // Tablets and large devices
    if (screenSize > 1000000) return 'large'; // Phablets
    if (screenSize > 500000) return 'medium'; // Normal phones
    return 'small'; // Small phones
  }

  // Check for specific device features
  Future<bool> hasFeature(String feature) async {
    final capabilities = await getDeviceCapabilities();
    return capabilities[feature] ?? false;
  }

  // Get device information for crash reporting
  Future<Map<String, dynamic>> getCrashReportInfo() async {
    final deviceInfo = await getDeviceInfo();

    return {
      'device': deviceInfo,
      'platform': _getPlatformInfo(),
      'app': await getAppVersionInfo(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Private helper methods
  Map<String, dynamic> _getAndroidInfo(AndroidDeviceInfo androidInfo) {
    return {
      'platform': 'android',
      'device_id': androidInfo.id,
      'device_model': androidInfo.model,
      'device_brand': androidInfo.brand,
      'device_product': androidInfo.product,
      'device_board': androidInfo.board,
      'device_manufacturer': androidInfo.manufacturer,
      'android_version': androidInfo.version.release,
      'android_sdk_version': androidInfo.version.sdkInt,
      'android_codename': androidInfo.version.codename,
      'android_base_os': androidInfo.version.baseOS,
      'android_preview_sdk': androidInfo.version.previewSdkInt,
      'android_security_patch': androidInfo.version.securityPatch,
      'device_host': androidInfo.host,
      'device_fingerprint': androidInfo.fingerprint,
      'device_hardware': androidInfo.hardware,
      'device_tags': androidInfo.tags,
      'device_type': androidInfo.type,
      'device_is_physical': androidInfo.isPhysicalDevice,
      'device_system_features': androidInfo.systemFeatures,
      'device_display': androidInfo.display,
      'device_bootloader': androidInfo.bootloader,
    };
  }

  Map<String, dynamic> _getIosInfo(IosDeviceInfo iosInfo) {
    return {
      'platform': 'ios',
      'device_id': iosInfo.identifierForVendor,
      'device_name': iosInfo.name,
      'device_model': iosInfo.model,
      'device_utsname': iosInfo.utsname.machine,
      'ios_version': iosInfo.systemVersion,
      'device_is_physical': iosInfo.isPhysicalDevice,
      'device_localized_model': iosInfo.localizedModel,
      'device_system_name': iosInfo.systemName,
    };
  }

  Map<String, dynamic> _getPackageInfo(PackageInfo packageInfo) {
    return {
      'app_name': packageInfo.appName,
      'package_name': packageInfo.packageName,
      'version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
    };
  }

  Map<String, dynamic> _getPlatformInfo() {
    return {
      'platform_operating_system': Platform.operatingSystem,
      'platform_operating_system_version': Platform.operatingSystemVersion,
      'platform_local_hostname': Platform.localHostname,
      'platform_number_of_processors': Platform.numberOfProcessors,
      'platform_path_separator': Platform.pathSeparator,
      'platform_version': Platform.version,
    };
  }

  bool _isAndroidTablet(AndroidDeviceInfo androidInfo) {
    // Various heuristics to detect tablets on Android
    final model = androidInfo.model.toLowerCase();
    final isTabletModel =
        model.contains('tab') ||
        model.contains('pad') ||
        model.contains('tablet');

    // Check screen size through system features
    final hasLargeScreen =
        androidInfo.systemFeatures.contains('android.hardware.touchscreen') &&
        androidInfo.systemFeatures.contains('android.hardware.wifi');

    return isTabletModel || hasLargeScreen;
  }

  Future<bool> _checkCameraCapability() async {
    // This would typically use camera plugin to check availability
    // For now, assume most devices have cameras
    return true;
  }

  Future<bool> _checkInternetCapability() async {
    // This would check network connectivity
    // For now, assume devices can connect to internet
    return true;
  }

  Future<bool> _checkStorageCapability() async {
    // This would check available storage
    // For now, assume devices have storage
    return true;
  }
}
