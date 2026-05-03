import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { dev, staging, prod }

class Environment {
  static AppFlavor _flavor = AppFlavor.dev;
  static late EnvironmentConfig _config;

  static AppFlavor get flavor => _flavor;
  static EnvironmentConfig get config => _config;

  /// Initialize the environment configuration
  static Future<void> init({required AppFlavor flavor}) async {
    _flavor = flavor;
    
    await dotenv.load(fileName: ".env");

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

  // Helper to get env variables with defaults
  static String getEnv(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
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

  // Firebase
  String get firebaseApiKey;
  String get firebaseAppId;
  String get firebaseMessagingSenderId;
  String get firebaseProjectId;

  // Dynamic Links & Contacts
  String get webAppUrl;
  String get adminEmail;
  String get supportEmail;
}

/// Development environment configuration
class DevConfig implements EnvironmentConfig {
  @override
  String get apiBaseUrl => Environment.getEnv('API_BASE_URL');

  @override
  String get appName => Environment.getEnv('APP_NAME');

  @override
  bool get showDebugBanner => false;

  @override
  bool get enableLogging => true;

  @override
  Duration get apiTimeout => const Duration(seconds: 30);

  @override
  int get maxRetries => 3;

  @override
  bool get enableBiometricAuth => true;

  @override
  bool get enableSocialLogin => true;

  @override
  bool get enableCrashReporting => false;

  @override
  bool get enableAnalytics => false;

  @override
  String? get googleClientId => Environment.getEnv('GOOGLE_CLIENT_ID');

  @override
  String? get appleClientId => Environment.getEnv('APPLE_CLIENT_ID');

  @override
  String? get stripePublishableKey => Environment.getEnv('STRIPE_PUBLISHABLE_KEY');

  @override
  String get firebaseApiKey => Environment.getEnv('FIREBASE_API_KEY');
  @override
  String get firebaseAppId => Environment.getEnv('FIREBASE_APP_ID');
  @override
  String get firebaseMessagingSenderId => Environment.getEnv('FIREBASE_MESSAGING_SENDER_ID');
  @override
  String get firebaseProjectId => Environment.getEnv('FIREBASE_PROJECT_ID');

  @override
  String get webAppUrl => Environment.getEnv('WEB_APP_URL');

  @override
  String get adminEmail => Environment.getEnv('ADMIN_EMAIL');

  @override
  String get supportEmail => Environment.getEnv('SUPPORT_EMAIL');
}

/// Staging environment configuration
class StagingConfig implements EnvironmentConfig {
  @override
  String get apiBaseUrl => Environment.getEnv('API_BASE_URL');

  @override
  String get appName => Environment.getEnv('APP_NAME');

  @override
  bool get showDebugBanner => false;

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
  bool get enableCrashReporting => true;

  @override
  bool get enableAnalytics => true;

  @override
  String? get googleClientId => Environment.getEnv('GOOGLE_CLIENT_ID');

  @override
  String? get appleClientId => Environment.getEnv('APPLE_CLIENT_ID');

  @override
  String? get stripePublishableKey => Environment.getEnv('STRIPE_PUBLISHABLE_KEY');

  @override
  String get firebaseApiKey => Environment.getEnv('FIREBASE_API_KEY');
  @override
  String get firebaseAppId => Environment.getEnv('FIREBASE_APP_ID');
  @override
  String get firebaseMessagingSenderId => Environment.getEnv('FIREBASE_MESSAGING_SENDER_ID');
  @override
  String get firebaseProjectId => Environment.getEnv('FIREBASE_PROJECT_ID');

  @override
  String get webAppUrl => Environment.getEnv('WEB_APP_URL');

  @override
  String get adminEmail => Environment.getEnv('ADMIN_EMAIL');

  @override
  String get supportEmail => Environment.getEnv('SUPPORT_EMAIL');
}

/// Production environment configuration
class ProdConfig implements EnvironmentConfig {
  @override
  String get apiBaseUrl => Environment.getEnv('API_BASE_URL');

  @override
  String get appName => Environment.getEnv('APP_NAME');

  @override
  bool get showDebugBanner => false;

  @override
  bool get enableLogging => false;

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
  String? get googleClientId => Environment.getEnv('GOOGLE_CLIENT_ID');

  @override
  String? get appleClientId => Environment.getEnv('APPLE_CLIENT_ID');

  @override
  String? get stripePublishableKey => Environment.getEnv('STRIPE_PUBLISHABLE_KEY');

  @override
  String get firebaseApiKey => Environment.getEnv('FIREBASE_API_KEY');
  @override
  String get firebaseAppId => Environment.getEnv('FIREBASE_APP_ID');
  @override
  String get firebaseMessagingSenderId => Environment.getEnv('FIREBASE_MESSAGING_SENDER_ID');
  @override
  String get firebaseProjectId => Environment.getEnv('FIREBASE_PROJECT_ID');

  @override
  String get webAppUrl => Environment.getEnv('WEB_APP_URL');

  @override
  String get adminEmail => Environment.getEnv('ADMIN_EMAIL');

  @override
  String get supportEmail => Environment.getEnv('SUPPORT_EMAIL');
}
