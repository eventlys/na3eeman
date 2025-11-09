import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/points_provider.dart';
import 'Routes/routes.dart';
import 'Services/sidebar_navigation_service.dart';

void main() {
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
