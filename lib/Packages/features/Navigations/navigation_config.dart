import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../Providers/main_providers.dart';
import '../../../Services/enums/gender.dart';

class NavItem {
  final String id;
  final String activeIconPath;
  final String inactiveIconPath;
  final String route;
  final String label;

  const NavItem({
    required this.id,
    required this.activeIconPath,
    required this.inactiveIconPath,
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

  static String getProfileAvatar(
    AppStateProvider appStateProvider,
    bool isActive,
  ) {
    // Get gender from provider to determine avatar
    final gender = appStateProvider.userGender;

    if (isActive) {
      return gender == Gender.female
          ? 'assets/icons/avatar_female_view.png'
          : 'assets/icons/avatar_male_view.png';
    } else {
      return gender == Gender.female
          ? 'assets/icons/avatar_female.png'
          : 'assets/icons/avatar_male.png';
    }
  }

  static List<NavItem> getNavItems(
    AppStateProvider appStateProvider,
    String currentRoute,
    BuildContext context,
  ) {
    final allItems = [
      NavItem(
        id: 'home',
        activeIconPath: 'assets/icons/home_view.png',
        inactiveIconPath: 'assets/icons/home_front.png',
        route: getHomeRoute(appStateProvider),
        label: "home".tr(),
      ),
      NavItem(
        id: 'search',
        activeIconPath: 'assets/icons/search_view.png',
        inactiveIconPath: 'assets/icons/search.png',
        route: '/search',
        label: 'Search',
      ),
      NavItem(
        id: 'history',
        activeIconPath: 'assets/icons/clock_view.png',
        inactiveIconPath: 'assets/icons/clock.png',
        route: '/history',
        label: "history".tr(),
      ),
      NavItem(
        id: 'admin',
        activeIconPath: 'assets/icons/admin_view.png',
        inactiveIconPath: 'assets/icons/admin.png',
        route: '/owner',
        label: "admin".tr(),
      ),
      NavItem(
        id: 'staff',
        activeIconPath: 'assets/icons/staff_view.png',
        inactiveIconPath: 'assets/icons/staff.png',
        route: '/staff',
        label: "staff".tr(),
      ),
      NavItem(
        id: 'profile',
        activeIconPath: getProfileAvatar(
          appStateProvider,
          currentRoute == '/profile',
        ),
        inactiveIconPath: getProfileAvatar(appStateProvider, false),
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
