import 'package:na3eeman/config/environment.dart';

/// Application Configuration
/// 
/// Unified configuration that uses the Environment system for dynamic values
/// and defines constants for static configuration.
class AppConfig {
  // API Configuration - powered by Environment
  static String get baseUrl => Environment.config.apiBaseUrl;
  static Duration get apiTimeout => Environment.config.apiTimeout;
  static int get maxRetries => Environment.config.maxRetries;

  // App Information
  static String get appName => Environment.config.appName;
  static bool get showDebugBanner => Environment.config.showDebugBanner;
  static bool get enableLogging => Environment.config.enableLogging;
  
  static const String appVersion = '1.0.0';
  static bool get isProduction => Environment.isProduction;
  static bool get isDevelopment => Environment.isDevelopment;
  static bool get isDebug => Environment.isDevelopment;

  // Feature Flags - dynamic based on environment
  static bool get enableBiometricAuth => Environment.config.enableBiometricAuth;
  static bool get enableSocialLogin => Environment.config.enableSocialLogin;
  static bool get enableCrashReporting => Environment.config.enableCrashReporting;
  static bool get enableAnalytics => Environment.config.enableAnalytics;

  // Legacy flags (can be removed after migration)
  static const bool enableBackgroundSync = true;

  // OAuth/Social Auth
  static String? get googleClientId => Environment.config.googleClientId;
  static String? get appleClientId => Environment.config.appleClientId;

  // Payment
  static String? get stripePublishableKey => Environment.config.stripePublishableKey;

  // Cache Configuration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(hours: 1);
  static const Duration cacheLongDuration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Security
  static const bool enableCertificatePinning = false; // Enable in production
  static const List<String> pinnedCertificates = [];

  // UI Configuration
  static const String defaultCurrency = 'SAR';
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'ar'];

  // Media Upload
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'heic'];

  // Loyalty Configuration
  static const int haircutsForFree = 10;
  static const int pointsPerHaircut = 100;
}
