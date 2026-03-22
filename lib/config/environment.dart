/// Application Environment Configuration
///
/// This file defines the environment configuration for the app.
/// Different environments (dev, staging, prod) can be selected at build time.

enum AppFlavor { dev, staging, prod }

class Environment {
  static AppFlavor _flavor = AppFlavor.dev;
  static late EnvironmentConfig _config;

  static AppFlavor get flavor => _flavor;
  static EnvironmentConfig get config => _config;

  /// Initialize the environment configuration
  ///
  /// Call this in main() before runApp()
  ///
  /// Example:
  /// ```dart
  /// await Environment.init(flavor: AppFlavor.prod);
  /// ```
  static Future<void> init({required AppFlavor flavor}) async {
    _flavor = flavor;

    switch (flavor) {
      case AppFlavor.dev:
        _config = DevConfig();
        break;
      case AppFlavor.staging:
        _config = StagingConfig();
        break;
      case AppFlavor.prod:
        _config = ProdConfig();
        break;
    }
  }

  static bool get isDevelopment => _flavor == AppFlavor.dev;
  static bool get isStaging => _flavor == AppFlavor.staging;
  static bool get isProduction => _flavor == AppFlavor.prod;
}

/// Base configuration interface
abstract class EnvironmentConfig {
  String get apiBaseUrl;
  String get appName;
  bool get showDebugBanner;
  bool get enableLogging;
  Duration get apiTimeout;
  int get maxRetries;

  // Feature flags
  bool get enableBiometricAuth;
  bool get enableSocialLogin;
  bool get enableCrashReporting;
  bool get enableAnalytics;

  // OAuth/Social Auth
  String? get googleClientId;
  String? get appleClientId;

  // Payment
  String? get stripePublishableKey;
}

/// Development environment configuration
class DevConfig implements EnvironmentConfig {
  // --- Connection Options ---
  // 1. Android Emulator: 'http://10.0.2.2:8080/api/v1'
  // 2. iOS Simulator:   'http://localhost:8080/api/v1'
  // 3. Local LAN IP:     'http://192.168.1.90:8080/api/v1' (Change to your PC's IP)
  // 4. Remote Tunnel:   'https://xxxx.ngrok-free.app/api/v1' (Use for remote testing)
  
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    // Change this defaultValue to switch connection types
    defaultValue: 'http://192.168.1.90:8080/api/v1',
  );

  @override
  String get appName => 'Na3eeman (Dev)';

  @override
  bool get showDebugBanner => false;

  @override
  bool get enableLogging => true;

  @override
  Duration get apiTimeout => const Duration(seconds: 30);

  @override
  int get maxRetries => 3;

  // Feature flags for dev
  @override
  bool get enableBiometricAuth => true;

  @override
  bool get enableSocialLogin => true;

  @override
  bool get enableCrashReporting => false; // Don't send dev crashes to Sentry

  @override
  bool get enableAnalytics => false; // Don't track dev usage

  @override
  String? get googleClientId =>
      const String.fromEnvironment('GOOGLE_CLIENT_ID');

  @override
  String? get appleClientId => const String.fromEnvironment('APPLE_CLIENT_ID');

  @override
  String? get stripePublishableKey => const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_...', // Test key for development
  );
}

/// Staging environment configuration
class StagingConfig implements EnvironmentConfig {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://staging-api.na3eeman.com/api/v1',
  );

  @override
  String get appName => 'Na3eeman (Staging)';

  @override
  bool get showDebugBanner => true;

  @override
  bool get enableLogging => true;

  @override
  Duration get apiTimeout => const Duration(seconds: 20);

  @override
  int get maxRetries => 3;

  @override
  bool get enableBiometricAuth => true;

  @override
  bool get enableSocialLogin => true;

  @override
  bool get enableCrashReporting => true; // Log staging crashes

  @override
  bool get enableAnalytics => true; // Track staging usage

  @override
  String? get googleClientId =>
      const String.fromEnvironment('GOOGLE_CLIENT_ID');

  @override
  String? get appleClientId => const String.fromEnvironment('APPLE_CLIENT_ID');

  @override
  String? get stripePublishableKey =>
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
}

/// Production environment configuration
class ProdConfig implements EnvironmentConfig {
  @override
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.na3eeman.com/api/v1',
  );

  @override
  String get appName => 'Na3eeman';

  @override
  bool get showDebugBanner => false;

  @override
  bool get enableLogging => false; // Minimize logging in production

  @override
  Duration get apiTimeout => const Duration(seconds: 15);

  @override
  int get maxRetries => 2;

  @override
  bool get enableBiometricAuth => true;

  @override
  bool get enableSocialLogin => true;

  @override
  bool get enableCrashReporting => true;

  @override
  bool get enableAnalytics => true;

  @override
  String? get googleClientId =>
      const String.fromEnvironment('GOOGLE_CLIENT_ID');

  @override
  String? get appleClientId => const String.fromEnvironment('APPLE_CLIENT_ID');

  @override
  String? get stripePublishableKey =>
      const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
}
