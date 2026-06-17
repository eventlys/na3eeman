import 'package:logger/logger.dart' as logger_pkg;

import 'config.dart';

final logger = logger_pkg.Logger(
  printer: logger_pkg.PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: logger_pkg.DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: AppConfig.isDebug ? logger_pkg.Level.debug : logger_pkg.Level.warning,
);

class AppLogger {
  static final logger_pkg.Logger _logger = logger;

  static void debug(
    String message, {
    dynamic error,
    Map<String, dynamic>? extra,
  }) {
    final formattedMessage = _buildMessage(
      '🔍 $message',
      error: error,
      extra: extra,
    );
    _logger.d(formattedMessage);
  }

  static void info(String message, {Map<String, dynamic>? extra}) {
    final formattedMessage = _buildMessage('ℹ️ $message', extra: extra);
    _logger.i(formattedMessage);
  }

  static void warning(
    String message, {
    dynamic error,
    Map<String, dynamic>? extra,
  }) {
    final formattedMessage = _buildMessage(
      '⚠️ $message',
      error: error,
      extra: extra,
    );
    _logger.w(formattedMessage);
  }

  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    final formattedMessage = _buildMessage(
      '❌ $message',
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
    _logger.e(formattedMessage, error: error, stackTrace: stackTrace);
  }

  static void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    final formattedMessage = _buildMessage(
      '💀 $message',
      error: error,
      stackTrace: stackTrace,
      extra: extra,
    );
    _logger.f(formattedMessage, error: error, stackTrace: stackTrace);
  }

  static void api(
    String method,
    String endpoint, {
    int? statusCode,
    int? durationMs,
    dynamic request,
    dynamic response,
  }) {
    final emoji = statusCode != null && statusCode >= 200 && statusCode < 300
        ? '✅'
        : '❌';
    final message =
        '$emoji API: $method $endpoint ${statusCode != null ? '($statusCode)' : ''} ${durationMs != null ? '${durationMs}ms' : ''}';

    final formattedMessage = _buildMessage(
      message,
      extra: {
        'method': method,
        'endpoint': endpoint,
        'status_code': statusCode,
        'duration_ms': durationMs,
        'request': request,
        'response': response,
      },
    );

    _logger.i(formattedMessage);
  }

  static void performance(String action, int durationMs, {String? category}) {
    final level = durationMs > 1000 ? logger_pkg.Level.warning : logger_pkg.Level.info;
    final emoji = durationMs > 1000 ? '🐌' : '⚡';
    final message = '$emoji Performance: $action - ${durationMs}ms';

    final formattedMessage = _buildMessage(
      message,
      extra: {
        'action': action,
        'duration_ms': durationMs,
        'category': category,
      },
    );

    _logger.log(level, formattedMessage);
  }

  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    final formattedMessage = _buildMessage(
      '📊 Analytics: $event',
      extra: parameters,
    );
    _logger.d(formattedMessage);
  }

  static void security(String message, {Map<String, dynamic>? extra}) {
    final formattedMessage = _buildMessage(
      '🔒 Security: $message',
      extra: extra,
    );
    _logger.w(formattedMessage);
  }

  static void navigation(String from, String to, {String? action}) {
    final message =
        '🧭 Navigation: $from → $to ${action != null ? '($action)' : ''}';
    _logger.d(message);
  }

  static StackTrace? get stackTrace => StackTrace.current;

  static String _buildMessage(
    String baseMessage, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    final buffer = StringBuffer(baseMessage);

    if (error != null) {
      buffer.write('\nError: $error');
    }

    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }

    final sanitizedExtra = _formatExtra(extra);
    if (sanitizedExtra != null && sanitizedExtra.isNotEmpty) {
      buffer.write('\nExtra: $sanitizedExtra');
    }

    return buffer.toString();
  }

  static Map<String, dynamic>? _formatExtra(Map<String, dynamic>? extra) {
    if (extra == null || extra.isEmpty) return null;

    // Remove sensitive data from logs
    final sanitized = Map<String, dynamic>.from(extra);
    const sensitiveFields = [
      'password',
      'token',
      'secret',
      'credit_card',
      'cvc',
      'authorization',
    ];

    for (final field in sensitiveFields) {
      if (sanitized.containsKey(field)) {
        sanitized[field] = '***REDACTED***';
      }
    }

    return sanitized;
  }
}
