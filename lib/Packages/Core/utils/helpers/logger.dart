class AppLogger {
  static const bool _isDebug = true;

  static void debug(String message) {
    if (_isDebug) print('🐛 DEBUG: $message');
  }

  static void info(String message) {
    if (_isDebug) print('💡 INFO: $message');
  }

  static void warning(String message) {
    if (_isDebug) print('⚠️ WARNING: $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDebug) {
      print('❌ ERROR: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('Stack Trace: $stackTrace');
    }
  }

  static void network(String message) {
    if (_isDebug) print('🌐 NETWORK: $message');
  }

  static void database(String message) {
    if (_isDebug) print('💾 DATABASE: $message');
  }
}
