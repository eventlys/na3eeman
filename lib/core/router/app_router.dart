import 'package:flutter/material.dart';
import '../../Routes/routes.dart';
import '../middleware/permission_guard.dart';
import '../enums/user_type.dart';

/// Central router handling role-based redirects and navigation logic.
class AppRouter {
  static final Map<String, WidgetBuilder> routes = AppRoutes.routes;

  /// Main entry point for routing after login.
  /// Routes users to correct dashboards based on role.
  static String resolveInitialRoute(UserType userType) {
    return PermissionGuard.getDashboardRoute(userType);
  }

  /// Navigates to the user's dashboard.
  static void navigateToDashboard(BuildContext context, UserType userType) {
    final route = resolveInitialRoute(userType);
    Navigator.pushReplacementNamed(context, route);
  }

  /// Global route generator (if using onGenerateRoute)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }
}
