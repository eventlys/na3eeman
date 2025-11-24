import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Routes/routes.dart';
import 'Services/ui/sidebar_navigation_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services in order
  await LocalStorage.init();
  await OfflineService().initialize();
  await CrashReportingService().initialize();
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
        ChangeNotifierProvider(create: (_) => PointsProvider()),
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
      title: 'Na3eeman',
      navigatorKey: SideNavigationService.navigatorKey,
      initialRoute: '/login',
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
