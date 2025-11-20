import '../../../Models/olds/user_model.dart';

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
  static String getHomeRoute(User user) {
    if (user.isCustomer) {
      return '/customer_home';
    } else {
      return '/barber_home';
    }
  }

  static List<NavItem> getNavItems(User user, String currentRoute) {
    final allItems = [
      NavItem(
        id: 'home',
        activeIconPath: 'assets/icons/home_view.png',
        inactiveIconPath: 'assets/icons/home_front.png',
        route: getHomeRoute(user),
        label: 'Home',
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
        label: 'History',
      ),
      NavItem(
        id: 'admin',
        activeIconPath: 'assets/icons/admin_view.png',
        inactiveIconPath: 'assets/icons/admin.png',
        route: '/owner',
        label: 'Admin',
      ),
      NavItem(
        id: 'staff',
        activeIconPath: 'assets/icons/staff_view.png',
        inactiveIconPath: 'assets/icons/staff.png',
        route: '/staff',
        label: 'Staff',
      ),
      NavItem(
        id: 'profile',
        activeIconPath: 'assets/icons/avatar_male_view.png',
        inactiveIconPath: 'assets/icons/avatar_male.png',
        route: '/profile',
        label: 'Profile',
      ),
    ];

    // Filter items based on user role
    return allItems.where((item) {
      switch (item.id) {
        case 'search':
          return user.isCustomer;
        case 'admin':
        case 'staff':
          return user.isOwner;
        default:
          return true;
      }
    }).toList();
  }

  static bool isItemActive(NavItem item, String currentRoute, User user) {
    if (item.id == 'home') {
      final homeRoute = getHomeRoute(user);
      return currentRoute == homeRoute || currentRoute == '/';
    }
    return currentRoute == item.route;
  }
}

