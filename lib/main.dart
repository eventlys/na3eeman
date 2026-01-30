import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import 'Services/ui/sidebar_navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  
  await NotificationService().initialize();
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointsProvider(ApiService())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      navigatorKey: SideNavigationService.navigatorKey,
      initialRoute: '/login',
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: AppConfig.showDebugBanner,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
