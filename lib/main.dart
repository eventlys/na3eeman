import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'config/environment.dart';
import 'Helpers/config.dart';
import 'Helpers/customized/error_reporter.dart';
import 'Helpers/logger.dart';
import 'Providers/app_providers.dart';
import 'Providers/main_providers.dart';
import 'Providers/provider_wrapper.dart';
import 'Routes/routes.dart';
import 'Services/api/api_service.dart';
import 'Services/core/performance_service.dart';
import 'Services/general_service.dart';
import 'Services/storage_service.dart';
import 'Services/ui/sidebar_navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Services/notification/fcm_service.dart';
import 'Helpers/notification_helper.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'mock-api-key',
        appId: '1:1234567890:android:mockappid',
        messagingSenderId: '1234567890',
        projectId: 'mock-project-id',
      ),
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    AppLogger.error('Firebase initialization failed: \$e');
  }

  // Initialize environment first (defaults to dev if not specified)
  await Environment.init(flavor: AppFlavor.dev);

  // Log environment info
  if (AppConfig.enableLogging) {
    AppLogger.info('=== ${AppConfig.appName} Starting ===');
    AppLogger.info('Environment: ${Environment.flavor.name}');
    AppLogger.info('API URL: ${AppConfig.baseUrl}');
    AppLogger.info('Debug Mode: ${AppConfig.showDebugBanner}');
  }

  // Initialize services in order
  await UnifiedStorageService().initialize();
  await OfflineService().initialize();

  // Only initialize crash reporting if enabled for this environment
  if (AppConfig.enableCrashReporting) {
    await CrashReportingService().initialize();
  }

  await NotificationHelper().initialize();
  await FCMService().initialize();
  await BackgroundService().initialize();

  // Setup app lifecycle
  AppLifecycleService().initialize();

  // Setup global error handling
  GlobalErrorHandler.setup();

  // Setup dependency injection
  DependencyInjection.setup();

  // Register background tasks
  BackgroundService().registerPeriodicTasks();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'assets/Lang', 
      fallbackLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ...providers,
          // Legacy points provider kept for backward compatibility
          ChangeNotifierProvider(create: (_) => PointsProvider(ApiService())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider drives the MaterialApp theme reactively
    return ShowCaseWidget(
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: AppConfig.appName,
            navigatorKey: SideNavigationService.navigatorKey,
            initialRoute: '/',
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: AppConfig.showDebugBanner,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            // ── Dynamic theme: gender accent (Pink/Navy) + brightness ──────
            theme: themeProvider.currentTheme,
            // Provide dark theme as fallback for OS-level dark mode requests
            darkTheme: themeProvider.isDark ? themeProvider.currentTheme : null,
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}

