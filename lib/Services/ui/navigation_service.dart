// lib/Services/ui/navigation_service.dart
import 'package:flutter/material.dart';
import '../analytics_service.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Get home route based on user role
  static String getHomeRouteBasedOnRole(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return '/owner_dashboard';
      case 'EMPLOYEE':
      case 'BARBER':
        return '/employee_dashboard';
      case 'RECEPTIONIST':
        return '/receptionist_dashboard';
      case 'INTERN':
        return '/intern_dashboard';
      case 'ADMIN':
        return '/admin';
      case 'CUSTOMER':
        return '/customer_home';
      default:
        return '/customer_home';
    }
  }

  // Navigate to home based on role
  static void navigateToHomeBasedOnRole(BuildContext context, String role) {
    try {
      final routeName = getHomeRouteBasedOnRole(role);
      Navigator.pushReplacementNamed(context, routeName);
      
      // Log navigation event
      AnalyticsService().logCustomEvent(
        name: 'navigate_to_home',
        parameters: {'role': role},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation error: ${e.toString()}')),
      );
    }
  }

  // Navigate to appointment booking
  void navigateToAppointmentBooking(BuildContext context, {
    required int shopId,
    int? barberId,
    List<Map<String, dynamic>>? services,
  }) {
    Navigator.pushNamed(
      context,
      '/book_appointment',
      arguments: {
        'shopId': shopId,
        'barberId': barberId,
        'services': services,
      },
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_booking',
      parameters: {
        'shop_id': shopId,
        'barber_id': barberId,
      },
    );
  }

  // Navigate to appointment details
  void navigateToAppointmentDetails(BuildContext context, String appointmentId) {
    Navigator.pushNamed(
      context,
      '/appointment_details',
      arguments: {'appointmentId': appointmentId},
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_appointment_details',
      parameters: {'appointment_id': appointmentId},
    );
  }

  // Navigate to loyalty page
  void navigateToLoyalty(BuildContext context, int customerId) {
    Navigator.pushNamed(
      context,
      '/loyalty',
      arguments: {'customerId': customerId},
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_loyalty',
      parameters: {'customer_id': customerId},
    );
  }

  // Navigate to free haircut redemption
  void navigateToFreeHaircutRedemption(BuildContext context, int customerId) {
    Navigator.pushNamed(
      context,
      '/free_haircut_redemption',
      arguments: {'customerId': customerId},
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_free_haircut',
      parameters: {'customer_id': customerId},
    );
  }

  // Navigate to payment
  void navigateToPayment(BuildContext context, {
    required double amount,
    required String appointmentId,
    required String paymentMethod,
  }) {
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'amount': amount,
        'appointmentId': appointmentId,
        'paymentMethod': paymentMethod,
      },
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_payment',
      parameters: {
        'amount': amount,
        'appointment_id': appointmentId,
        'payment_method': paymentMethod,
      },
    );
  }

  // Navigate to staff management
  void navigateToStaffManagement(BuildContext context, int shopId) {
    Navigator.pushNamed(
      context,
      '/staff_management',
      arguments: {'shopId': shopId},
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_staff_management',
      parameters: {'shop_id': shopId},
    );
  }

  // Navigate to inventory management
  void navigateToInventoryManagement(BuildContext context, int shopId) {
    Navigator.pushNamed(
      context,
      '/inventory_management',
      arguments: {'shopId': shopId},
    );

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_inventory',
      parameters: {'shop_id': shopId},
    );
  }

  // Navigate to subscription management
  void navigateToSubscriptionManagement(BuildContext context) {
    Navigator.pushNamed(context, '/subscription_management');

    AnalyticsService().logCustomEvent(
      name: 'navigate_to_subscription',
    );
  }

  // Generic navigation methods
  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    AnalyticsService().logCustomEvent(
      name: 'navigate_to',
      parameters: {'route': routeName},
    );
    
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  void goBack() {
    AnalyticsService().logCustomEvent(
      name: 'navigate_back',
    );
    
    navigatorKey.currentState!.pop();
  }

  // Replace current route
  Future<dynamic> replaceWith(String routeName, {dynamic arguments}) {
    AnalyticsService().logCustomEvent(
      name: 'navigate_replace',
      parameters: {'route': routeName},
    );
    
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Clear all routes and go to new route
  void clearAllAndGoTo(String routeName, {dynamic arguments}) {
    AnalyticsService().logCustomEvent(
      name: 'navigate_clear_all',
      parameters: {'route': routeName},
    );
    
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Check if can pop
  bool canPop() {
    return navigatorKey.currentState!.canPop();
  }
}
