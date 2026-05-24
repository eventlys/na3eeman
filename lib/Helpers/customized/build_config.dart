class BuildConfig {
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG',
    defaultValue: false,
  );
  static const bool isProfile = bool.fromEnvironment(
    'PROFILE',
    defaultValue: false,
  );
  static const bool isRelease = bool.fromEnvironment(
    'RELEASE',
    defaultValue: true,
  );

  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  // Feature toggles based on build type
  static bool get enableDebugTools => isDebug;
  static bool get enablePerformanceOverlay => isDebug;
  static bool get enableSlowAnimations => isDebug;
  static bool get enableDebugBanner => isDebug;

  // Logging configuration
  static bool get enableVerboseLogging => isDebug;
  static bool get enableAnalytics => true;
  static bool get enableCrashReporting => isRelease;

  // API configuration based on flavor
  static String get baseUrl {
    switch (flavor) {
      case 'development':
        return 'https://dev-api.na3eeman.com/api';
      case 'staging':
        return 'https://staging-api.na3eeman.com/api';
      case 'production':
      default:
        return 'https://api.na3eeman.com/api';
    }
  }

  // Payment configuration
  static bool get enableTestPayments => flavor != 'production';

  // Cache configuration
  static int get cacheDurationMinutes => isDebug ? 1 : 10;

  static void validate() {
    assert(() {
      // Add any build-specific validation here
      return true;
    }());
  }
}
