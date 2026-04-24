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

final GetIt serviceLocator = GetIt.instance;

class ServiceLocator {
  static Future<void> initialize() async {
    // Initialize storage first

    // ============ CORE SERVICES ============
    serviceLocator.registerLazySingleton(() => ApiService());
    serviceLocator.registerLazySingleton(() => ApiThrottler());
    serviceLocator.registerLazySingleton(() => SecurityService());
    serviceLocator.registerLazySingleton(() => UnifiedStorageService());
    serviceLocator.registerLazySingleton(() => AnalyticsService());

    // ============ API INTERCEPTOR ============
    serviceLocator.registerLazySingleton(() => ApiInterceptorService(
      serviceLocator.get<ApiService>(),
    ));

    // ============ BUSINESS SERVICES ============
    serviceLocator.registerLazySingleton(() => BusinessService());

    // ============ STORAGE SERVICES ============

    // ============ UI SERVICES ============
    serviceLocator.registerLazySingleton(() => NavigationService());
    serviceLocator.registerLazySingleton(() => SideNavigationService());
    serviceLocator.registerLazySingleton(() => OverlayService());
    serviceLocator.registerLazySingleton(() => ThemeService());
    serviceLocator.registerLazySingleton(() => LanguageService());

    // ============ APP MANAGEMENT ============
    serviceLocator.registerLazySingleton(() => AppManagementService());

    // ============ REPOSITORIES ============
    serviceLocator.registerLazySingleton(() => AuthRepository(
      serviceLocator.get<ApiService>(),
    ));

    serviceLocator.registerLazySingleton(() => SalonRepository(
      serviceLocator.get<ApiService>(),
    ));

    // ============ USE CASES ============
    serviceLocator.registerLazySingleton(() => LoginUseCase(
      serviceLocator.get<AuthRepository>(),
    ));

    serviceLocator.registerLazySingleton(() => GetSalonsUseCase(
      serviceLocator.get<SalonRepository>(),
    ));

    serviceLocator.registerLazySingleton(() => AppointmentUseCases(
      serviceLocator.get<BusinessService>(),
    ));

    // ============ UTILITY SERVICES ============
    serviceLocator.registerLazySingleton(() => LocationService());
    serviceLocator.registerLazySingleton(() => UnifiedService());

    // ============ INITIALIZE ASYNC SERVICES ============
    await serviceLocator.get<UnifiedStorageService>().initialize();
    await serviceLocator.get<AppManagementService>().initialize();
    await serviceLocator.get<LanguageService>().init();

    print('✅ All services initialized successfully');
  }

  static T get<T extends Object>() => serviceLocator.get<T>();
}
