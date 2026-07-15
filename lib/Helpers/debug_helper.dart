import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'logger.dart';

class DebugHelper {
  static final DebugHelper _instance = DebugHelper._internal();

  factory DebugHelper() => _instance;

  DebugHelper._internal();

  // Debug flags
  bool _isDebugMode = kDebugMode;
  bool _showDebugBanner = kDebugMode;
  bool _enableDebugLogging = kDebugMode;
  final bool _enablePerformanceOverlay = false;
  bool _enableSlowAnimations = false;
  final bool _showSemanticsDebugger = false;
  final bool _showPaintLayers = false;
  bool _showPerformanceOverlay = false;

  // Debug information storage
  final Map<String, dynamic> _debugInfo = {};
  final List<String> _debugLog = [];

  // Getters
  bool get isDebugMode => _isDebugMode;
  bool get showDebugBanner => _showDebugBanner;
  bool get enableDebugLogging => _enableDebugLogging;

  // Initialize debug helper
  void initialize({bool? debugMode}) {
    _isDebugMode = debugMode ?? kDebugMode;

    if (_isDebugMode) {
      AppLogger.debug('Debug helper initialized in debug mode');
      _setupDebugFeatures();
    } else {
      AppLogger.debug('Debug helper initialized in release mode');
    }
  }

  // Setup debug features
  void _setupDebugFeatures() {
    // Add debug menu if in debug mode
    _setupDebugMenu();

    // Log device information
    _logDeviceInfo();

    // Monitor performance
    _startPerformanceMonitoring();
  }

  // Setup debug menu (floating action button for debug features)
  void _setupDebugMenu() {
    // This would typically be implemented as a floating debug button
    // that shows a menu of debug options
  }

  // Log device information
  void _logDeviceInfo() async {
    try {
      // This would use DeviceInfoHelper to get device information
      AppLogger.debug('Device info logging would go here');
    } catch (e) {
      AppLogger.error('Failed to log device info', error: e);
    }
  }

  // Start performance monitoring
  void _startPerformanceMonitoring() {
    if (!_isDebugMode) return;

    // Monitor widget rebuilds
    _monitorWidgetRebuilds();

    // Monitor memory usage
    _monitorMemoryUsage();

    // Monitor API performance
    _monitorApiPerformance();
  }

  // Monitor widget rebuilds
  void _monitorWidgetRebuilds() {
    if (!_isDebugMode) return;

    // This would use a widget inspector to monitor rebuilds
    // Implementation depends on specific needs
  }

  // Monitor memory usage
  void _monitorMemoryUsage() {
    if (!_isDebugMode) return;

    // Periodic memory usage logging
    _periodicMemoryCheck();
  }

  void _periodicMemoryCheck() {
    // Check memory usage every 30 seconds in debug mode
    if (_isDebugMode) {
      Future.delayed(const Duration(seconds: 30), () {
        _logMemoryUsage();
        _periodicMemoryCheck();
      });
    }
  }

  void _logMemoryUsage() {
    // Memory usage logging would go here
    // In Flutter, you can use:
    // - WidgetsBinding.instance?.addPostFrameCallback for frame timing
    // - DevTools for detailed memory analysis
  }

  // Monitor API performance
  void _monitorApiPerformance() {
    if (!_isDebugMode) return;

    // API performance monitoring would be integrated with
    // the ApiService and LoggingInterceptor
  }

  // Debug logging methods
  void log(String message, {dynamic data, String? category}) {
    if (!_enableDebugLogging) return;

    final timestamp = DateTime.now();
    final logEntry = '[${timestamp.toIso8601String()}] $message';

    _debugLog.add(logEntry);

    if (data != null) {
      _debugLog.add('Data: $data');
    }

    // Keep log size manageable
    if (_debugLog.length > 1000) {
      _debugLog.removeRange(0, 100);
    }

    AppLogger.debug('🔧 $message', extra: {'category': category, 'data': data});
  }

  void logError(String error, {StackTrace? stackTrace, String? context}) {
    if (!_enableDebugLogging) return;

    final timestamp = DateTime.now();
    final logEntry = '[${timestamp.toIso8601String()}] ERROR: $error';

    _debugLog.add(logEntry);

    if (stackTrace != null) {
      _debugLog.add('Stack: $stackTrace');
    }

    if (context != null) {
      _debugLog.add('Context: $context');
    }

    AppLogger.error('🔧 $error', error: error, stackTrace: stackTrace);
  }

  void logPerformance(String operation, int durationMs, {String? details}) {
    if (!_enableDebugLogging) return;

    final timestamp = DateTime.now();
    final logEntry =
        '[${timestamp.toIso8601String()}] PERFORMANCE: $operation - ${durationMs}ms';

    _debugLog.add(logEntry);

    if (details != null) {
      _debugLog.add('Details: $details');
    }

    AppLogger.performance(operation, durationMs);
  }

  // Store debug information
  void storeInfo(String key, dynamic value) {
    _debugInfo[key] = {
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Retrieve debug information
  dynamic getInfo(String key) {
    return _debugInfo[key]?['value'];
  }

  // Get all debug information
  Map<String, dynamic> getAllInfo() {
    return Map.from(_debugInfo);
  }

  // Get debug log
  List<String> getDebugLog() {
    return List.from(_debugLog);
  }

  // Clear debug log
  void clearDebugLog() {
    _debugLog.clear();
  }

  // Debug widget helpers
  Widget debugBanner(Widget child, BuildContext context) {
    if (!_showDebugBanner) return child;

    return Banner(
      message: "debug".tr(),
      location: BannerLocation.topEnd,
      color: Colors.red.withValues(alpha: 0.6),
      child: child,
    );
  }

  Widget debugPaint(Widget child) {
    if (!_showPaintLayers) return child;

    return CustomPaint(painter: _DebugGridPainter(), child: child);
  }

  // Performance overlay
  Widget performanceOverlay(Widget child) {
    if (!_showPerformanceOverlay) return child;

    return Stack(
      children: [
        child,
        const Positioned.fill(child: PerformanceOverlay()),
      ],
    );
  }

  // Debug methods for development
  void simulateSlowNetwork() {
    if (!_isDebugMode) return;

    log('Slow network simulation enabled');
    // This would modify ApiService timeouts or add delays
  }

  void simulateApiErrors() {
    if (!_isDebugMode) return;

    log('API error simulation enabled');
    // This would modify ApiService to return errors
  }

  void simulateLowMemory() {
    if (!_isDebugMode) return;

    log('Low memory simulation enabled');
    // This would trigger memory warnings or simulate low memory
  }

  // Debug toggle methods
  void toggleDebugBanner() {
    _showDebugBanner = !_showDebugBanner;
    log('Debug banner ${_showDebugBanner ? 'enabled' : 'disabled'}');
  }

  void togglePerformanceOverlay() {
    _showPerformanceOverlay = !_showPerformanceOverlay;
    log(
      'Performance overlay ${_showPerformanceOverlay ? 'enabled' : 'disabled'}',
    );
  }

  void toggleSlowAnimations() {
    _enableSlowAnimations = !_enableSlowAnimations;

    // This would modify timeDilation
    if (_enableSlowAnimations) {
      timeDilation = 5.0; // 5x slower
    } else {
      timeDilation = 1.0; // Normal speed
    }

    log('Slow animations ${_enableSlowAnimations ? 'enabled' : 'disabled'}');
  }

  void toggleDebugLogging() {
    _enableDebugLogging = !_enableDebugLogging;
    log('Debug logging ${_enableDebugLogging ? 'enabled' : 'disabled'}');
  }

  // Generate debug report
  Map<String, dynamic> generateDebugReport() {
    return {
      'debug_mode': _isDebugMode,
      'timestamp': DateTime.now().toIso8601String(),
      'debug_info': getAllInfo(),
      'log_entries_count': _debugLog.length,
      'recent_log_entries': _debugLog.take(50).toList(),
      'settings': {
        'show_debug_banner': _showDebugBanner,
        'enable_debug_logging': _enableDebugLogging,
        'enable_performance_overlay': _enablePerformanceOverlay,
        'enable_slow_animations': _enableSlowAnimations,
      },
    };
  }

  // Export debug data
  String exportDebugData() {
    final report = generateDebugReport();
    return const JsonEncoder.withIndent('  ').convert(report);
  }

  // Clear all debug data
  void clearAllDebugData() {
    _debugInfo.clear();
    _debugLog.clear();
    log('All debug data cleared');
  }

  // Check if any debug features are active
  bool get hasActiveDebugFeatures {
    return _showDebugBanner ||
        _enablePerformanceOverlay ||
        _enableSlowAnimations ||
        _showSemanticsDebugger ||
        _showPaintLayers;
  }

  // Get active debug features
  List<String> getActiveDebugFeatures() {
    final features = <String>[];

    if (_showDebugBanner) features.add('Debug Banner');
    if (_enablePerformanceOverlay) features.add('Performance Overlay');
    if (_enableSlowAnimations) features.add('Slow Animations');
    if (_showSemanticsDebugger) features.add('Semantics Debugger');
    if (_showPaintLayers) features.add('Paint Layers');

    return features;
  }
}

// Debug grid painter for visual layout debugging
class _DebugGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Debug widget wrapper
class DebugWrapper extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final bool showBanner;
  final bool showPerformance;

  const DebugWrapper({
    super.key,
    required this.child,
    this.showGrid = false,
    this.showBanner = true,
    this.showPerformance = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget wrappedChild = child;

    if (showGrid) {
      wrappedChild = DebugHelper().debugPaint(wrappedChild);
    }

    if (showBanner) {
      wrappedChild = DebugHelper().debugBanner(wrappedChild, context);
    }

    if (showPerformance) {
      wrappedChild = DebugHelper().performanceOverlay(wrappedChild);
    }

    return wrappedChild;
  }
}

// Debug button for easy access to debug features
class DebugButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const DebugButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (!DebugHelper().isDebugMode) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: onPressed ?? () => _showDebugMenu(context),
      mini: true,
      backgroundColor: Colors.red,
      child: const Icon(Icons.bug_report, color: Colors.white),
    );
  }

  void _showDebugMenu(BuildContext context) {
    showDialog(context: context, builder: (context) => _DebugMenu());
  }
}

class _DebugMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final debugHelper = DebugHelper();

    return AlertDialog(
      title: Text("debug_menu".tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DebugToggle(
              title: "debug_banner".tr(),
              value: debugHelper.showDebugBanner,
              onChanged: (value) => debugHelper.toggleDebugBanner(),
            ),
            _DebugToggle(
              title: "performance_overlay".tr(),
              value: debugHelper._enablePerformanceOverlay,
              onChanged: (value) => debugHelper.togglePerformanceOverlay(),
            ),
            _DebugToggle(
              title: "slow_animations".tr(),
              value: debugHelper._enableSlowAnimations,
              onChanged: (value) => debugHelper.toggleSlowAnimations(),
            ),
            _DebugToggle(
              title: "debug_logging".tr(),
              value: debugHelper.enableDebugLogging,
              onChanged: (value) => debugHelper.toggleDebugLogging(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("close".tr()),
        ),
      ],
    );
  }
}

class _DebugToggle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DebugToggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
