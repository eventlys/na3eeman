import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../constants/app_color.dart';
import 'package:easy_localization/easy_localization.dart';

/// Navigation item data model.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
  });
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;
}

/// Redesigned bottom navigation bar using Material 3 NavigationBar.
/// Adapts colours from the active gender theme automatically.
///
/// ```dart
/// AppBottomNavBar(
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
///   items: customerNavItems,
/// )
/// ```
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  // ── Predefined item sets ──────────────────────────────────────────────────

  static final List<AppNavItem> customerItems = [
    AppNavItem(
      label: 'home'.tr(),
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: '/customer_home',
    ),
    AppNavItem(
      label: 'shops'.tr(),
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      route: '/shops',
    ),
    AppNavItem(
      label: 'bookings'.tr(),
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      route: '/appointments',
    ),
    AppNavItem(
      label: 'favourites'.tr(),
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite_rounded,
      route: '/favorites',
    ),
    AppNavItem(
      label: 'profile'.tr(),
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: '/profile',
    ),
  ];

  static List<AppNavItem> barberItems = [
    AppNavItem(
      label: 'home'.tr(),
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: '/barber_home',
    ),
    AppNavItem(
      label: 'bookings'.tr(),
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      route: '/appointments',
    ),
    AppNavItem(
      label: 'history'.tr(),
      icon: Icons.history_rounded,
      route: '/history',
    ),
    AppNavItem(
      label: 'profile'.tr(),
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColor.ninjaCard : AppColor.lightSurface,
        boxShadow: [
          BoxShadow(
            color: AppColor.dark.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == i;
              return _NavItem(
                item: item,
                isSelected: isSelected,
                primary: primary,
                isDark: isDark,
                onTap: () => onTap(i),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });
  final AppNavItem item;
  final bool isSelected;
  final Color primary;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = isDark
        ? AppColor.darkTextHint
        : AppColor.lightTextHint;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                key: ValueKey(isSelected),
                size: 24,
                color: isSelected ? primary : unselectedColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? primary : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
