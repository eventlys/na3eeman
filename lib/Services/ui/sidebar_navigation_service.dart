import 'package:flutter/material.dart';
import '../../Helpers/logger.dart';

class SideNavigationService {
  static final SideNavigationService _instance =
      SideNavigationService._internal();

  factory SideNavigationService() => _instance;

  SideNavigationService._internal();

  // final LoggingInterceptor _logger = LoggingInterceptor();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Navigation methods
  static void navigateToSettings() {
    _logNavigation('Settings');
    navigatorKey.currentState?.pushNamed('/settings');
  }

  static void navigateToFavorites() {
    _logNavigation('Favorites');
    navigatorKey.currentState?.pushNamed('/favorites');
  }

  static void navigateToLogin() {
    _logNavigation('Login');
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  static void navigateToProfile() {
    _logNavigation('Profile');
    navigatorKey.currentState?.pushNamed('/profile');
  }

  static void navigateToAppointments() {
    _logNavigation('Appointments');
    navigatorKey.currentState?.pushNamed('/appointments');
  }

  static void navigateToBooking() {
    _logNavigation('Booking');
    navigatorKey.currentState?.pushNamed('/booking');
  }

  static void navigateToSalonDetail(int salonId) {
    _logNavigation('Salon Detail $salonId');
    navigatorKey.currentState?.pushNamed('/salon/$salonId');
  }

  static void navigateToExpertDetail(int expertId) {
    _logNavigation('Expert Detail $expertId');
    navigatorKey.currentState?.pushNamed('/expert/$expertId');
  }

  static void navigateToLoyalty() {
    _logNavigation('Loyalty');
    navigatorKey.currentState?.pushNamed('/loyalty');
  }

  static void navigateToPaymentHistory() {
    _logNavigation('Payment History');
    navigatorKey.currentState?.pushNamed('/payment-history');
  }

  static void navigateToSubscription() {
    _logNavigation('Subscription');
    navigatorKey.currentState?.pushNamed('/subscription');
  }

  // Back navigation
  static void goBack() {
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.pop();
      _logNavigation('Back');
    }
  }

  // Replace current route
  static void replaceWith(String routeName) {
    _logNavigation('Replace with $routeName');
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  // Clear stack and navigate
  static void clearStackAndNavigate(String routeName) {
    _logNavigation('Clear stack and navigate to $routeName');
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  // Navigation with arguments
  static void navigateWithArguments(String routeName, Object arguments) {
    _logNavigation('Navigate to $routeName with arguments');
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  // Check current route
  static String? getCurrentRoute() {
    final route = navigatorKey.currentState?.widget.onGenerateRoute;
    // This would need to be implemented based on your routing setup
    return null;
  }

  // Debug method to check if navigation is working
  static void debugNavigation() {
    final instance = SideNavigationService();
    AppLogger.debug(
      '=== NAVIGATION DEBUG ===',
      extra: {
        'navigator_key_state': navigatorKey.currentState != null
            ? 'Active'
            : 'Null',
        'can_pop': navigatorKey.currentState?.canPop() ?? false,
        'current_route': getCurrentRoute(),
      },
    );
  }

  static void _logNavigation(String destination) {
    final instance = SideNavigationService();
    AppLogger.debug('Navigating to: $destination');
  }

  // Method to handle deep links
  static void handleDeepLink(Uri uri) {
    final instance = SideNavigationService();
    AppLogger.debug('Handling deep link: $uri');

    switch (uri.path) {
      case '/salon':
        final salonId = uri.queryParameters['id'];
        if (salonId != null) {
          navigateToSalonDetail(int.parse(salonId));
        }
        break;
      case '/appointment':
        final appointmentId = uri.queryParameters['id'];
        if (appointmentId != null) {
          navigateWithArguments('/appointment-detail', appointmentId);
        }
        break;
      case '/booking':
        final salonId = uri.queryParameters['salonId'];
        if (salonId != null) {
          navigateWithArguments('/booking', int.parse(salonId));
        }
        break;
      default:
        AppLogger.debug('Unknown deep link: $uri');
    }
  }

  // Method to check if user can navigate to a route (permission check)
  static Future<bool> canNavigateTo(String routeName) async {
    // Implement permission checks based on user role
    // For example, some routes might be admin-only

    const restrictedRoutes = ['/admin', '/owner-dashboard'];
    if (restrictedRoutes.contains(routeName)) {
      // Check if user has appropriate role
      return false; // Implement actual role check
    }

    return true;
  }

  // Navigation history (optional feature)
  static final List<String> _navigationHistory = [];

  static void addToHistory(String routeName) {
    _navigationHistory.add(routeName);
    // Keep only last 10 entries
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
  }

  static List<String> getNavigationHistory() {
    return List.from(_navigationHistory);
  }

  static void clearNavigationHistory() {
    _navigationHistory.clear();
  }
}
