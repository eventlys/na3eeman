class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-api-url.com/api',
  );

  static const String appName = 'Na3eeman';
  static const String appVersion = '1.0.0';
  static const String environment = String.fromEnvironment(
    'APP_ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int apiMaxRetries = 3;

  // App Configuration
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableBackgroundSync = true;
  static const bool enableOfflineMode = true;

  // Cache Configuration
  static const int cacheDurationMinutes = 10;
  static const int maxCacheSize = 100;

  // Security Configuration
  static const bool enableCertificatePinning = bool.fromEnvironment('ENABLE_CERT_PINNING', defaultValue: false);
  static const bool enableBiometricAuth = true;

  // Payment Configuration
  static const String defaultCurrency = 'USD';
  static const bool enableTestPayments = bool.fromEnvironment('ENABLE_TEST_PAYMENTS', defaultValue: true);
}
