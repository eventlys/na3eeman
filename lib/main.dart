// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'config/environment.dart';
import 'Helpers/config.dart';
import 'Helpers/customized/error_reporter.dart';
import 'Helpers/logger.dart';
import 'Providers/main_providers.dart';
import 'Providers/provider_wrapper.dart';
import 'Routes/routes.dart';
import 'Services/api/api_service.dart';
import 'Services/core/performance_service.dart';
import 'Services/general_service.dart';
import 'Services/storage_service.dart';
import 'Services/security_service.dart';
import 'Services/ui/sidebar_navigation_service.dart';
import 'Packages/Core/widgets/base/error_boundary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Services/notification/fcm_service.dart';
import 'Helpers/notification_helper.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize environment based on --dart-define=FLAVOR=xxx
  const flavorString = String.fromEnvironment('FLAVOR');
  final flavor = AppFlavor.values.firstWhere(
    (e) => e.name == flavorString,
    orElse: () => AppFlavor.dev,
  );

  await Environment.init(flavor: flavor);

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Environment.config.firebaseApiKey,
        appId: Environment.config.firebaseAppId,
        messagingSenderId: Environment.config.firebaseMessagingSenderId,
        projectId: Environment.config.firebaseProjectId,
      ),
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    AppLogger.error('Firebase initialization failed: $e');
  }

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

  // Security Hardening
  final securityResult = await SecurityService().performSecurityScan();
  if (!securityResult.isSecure) {
    AppLogger.warning(
      'App running in insecure environment: ${securityResult.scanError ?? "Rooted/Modified device"}',
    );
  }

  // Enable screenshot prevention for the whole app as a security baseline
  // Sensitive screens will reinforce this
  await SecurityService().allowScreenshots();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
      path: 'assets/Lang',
      fallbackLocale: const Locale('en', 'US'),
      child: MultiProvider(
        providers: [
          ...providers,
          ChangeNotifierProvider(create: (_) => PointsProvider(ApiService())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ShowcaseView.register();
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return ErrorBoundary(
          isDarkMode: themeProvider.isDark,
          userGender: themeProvider.gender,
          onRetry: () {
            Navigator.of(
              SideNavigationService.navigatorKey.currentContext!,
            ).pushReplacementNamed('/');
          },
          child: MaterialApp(
            title: AppConfig.appName,
            navigatorKey: SideNavigationService.navigatorKey,
            initialRoute: '/login',
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: AppConfig.showDebugBanner,

            // Localization Configuration
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            theme: themeProvider.currentTheme,
            darkTheme: themeProvider.isDark ? themeProvider.currentTheme : null,
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          ),
        );
      },
    );
  }
}
