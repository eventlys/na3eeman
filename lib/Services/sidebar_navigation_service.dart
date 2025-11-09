import 'package:flutter/material.dart';

class SideNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToSettings() {
    print('Navigating to Settings...');
    navigatorKey.currentState?.pushNamed('/settings');
  }

  static void navigateToFavorites() {
    print('Navigating to Favorites...');
    navigatorKey.currentState?.pushNamed('/favorites');
  }

  static void navigateToLogin() {
    print('Navigating to Login...');
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static void navigateToProfile() {
    print('Navigating to Profile...');
    navigatorKey.currentState?.pushNamed('/profile');
  }

  // Debug method to check if navigation is working
  static void debugNavigation() {
    print('=== NAVIGATION DEBUG ===');
    print('Navigator key state: ${navigatorKey.currentState}');
    print('Can pop: ${navigatorKey.currentState?.canPop()}');
    print('Current route: ${navigatorKey.currentState?.widget.initialRoute}');
  }
}

