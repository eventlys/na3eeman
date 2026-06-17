// lib/Services/service_locator.dart
import 'package:get_it/get_it.dart';

// Core Services
import './api/api_service.dart';
import './api/api_interceptor_service.dart';
import './api/throttler.dart';
import './security_service.dart';

// Business Services
import './business_service.dart'; // Consolidated business service

// UI Services
import './ui/navigation_service.dart';
import './ui/sidebar_navigation_service.dart';
import './ui/overlay_service.dart';
import './ui/theme_service.dart';
import './ui/language_service.dart';

// Repositories
import './repositories/auth_repository.dart';
import './repositories/salon_repository.dart';
// import './repositories/base_repository.dart';

// Use Cases
import './use_cases/auth_use_cases.dart';
import './use_cases/salon_use_cases.dart';
import './use_cases/appointment_use_cases.dart';

// Utility Services
import './utils/location_service.dart';
import 'analytics_service.dart';
import 'core/app_management_service.dart';
import 'storage_service.dart';
import 'utils/filters_service.dart'; // Consolidated utilities
import 'package:na3eeman/Helpers/logger.dart';

final GetIt locator = GetIt.instance;

class ServiceLocator {
  static Future<void> initialize() async {
    // Initialize storage first

    // ============ CORE SERVICES ============
    locator.registerLazySingleton(() => ApiService());
    locator.registerLazySingleton(() => ApiThrottler());
    locator.registerLazySingleton(() => SecurityService());
    locator.registerLazySingleton(() => UnifiedStorageService());
    locator.registerLazySingleton(() => AnalyticsService());

    // ============ API INTERCEPTOR ============
    locator.registerLazySingleton(
      () => ApiInterceptorService(locator.get<ApiService>()),
    );

    // ============ BUSINESS SERVICES ============
    locator.registerLazySingleton(() => BusinessService());

    // ============ STORAGE SERVICES ============

    // ============ UI SERVICES ============
    locator.registerLazySingleton(() => NavigationService());
    locator.registerLazySingleton(() => SideNavigationService());
    locator.registerLazySingleton(() => OverlayService());
    locator.registerLazySingleton(() => ThemeService());
    locator.registerLazySingleton(() => LanguageService());

    // ============ APP MANAGEMENT ============
    locator.registerLazySingleton(() => AppManagementService());

    // ============ REPOSITORIES ============
    locator.registerLazySingleton(
      () => AuthRepository(locator.get<ApiService>()),
    );

    locator.registerLazySingleton(
      () => SalonRepository(locator.get<ApiService>()),
    );

    // ============ USE CASES ============
    locator.registerLazySingleton(
      () => LoginUseCase(locator.get<AuthRepository>()),
    );

    locator.registerLazySingleton(
      () => GetSalonsUseCase(locator.get<SalonRepository>()),
    );

    locator.registerLazySingleton(
      () => AppointmentUseCases(locator.get<BusinessService>()),
    );

    // ============ UTILITY SERVICES ============
    locator.registerLazySingleton(() => LocationService());
    locator.registerLazySingleton(() => UnifiedService());

    // ============ INITIALIZE ASYNC SERVICES ============
    await locator.get<UnifiedStorageService>().initialize();
    await locator.get<AppManagementService>().initialize();
    await locator.get<LanguageService>().init();

    AppLogger.info('All services initialized successfully');
  }

  static T get<T extends Object>() => locator.get<T>();
}
