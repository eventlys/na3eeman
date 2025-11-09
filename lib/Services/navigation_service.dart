import 'package:flutter/material.dart';
import '../Packages/HomePages/customer_home.dart';
import '../Packages/HomePages/barber_home.dart';
import '../Packages/HomePages/admin_home.dart';

class NavigationService {
  static String getHomeRouteBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return '/customer_home';
      case 'barber':
        return '/barber_home';
      case 'owner':
        return '/owner_home';
      case 'admin':
        return '/admin_home';
      default:
        throw Exception('Unknown role: $role');
    }
  }

  static void navigateToHomeBasedOnRole(BuildContext context, String role) {
    try {
      final routeName = getHomeRouteBasedOnRole(role);
      Navigator.pushReplacementNamed(context, routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation error: ${e.toString()}')),
      );
    }
  }

  static Widget getHomeWidgetBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return const CustomerHomePage();
      case 'barber':
        return const BarberHomePage();
      case 'owner':
        return const BarberHomePage();
      case 'admin':
        return const AdminHomePage();
      default:
        throw Exception('Unknown role: $role');
    }
  }
}

