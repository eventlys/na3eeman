import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import '../analytics_service.dart';
import '../../Helpers/logger.dart';
import '../../Helpers/config.dart';
import '../security_service.dart';
import '../storage_service.dart';
import 'user_service.dart';
import '../ui/sidebar_navigation_service.dart';

class AppManagementService with WidgetsBindingObserver {
  static final AppManagementService _instance = AppManagementService._internal();

  factory AppManagementService() => _instance;

  AppManagementService._internal();

  // Lifecycle State Management
  AppLifecycleState _currentState = AppLifecycleState.resumed;
  final List<Function(AppLifecycleState)> _lifecycleListeners = [];

  // Updated Services
  final SecurityService _securityService = SecurityService();
  final UnifiedStorageService _storageService = UnifiedStorageService();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Configuration
  static String get _baseUrl => AppConfig.baseUrl;

  // Background Tasks
  static const String syncTask = 'syncData';
  static const String notificationTask = 'scheduleNotifications';
  static const String loyaltySyncTask = 'syncLoyaltyData';
  static const String appointmentReminderTask = 'appointmentReminders';

  // Lifecycle State Management
  AppLifecycleState get currentState => _currentState;

  void addLifecycleListener(Function(AppLifecycleState) listener) {
    _lifecycleListeners.add(listener);
  }

  void removeLifecycleListener(Function(AppLifecycleState) listener) {
    _lifecycleListeners.remove(listener);
  }

  // Initialization
  Future<void> initialize() async {
    try {
      // Initialize lifecycle observer
      WidgetsBinding.instance.addObserver(this);

      // Initialize storage service
      await _storageService.initialize();

      // Initialize background service
      await _initializeBackgroundService();

      // Initialize notifications
      await _initializeNotifications();

      AppLogger.debug('AppManagementService initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize AppManagementService: $e');
    }
  }

  Future<void> _initializeBackgroundService() async {
    await Workmanager().initialize(
      _backgroundTaskDispatcher,
      // isInDebugMode: BuildConfig.isDebug,
    );
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification response if needed
      },
    );
  }

  // App Lifecycle Management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _currentState = state;

    for (final listener in _lifecycleListeners) {
      listener(state);
    }

    _handleLifecycleState(state);
  }

  void _handleLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  void _onAppPaused() {
    _syncDataBeforeBackground();
    _logAnalyticsEvent('app_background');
  }

  void _onAppResumed() {
    _refreshDataOnResume();
    _logAnalyticsEvent('app_foreground');
  }

  void _onAppInactive() {
    // App is inactive but still visible
  }

  void _onAppDetached() {
    _cleanupBeforeExit();
  }

  void _onAppHidden() {
    // App is hidden
  }

  // App Update Management
  Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      final platform = _getPlatform(deviceInfo);

      AppLogger.debug('Checking for update', extra: {
        'current_version': packageInfo.version,
        'platform': platform,
      });

      // Use the new SecurityService for secure requests
      final response = await _securityService.secureGet(
        '$_baseUrl/app/version/?platform=$platform&version=${packageInfo.version}',
      );

      final responseBody = await response.transform(utf8.decoder).join();
      AppLogger.debug('Update check response: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return AppUpdateInfo.fromJson(data);
      } else {
        throw Exception('Failed to check for update: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Update check failed: $e');
      return AppUpdateInfo(
        updateAvailable: false,
        currentVersion: '1.0.0',
      );
    }
  }

  Future<void> openStore([String? updateUrl]) async {
    try {
      final url = updateUrl != null
          ? Uri.tryParse(updateUrl)
          : Uri.tryParse(_getStoreUrl());

      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch app store');
      }
    } catch (e) {
      AppLogger.error('Failed to open store: $e');
      rethrow;
    }
  }

  // Background Task Management
  void registerPeriodicTasks() {
    try {
      // Sync data every 6 hours
      Workmanager().registerPeriodicTask(
        syncTask,
        syncTask,
        frequency: const Duration(hours: 6),
        constraints: Constraints(networkType: NetworkType.connected),
      );

      // Schedule notifications daily at 9 AM
      Workmanager().registerPeriodicTask(
        notificationTask,
        notificationTask,
        frequency: const Duration(hours: 24),
        initialDelay: _calculateInitialDelay(const TimeOfDay(hour: 9, minute: 0)),
      );

      // Sync loyalty data every 12 hours
      Workmanager().registerPeriodicTask(
        loyaltySyncTask,
        loyaltySyncTask,
        frequency: const Duration(hours: 12),
        constraints: Constraints(networkType: NetworkType.connected),
      );

      // Check for appointment reminders every hour
      Workmanager().registerPeriodicTask(
        appointmentReminderTask,
        appointmentReminderTask,
        frequency: const Duration(hours: 1),
      );

      AppLogger.debug('Periodic tasks registered');
    } catch (e) {
      AppLogger.error('Failed to register periodic tasks: $e');
    }
  }

  void scheduleAppointmentReminder(String appointmentId, DateTime reminderTime) {
    try {
      final now = DateTime.now();
      final delay = reminderTime.difference(now);

      if (delay.inSeconds > 0) {
        Workmanager().registerOneOffTask(
          'appointment_reminder_$appointmentId',
          appointmentReminderTask,
          initialDelay: delay,
          inputData: {'appointment_id': appointmentId},
        );

        AppLogger.debug('Appointment reminder scheduled: $appointmentId');
      }
    } catch (e) {
      AppLogger.error('Failed to schedule appointment reminder: $e');
    }
  }

  // Deep Link Management
  Future<void> handleDeepLink(Uri uri) async {
    final path = uri.path;
    final queryParams = uri.queryParameters;

    _logAnalyticsEvent('deep_link_opened', parameters: {
      'url': uri.toString(),
      'path': path,
      'query_params': queryParams,
    });

    switch (path) {
      case '/salon':
        final salonId = queryParams['id'];
        if (salonId != null) _navigateToSalon(int.parse(salonId));
        break;
      case '/appointment':
        final appointmentId = queryParams['id'];
        if (appointmentId != null) _navigateToAppointment(appointmentId);
        break;
      case '/offer':
        final offerId = queryParams['id'];
        if (offerId != null) _navigateToOffer(offerId);
        break;
      case '/loyalty':
        final customerId = queryParams['customer_id'];
        if (customerId != null) _navigateToLoyalty(int.parse(customerId));
        break;
      case '/free_haircut':
        final customerId = queryParams['customer_id'];
        if (customerId != null) _navigateToFreeHaircut(int.parse(customerId));
        break;
      default:
        _handleUnknownDeepLink(uri);
        break;
    }
  }

  // User Service Methods
  Future<UserStatistics> getUserStatistics() async {
    try {
      AppLogger.debug('GET: {$_baseUrl/users/statistics/}');

      final response = await _securityService.secureGet('$_baseUrl/users/statistics/');
      final responseBody = await response.transform(utf8.decoder).join();
      AppLogger.debug('Response: ${response.statusCode} - $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return UserStatistics.fromJson(data);
      } else {
        throw Exception('Failed to fetch user statistics: ${response.statusCode}');
      }
    } catch (error) {
      AppLogger.error('Error fetching user statistics: $error');
      rethrow;
    }
  }

  // Private Helper Methods
  Future<void> _syncDataBeforeBackground() async {
    try {
      await _storageService.syncOfflineActions();
    } catch (e) {
      AppLogger.error('Error syncing data before background: $e');
    }
  }

  Future<void> _refreshDataOnResume() async {
    // Implement data refresh logic if needed
  }

  void _logAnalyticsEvent(String name, {Map<String, dynamic>? parameters}) {
    AnalyticsService().logCustomEvent(
      name: name,
      parameters: parameters ?? {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  String _getPlatform(dynamic deviceInfo) {
    if (deviceInfo is AndroidDeviceInfo) return 'android';
    if (deviceInfo is IosDeviceInfo) return 'ios';
    return 'unknown';
  }

  String _getStoreUrl() {
    // In a real app, you'd determine this based on platform
    return 'https://play.google.com/store/apps/details?id=com.na3eeman.app';
  }

  Duration _calculateInitialDelay(TimeOfDay notificationTime) {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year, now.month, now.day,
      notificationTime.hour, notificationTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      return scheduledTime.add(const Duration(days: 1)).difference(now);
    }

    return scheduledTime.difference(now);
  }

  // Background Task Handler
  static void _backgroundTaskDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final service = AppManagementService();

      try {
        switch (task) {
          case syncTask:
            await service._syncDataInBackground();
            break;
          case notificationTask:
            await service._scheduleNotifications();
            break;
          case loyaltySyncTask:
            await service._syncLoyaltyData();
            break;
          case appointmentReminderTask:
            await service._handleAppointmentReminders(inputData);
            break;
        }
        return Future.value(true);
      } catch (e) {
        AppLogger.error('Background task failed: $e');
        return Future.value(false);
      }
    });
  }

  // Background Task Implementations
  Future<void> _syncDataInBackground() async {
    try {
      AppLogger.debug('Starting background data sync');
      await _syncUserData();
      await _syncAppointments();
      await _syncLoyaltyData();
      AppLogger.debug('Background data sync completed');
    } catch (e) {
      AppLogger.error('Background data sync failed: $e');
    }
  }

  Future<void> _syncUserData() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _syncAppointments() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _syncLoyaltyData() async {
    try {
      AppLogger.debug('Syncing loyalty data in background');
      await Future.delayed(const Duration(seconds: 1));
      AppLogger.debug('Loyalty data sync completed');
    } catch (e) {
      AppLogger.error('Loyalty data sync failed: $e');
    }
  }

  Future<void> _scheduleNotifications() async {
    try {
      AppLogger.debug('Scheduling daily notifications');
      await _scheduleAppointmentNotifications();
      await _scheduleLoyaltyNotifications();
      AppLogger.debug('Daily notifications scheduled');
    } catch (e) {
      AppLogger.error('Notification scheduling failed: $e');
    }
  }

  Future<void> _scheduleAppointmentNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _scheduleLoyaltyNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _handleAppointmentReminders(Map<String, dynamic>? inputData) async {
    try {
      final appointmentId = inputData?['appointment_id'] as String?;
      appointmentId != null
          ? await _sendAppointmentReminder(appointmentId)
          : await _checkAllAppointmentReminders();
    } catch (e) {
      AppLogger.error('Appointment reminder handling failed: $e');
    }
  }

  Future<void> _sendAppointmentReminder(String appointmentId) async {
    try {
      const NotificationDetails platformDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'appointment_reminders',
          'Appointment Reminders',
          channelDescription: 'Reminders for upcoming appointments',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      final context = SideNavigationService.navigatorKey.currentContext;
      if (context == null) return;

      await _notifications.show(
        id: appointmentId.hashCode,
        title: "appointment_reminder".tr(),
        body: 'You have an upcoming appointment',
        notificationDetails: platformDetails,
      );

      AppLogger.debug('Appointment reminder sent: $appointmentId');
    } catch (e) {
      AppLogger.error('Failed to send appointment reminder: $e');
    }
  }

  Future<void> _checkAllAppointmentReminders() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Navigation Methods (to be implemented based on your navigation setup)
  void _navigateToSalon(int salonId) {}
  void _navigateToAppointment(String appointmentId) {}
  void _navigateToOffer(String offerId) {}
  void _navigateToLoyalty(int customerId) {}
  void _navigateToFreeHaircut(int customerId) {}

  void _handleUnknownDeepLink(Uri uri) {
    _logAnalyticsEvent('unknown_deep_link', parameters: {'url': uri.toString()});
  }

  // Cleanup
  Future<void> _cleanupBeforeExit() async {
    WidgetsBinding.instance.removeObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      AppLogger.debug('All background tasks cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel background tasks: $e');
    }
  }

  // Security service accessor
  SecurityService get securityService => _securityService;

  // Storage service accessor
  UnifiedStorageService get storageService => _storageService;
}

// Supporting Classes
class AppUpdateInfo {
  final bool updateAvailable;
  final String currentVersion;
  final String? latestVersion;
  final String? updateUrl;
  final bool isCritical;
  final String? releaseNotes;
  final String? minRequiredVersion;

  const AppUpdateInfo({
    required this.updateAvailable,
    this.currentVersion = '',
    this.latestVersion,
    this.updateUrl,
    this.isCritical = false,
    this.releaseNotes,
    this.minRequiredVersion,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      updateAvailable: json['update_available'] ?? false,
      currentVersion: json['current_version'] ?? '',
      latestVersion: json['latest_version'],
      updateUrl: json['update_url'],
      isCritical: json['is_critical'] ?? false,
      releaseNotes: json['release_notes'],
      minRequiredVersion: json['min_required_version'],
    );
  }

  bool get isUpdateRequired {
    if (minRequiredVersion == null) return false;
    return _compareVersions(currentVersion, minRequiredVersion!) < 0;
  }

  int _compareVersions(String version1, String version2) {
    final v1 = version1.split('.').map(int.parse).toList();
    final v2 = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1.length; i++) {
      if (v2.length <= i) return 1;
      if (v1[i] > v2[i]) return 1;
      if (v1[i] < v2[i]) return -1;
    }
    return 0;
  }
}
