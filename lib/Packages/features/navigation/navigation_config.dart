import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../Providers/main_providers.dart';

class NavItem {
  final String id;
  final IconData icon;
  final String route;
  final String label;

  const NavItem({
    required this.id,
    required this.icon,
    required this.route,
    required this.label,
  });
}

class NavigationConfig {
  static String getHomeRoute(AppStateProvider appStateProvider) {
    if (appStateProvider.isCustomer) {
      return '/customer_home';
    } else {
      return '/expert_home';
    }
  }

  static IconData getProfileAvatar(AppStateProvider appStateProvider) {
    return Icons.person;
  }

  static List<NavItem> getNavItems(
    AppStateProvider appStateProvider,
    String currentRoute,
    BuildContext context,
  ) {
    final allItems = [
      NavItem(
        id: 'home',
        icon: Icons.home,
        route: getHomeRoute(appStateProvider),
        label: "home".tr(),
      ),
      NavItem(
        id: 'search',
        icon: Icons.search,
        route: '/search',
        label: 'Search',
      ),
      NavItem(
        id: 'history',
        icon: Icons.access_time,
        route: '/history',
        label: "history".tr(),
      ),
      NavItem(
        id: 'admin',
        icon: Icons.admin_panel_settings,
        route: '/owner',
        label: "admin".tr(),
      ),
      NavItem(
        id: 'staff',
        icon: Icons.people,
        route: '/staff',
        label: "staff".tr(),
      ),
      NavItem(
        id: 'profile',
        icon: getProfileAvatar(appStateProvider),
        route: '/profile',
        label: "profile".tr(),
      ),
    ];

    // Filter items based on user role
    return allItems.where((item) {
      switch (item.id) {
        case 'search':
          return appStateProvider.isCustomer;
        case 'admin':
        case 'staff':
          return appStateProvider.isOwner;
        default:
          return true;
      }
    }).toList();
  }

  static bool isItemActive(
    NavItem item,
    String currentRoute,
    AppStateProvider appStateProvider,
  ) {
    if (item.id == 'home') {
      final homeRoute = getHomeRoute(appStateProvider);
      return currentRoute == homeRoute || currentRoute == '/';
    }
    return currentRoute == item.route;
  }
}
