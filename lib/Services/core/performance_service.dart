import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../Helpers/logger.dart';
import 'package:easy_localization/easy_localization.dart';

class AppServicesManager {
  static final AppServicesManager _instance = AppServicesManager._internal();

  factory AppServicesManager() => _instance;

  AppServicesManager._internal();

  // Service instances
  final CrashReportingService _crashReporting = CrashReportingService();
  final NotificationService _notifications = NotificationService();
  final PerformanceMonitor _performance = PerformanceMonitor();
  final PerformanceOptimizer _optimizer = PerformanceOptimizer();

  // Service getters
  CrashReportingService get crashReporting => _crashReporting;
  NotificationService get notifications => _notifications;
  PerformanceMonitor get performance => _performance;
  PerformanceOptimizer get optimizer => _optimizer;

  bool _isInitialized = false;

  Future<void> initializeAll() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone first (needed for notifications)
      tz.initializeTimeZones();

      // Initialize services in parallel where possible
      await Future.wait([
        _crashReporting.initialize(),
        _notifications.initialize(),
      ]);

      // Start performance monitoring
      _performance.monitorMemoryUsage();

      _isInitialized = true;
      AppLogger.debug('All app services initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize app services: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    _performance.clearHistory();
    _optimizer.optimizeMemoryUsage();
    AppLogger.debug('App services disposed');
  }
}

class CrashReportingService {
  static final CrashReportingService _instance =
      CrashReportingService._internal();

  factory CrashReportingService() => _instance;

  CrashReportingService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await SentryFlutter.init((options) {
        options.dsn = 'YOUR_SENTRY_DSN_HERE';
        options.tracesSampleRate = 1.0;
        options.enableAppLifecycleBreadcrumbs = true;
        options.attachStacktrace = true;
        options.sendDefaultPii = true;
        options.enableNativeCrashHandling = true;
      });

      _setupErrorHandlers();
      _isInitialized = true;
      AppLogger.debug('Crash reporting service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize crash reporting: $e');
    }
  }

  void _setupErrorHandlers() {
    FlutterError.onError = (details) {
      AppLogger.error('Flutter error caught', error: details.exception);
      Sentry.captureException(details.exception, stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error('Platform error caught', error: error);
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };
  }

  Future<void> reportError(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
  }) async {
    try {
      AppLogger.error('Reporting error: $error', error: error);

      await Sentry.captureException(error, stackTrace: stackTrace);

      if (context != null) {
        addBreadcrumb('Error Context: $context');
      }
    } catch (e) {
      AppLogger.error('Failed to report error: $e');
    }
  }

  Future<void> logMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    try {
      await Sentry.captureMessage(message, level: level);
      AppLogger.debug('Sentry message: $message');
    } catch (e) {
      AppLogger.error('Failed to log message to Sentry: $e');
    }
  }

  void setUserContext({
    String? id,
    String? email,
    String? username,
    String? role,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      Sentry.configureScope((scope) {
        scope.setUser(
          SentryUser(
            id: id,
            email: email,
            username: username,
            data: {'role': role, ...?additionalData},
          ),
        );
      });

      AppLogger.debug('User context set for crash reporting: $id');
    } catch (e) {
      AppLogger.error('Failed to set user context: $e');
    }
  }

  void addBreadcrumb(String message, {Map<String, dynamic>? data}) {
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          data: data,
          level: SentryLevel.info,
          timestamp: DateTime.now(),
        ),
      );

      AppLogger.debug('Breadcrumb added: $message');
    } catch (e) {
      AppLogger.error('Failed to add breadcrumb: $e');
    }
  }

  // Tracking methods
  void trackFeatureUsage(
    String featureName, {
    Map<String, dynamic>? properties,
  }) {
    addBreadcrumb('Feature Used: $featureName', data: properties);
  }

  void trackApiCall(
    String endpoint,
    String method,
    int statusCode,
    int durationMs,
  ) {
    addBreadcrumb(
      'API Call: $method $endpoint',
      data: {
        'status_code': statusCode,
        'duration_ms': durationMs,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  void trackAppointmentAction(
    String action,
    String appointmentId, {
    Map<String, dynamic>? additionalData,
  }) {
    addBreadcrumb(
      'Appointment $action',
      data: {
        'appointment_id': appointmentId,
        'timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  void trackPaymentAction(
    String action,
    String paymentId,
    double amount, {
    String? method,
  }) {
    addBreadcrumb(
      'Payment $action',
      data: {
        'payment_id': paymentId,
        'amount': amount,
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  void clearUserContext() {
    try {
      Sentry.configureScope((scope) => scope.setUser(null));
      AppLogger.debug('User context cleared');
    } catch (e) {
      AppLogger.error('Failed to clear user context: $e');
    }
  }

  Future<void> testCrashReporting() async {
    try {
      await Sentry.captureMessage('Test message from Na3eeman app');
      AppLogger.debug('Crash reporting test completed');
    } catch (e) {
      AppLogger.error('Crash reporting test failed: $e');
    }
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
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
        onDidReceiveNotificationResponse: (details) {},
      );
      AppLogger.debug('Notification service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'main_channel',
            'Main Notifications',
            channelDescription: 'Main notification channel',
            importance: Importance.max,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload,
      );
      AppLogger.debug('Notification shown: $title');
    } catch (e) {
      AppLogger.error('Failed to show notification: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'scheduled_channel',
            'Scheduled Notifications'.tr(),
            channelDescription:
                'Notifications that are scheduled for a specific time'.tr(),
            importance: Importance.max,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZDate,
        notificationDetails: platformDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      AppLogger.debug('Notification scheduled: $title at $scheduledDate');
    } catch (e) {
      AppLogger.error('Failed to schedule notification: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final bool? iosResult = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return iosResult ?? true;
    } catch (e) {
      AppLogger.error('Failed to request notification permissions: $e');
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id: id);
      AppLogger.debug('Notification cancelled: $id');
    } catch (e) {
      AppLogger.error('Failed to cancel notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      AppLogger.debug('All notifications cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel all notifications: $e');
    }
  }
}

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();

  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _performanceHistory = {};
  static const int _maxHistorySize = 100;

  void startTimer(String key) {
    _timers[key] = Stopwatch()..start();
    AppLogger.debug('Performance timer started: $key');
  }

  void stopTimer(String key, {String? label}) {
    final stopwatch = _timers[key];
    if (stopwatch != null) {
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      _storePerformanceData(key, elapsed);

      if (kDebugMode) {
        print('⏱️ ${label ?? key}: ${elapsed}ms');
      }

      AppLogger.debug(
        'Performance: ${label ?? key} - ${elapsed}ms',
        extra: {'duration_ms': elapsed, 'key': key, 'label': label},
      );

      if (elapsed > 1000) {
        _logSlowOperation(key, elapsed, label);
      }

      _timers.remove(key);
    }
  }

  void _storePerformanceData(String key, int duration) {
    if (!_performanceHistory.containsKey(key)) {
      _performanceHistory[key] = [];
    }

    final history = _performanceHistory[key]!;
    history.add(duration);

    if (history.length > _maxHistorySize) {
      history.removeAt(0);
    }
  }

  void _logSlowOperation(String key, int duration, String? label) {
    AppLogger.debug(
      'Slow operation detected',
      extra: {
        'key': key,
        'label': label,
        'duration_ms': duration,
        'threshold_ms': 1000,
      },
    );
  }

  Future<T> measureFuture<T>(
    String key,
    Future<T> Function() future, {
    String? label,
  }) async {
    startTimer(key);
    try {
      final result = await future();
      stopTimer(key, label: label);
      return result;
    } catch (e) {
      stopTimer(key, label: label);
      rethrow;
    }
  }

  T measureSync<T>(String key, T Function() function, {String? label}) {
    startTimer(key);
    try {
      final result = function();
      stopTimer(key, label: label);
      return result;
    } catch (e) {
      stopTimer(key, label: label);
      rethrow;
    }
  }

  // Specialized measurement methods
  Future<T> measureApiCall<T>(
    String endpoint,
    String method,
    Future<T> Function() apiCall,
  ) async {
    return measureFuture(
      'api_${method.toLowerCase()}_${endpoint.replaceAll('/login', '_')}',
      apiCall,
      label: '$method $endpoint',
    );
  }

  Future<T> measureDatabaseOperation<T>(
    String operation,
    Future<T> Function() dbOperation,
  ) async {
    return measureFuture(
      'db_${operation.toLowerCase()}',
      dbOperation,
      label: 'Database $operation',
    );
  }

  void measureNavigation(String routeName, {String? action}) {
    final key = 'navigation_${action ?? 'to'}_${routeName.toLowerCase()}';
    startTimer(key);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      stopTimer(key, label: 'Navigation to $routeName');
    });
  }

  // Memory monitoring
  void monitorMemoryUsage() {
    AppLogger.debug('Memory monitoring initialized');
  }

  // Performance analysis
  Map<String, dynamic> getPerformanceStats(String key) {
    final history = _performanceHistory[key];
    if (history == null || history.isEmpty) {
      return {'available': false};
    }

    history.sort();
    final avg = history.reduce((a, b) => a + b) / history.length;
    final median = history[history.length ~/ 2];
    final p95 = history[(history.length * 0.95).floor()];
    final p99 = history[(history.length * 0.99).floor()];

    return {
      'available': true,
      'count': history.length,
      'average': avg.round(),
      'median': median,
      'p95': p95,
      'p99': p99,
      'min': history.first,
      'max': history.last,
      'history': history,
    };
  }

  Map<String, Map<String, dynamic>> getAllPerformanceStats() {
    final stats = <String, Map<String, dynamic>>{};
    for (final key in _performanceHistory.keys) {
      stats[key] = getPerformanceStats(key);
    }
    return stats;
  }

  void clearHistory() {
    _performanceHistory.clear();
    AppLogger.debug('Performance history cleared');
  }

  bool isPerformanceAcceptable(String key, {int thresholdMs = 1000}) {
    final stats = getPerformanceStats(key);
    if (!stats['available']) return true;

    final average = stats['average'] as int;
    return average <= thresholdMs;
  }

  void logPerformanceReport() {
    final stats = getAllPerformanceStats();
    AppLogger.debug('Performance Report', extra: stats);
  }
}

class PerformanceOptimizer {
  static final PerformanceOptimizer _instance =
      PerformanceOptimizer._internal();

  factory PerformanceOptimizer() => _instance;

  PerformanceOptimizer._internal();

  // Optimization constants
  static const Map<String, dynamic> imageOptimizationSettings = {
    'cacheWidth': 300,
    'cacheHeight': 300,
    'filterQuality': FilterQuality.medium,
  };

  static const int _pageSize = 20;
  static const int _preloadThreshold = 5;
  static const int _maxImageCacheSize = 100;

  static Map<String, dynamic> getImageOptimization(
    String imageUrl, {
    int? width,
    int? height,
  }) {
    return {
      'cacheWidth': width ?? imageOptimizationSettings['cacheWidth'],
      'cacheHeight': height ?? imageOptimizationSettings['cacheHeight'],
      'filterQuality': imageOptimizationSettings['filterQuality'],
    };
  }

  static List<dynamic> paginateList(List<dynamic> items, int page) {
    final start = page * _pageSize;
    final end = start + _pageSize;

    if (start >= items.length) {
      return [];
    }

    return items.sublist(start, end > items.length ? items.length : end);
  }

  static bool shouldLoadMore(int currentIndex, int totalItems) {
    return currentIndex >= totalItems - _preloadThreshold;
  }

  void clearImageCache() {
    try {
      imageCache.clear();
      imageCache.clearLiveImages();
      AppLogger.debug('Image cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear image cache: $e');
    }
  }

  void optimizeMemoryUsage() {
    try {
      clearImageCache();
      AppLogger.debug('Memory optimization completed');
    } catch (e) {
      AppLogger.error('Memory optimization failed: $e');
    }
  }

  static Map<String, String> getOptimizedNetworkHeaders() {
    return {
      'Accept-Encoding': 'gzip',
      'Cache-Control': 'max-age=300',
      'Connection': 'keep-alive',
    };
  }

  static List<String> getDatabaseOptimizationTips() {
    return [
      'Use indexes for frequently queried fields',
      'Batch database operations when possible',
      'Use transactions for multiple related operations',
      'Limit the amount of data retrieved in queries',
      'Cache frequently accessed data in memory',
    ];
  }

  List<String> getPerformanceRecommendations(Map<String, dynamic> metrics) {
    final recommendations = <String>[];

    final buildTime = metrics['build_time_ms'] as int? ?? 0;
    if (buildTime > 16) {
      recommendations.add(
        'Optimize widget rebuilds - current build time: ${buildTime}ms',
      );
    }

    final memoryUsage = metrics['memory_usage_mb'] as int? ?? 0;
    if (memoryUsage > 500) {
      // _warningMemoryThreshold
      recommendations.add(
        'High memory usage detected: ${memoryUsage}MB - consider optimizing images and caching',
      );
    }

    final apiResponseTime = metrics['api_response_time_ms'] as int? ?? 0;
    if (apiResponseTime > 1000) {
      recommendations.add(
        'Slow API responses: ${apiResponseTime}ms - consider implementing caching',
      );
    }

    return recommendations;
  }

  bool needsOptimization(Map<String, dynamic> metrics) {
    return getPerformanceRecommendations(metrics).isNotEmpty;
  }

  Future<void> precacheImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    try {
      for (final url in imageUrls.take(_maxImageCacheSize)) {
        try {
          final provider = NetworkImage(url);
          await precacheImage(provider, context);
        } catch (e) {
          AppLogger.error('Failed to precache image: $url - $e');
        }
      }
      AppLogger.debug('Precached ${imageUrls.length} images');
    } catch (e) {
      AppLogger.error('Image precaching failed: $e');
    }
  }
}

// UI Components
class PerformanceWidget extends StatelessWidget {
  final String name;
  final Widget child;
  final bool enabled;

  const PerformanceWidget({
    super.key,
    required this.name,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    PerformanceMonitor().startTimer('widget_build_$name');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceMonitor().stopTimer('widget_build_$name');
    });

    return child;
  }
}

class LazyLoadBuilder extends StatelessWidget {
  final int itemCount;
  final int visibleThreshold;
  final VoidCallback onLoadMore;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? placeholder;
  final bool isLoading;

  const LazyLoadBuilder({
    super.key,
    required this.itemCount,
    required this.onLoadMore,
    required this.itemBuilder,
    this.visibleThreshold = 5,
    this.placeholder,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          final metrics = scrollNotification.metrics;
          if (metrics.atEdge && metrics.pixels == metrics.maxScrollExtent) {
            onLoadMore();
          }
        }
        return false;
      },
      child: ListView.builder(
        itemCount: itemCount + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == itemCount) {
            return placeholder ??
                const Center(child: CircularProgressIndicator());
          }

          if (index >= itemCount - visibleThreshold) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore();
            });
          }

          return itemBuilder(context, index);
        },
      ),
    );
  }
}

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCache;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableCache = true,
  });

  @override
  Widget build(BuildContext context) {
    final optimization = PerformanceOptimizer.getImageOptimization(
      imageUrl,
      width: width?.toInt(),
      height: height?.toInt(),
    );

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: enableCache ? optimization['cacheWidth'] : null,
      cacheHeight: enableCache ? optimization['cacheHeight'] : null,
      filterQuality: optimization['filterQuality'],
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return placeholder ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: Colors.grey),
            );
      },
    );
  }
}

// Extensions for easy performance monitoring
extension PerformanceMonitorExtension<T> on Future<T> {
  Future<T> measure(String key, {String? label}) async {
    return PerformanceMonitor().measureFuture(key, () => this, label: label);
  }
}

extension SyncPerformanceMonitorExtension<T> on T Function() {
  T measure(String key, {String? label}) {
    return PerformanceMonitor().measureSync(key, this, label: label);
  }
}
