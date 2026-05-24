import 'package:permission_handler/permission_handler.dart';

import 'logger.dart';

class PermissionHelper {
  static final PermissionHelper _instance = PermissionHelper._internal();

  factory PermissionHelper() => _instance;

  PermissionHelper._internal();

  // Check permission status
  Future<PermissionStatus> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      AppLogger.debug('Permission ${permission.toString()} status: $status');
      return status;
    } catch (e) {
      AppLogger.error(
        'Failed to check permission ${permission.toString()}',
        error: e,
      );
      return PermissionStatus.denied;
    }
  }

  // Request permission
  Future<PermissionStatus> requestPermission(Permission permission) async {
    try {
      final status = await permission.request();
      AppLogger.debug(
        'Permission ${permission.toString()} request result: $status',
      );
      return status;
    } catch (e) {
      AppLogger.error(
        'Failed to request permission ${permission.toString()}',
        error: e,
      );
      return PermissionStatus.denied;
    }
  }

  // Check and request permission if needed
  Future<PermissionStatus> checkAndRequestPermission(
    Permission permission,
  ) async {
    final status = await checkPermission(permission);

    if (status.isGranted) {
      return status;
    }

    return await requestPermission(permission);
  }

  // Check multiple permissions
  Future<Map<Permission, PermissionStatus>> checkPermissions(
    List<Permission> permissions,
  ) async {
    try {
      final statuses = await permissions.request();
      AppLogger.debug('Multiple permissions checked: $statuses');
      return statuses;
    } catch (e) {
      AppLogger.error('Failed to check multiple permissions', error: e);
      return {
        for (var permission in permissions) permission: PermissionStatus.denied,
      };
    }
  }

  // App-specific permission methods
  Future<bool> hasLocationPermission() async {
    final status = await checkPermission(Permission.location);
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await requestPermission(Permission.location);
    return status.isGranted;
  }

  Future<bool> hasCameraPermission() async {
    final status = await checkPermission(Permission.camera);
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await requestPermission(Permission.camera);
    return status.isGranted;
  }

  Future<bool> hasStoragePermission() async {
    final status = await checkPermission(Permission.storage);
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await requestPermission(Permission.storage);
    return status.isGranted;
  }

  Future<bool> hasNotificationPermission() async {
    final status = await checkPermission(Permission.notification);
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await requestPermission(Permission.notification);
    return status.isGranted;
  }

  Future<bool> hasMicrophonePermission() async {
    final status = await checkPermission(Permission.microphone);
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await requestPermission(Permission.microphone);
    return status.isGranted;
  }

  // Check if permission is permanently denied
  Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    final status = await checkPermission(permission);
    return status.isPermanentlyDenied;
  }

  // Open app settings for permission management
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      AppLogger.debug('App settings opened');
    } catch (e) {
      AppLogger.error('Failed to open app settings', error: e);
    }
  }

  // Check if we should show permission rationale
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async {
    final status = await checkPermission(permission);
    return status.isDenied || status.isRestricted;
  }

  // Get permission description for user-facing messages
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.location:
        return 'Location access is needed to find nearby expert salons and provide accurate service recommendations.';
      case Permission.camera:
        return 'Camera access is needed to take photos for reviews and profile pictures.';
      case Permission.storage:
        return 'Storage access is needed to save appointment receipts and download reports.';
      case Permission.notification:
        return 'Notifications are needed to receive appointment reminders and special offers.';
      case Permission.microphone:
        return 'Microphone access is needed for voice notes in reviews (if applicable).';
      default:
        return 'This permission is needed for the app to function properly.';
    }
  }

  // Bulk permission check for app features
  Future<Map<String, bool>> checkRequiredPermissions() async {
    final permissions = {
      'location': await hasLocationPermission(),
      'camera': await hasCameraPermission(),
      'storage': await hasStoragePermission(),
      'notifications': await hasNotificationPermission(),
    };

    AppLogger.debug('Required permissions status: $permissions');
    return permissions;
  }

  // Check if all required permissions are granted
  Future<bool> hasAllRequiredPermissions() async {
    final permissions = await checkRequiredPermissions();
    return permissions.values.every((isGranted) => isGranted);
  }

  // Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    try {
      final results = await permissions.request();
      AppLogger.debug('Multiple permissions requested: $results');
      return results;
    } catch (e) {
      AppLogger.error('Failed to request multiple permissions', error: e);
      rethrow;
    }
  }
}
