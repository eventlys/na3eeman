import 'package:flutter/foundation.dart';

class ErrorReporter {
  static final ErrorReporter _instance = ErrorReporter._internal();

  factory ErrorReporter() => _instance;

  ErrorReporter._internal();

  void reportFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      // In debug mode, simply print to console
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production, report to your error tracking service
      _reportToService(details);
    }
  }

  void reportZoneError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Zone Error: $error');
      print('Stack Trace: $stackTrace');
    } else {
      _reportToService(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Dart Zone',
        ),
      );
    }
  }

  void _reportToService(FlutterErrorDetails details) {
    final errorInfo = {
      'message': details.exception.toString(),
      'stack_trace': details.stack?.toString(),
      'library': details.library,
      'context': details.context?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class GlobalErrorHandler {
  static void setup() {
    // Capture Flutter framework errors
    FlutterError.onError = (details) {
      ErrorReporter().reportFlutterError(details);
    };

    // Capture Dart errors
    PlatformDispatcher.instance.onError = (error, stack) {
      ErrorReporter().reportZoneError(error, stack);
      return true;
    };
  }
}
