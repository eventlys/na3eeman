import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../constants/app_roles.dart';
import '../../themes/app_theme.dart';

/// Side drawer navigation widget for Admin, Owner, and Manager roles.
/// Renders a different set of sections based on [role].
///
/// ```dart
/// AppDrawer(role: UserRole.admin, currentRoute: '/admin')
/// ```
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.role,
    this.currentRoute,
    this.userName,
    this.userEmail,
    this.avatarPath,
  });

  final UserRole role;
  final String? currentRoute;
  final String? userName;
  final String? userEmail;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bg = isDark ? AppColor.ninjaCard : AppColor.lightSurface;
    final divider = isDark ? AppColor.ninjaDivider : AppColor.lightDivider;

    return Drawer(
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          _DrawerHeader(
            role: role,
            primary: primary,
            isDark: isDark,
            userName: userName,
            userEmail: userEmail,
            avatarPath: avatarPath,
          ),
          Divider(color: divider, thickness: 1, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildSections(context, isDark, primary),
            ),
          ),
          Divider(color: divider, thickness: 1, height: 1),
          _DrawerFooter(isDark: isDark),
        ],
      ),
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    bool isDark,
    Color primary,
  ) {
    final sections = <Widget>[];

    // Super Admin sections
    if (role == UserRole.admin) {
      sections.addAll([
        _DrawerSection(
          title: "god_mode".tr(),
          items: [
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: "overview".tr(),
              route: '/admin',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.people_outline_rounded,
              label: "user_management".tr(),
              route: '/admin/users',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.account_balance_outlined,
              label: "financial_reports".tr(),
              route: '/admin/finance',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.analytics_outlined,
              label: "analytics".tr(),
              route: '/admin/analytics',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.gavel_outlined,
              label: "compliance".tr(),
              route: '/admin/compliance',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.monitor_heart_outlined,
              label: "system_health".tr(),
              route: '/admin/system',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
          ],
        ),
      ]);
    }

    // Owner + Manager sections
    if (role == UserRole.owner ||
        role == UserRole.ownerExpert ||
        role == UserRole.owner ||
        role == UserRole.manager ||
        role == UserRole.admin) {
      sections.addAll([
        _DrawerSection(
          title: "salon_management".tr(),
          items: [
            _DrawerItem(
              icon: Icons.storefront_outlined,
              label: "my_salon".tr(),
              route: '/owner',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.group_outlined,
              label: "staff".tr(),
              route: '/staff',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
            _DrawerItem(
              icon: Icons.bar_chart_outlined,
              label: "reports".tr(),
              route: '/report',
              currentRoute: currentRoute,
              primary: primary,
              isDark: isDark,
            ),
          ],
        ),
      ]);
    }

    // Common links
    sections.addAll([
      _DrawerSection(
        title: "account".tr(),
        items: [
          _DrawerItem(
            icon: Icons.person_outline_rounded,
            label: "profile".tr(),
            route: '/profile',
            currentRoute: currentRoute,
            primary: primary,
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: "settings".tr(),
            route: '/settings',
            currentRoute: currentRoute,
            primary: primary,
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.star_outline_rounded,
            label: "subscription".tr(),
            route: '/subscription/upgrade',
            currentRoute: currentRoute,
            primary: primary,
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.flag_outlined,
            label: "report_issue".tr(),
            route: '/disputes',
            currentRoute: currentRoute,
            primary: primary,
            isDark: isDark,
          ),
        ],
      ),
    ]);

    return sections;
  }
}

// ── Sub-components ───────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.role,
    required this.primary,
    required this.isDark,
    this.userName,
    this.userEmail,
    this.avatarPath,
  });
  final UserRole role;
  final Color primary;
  final bool isDark;
  final String? userName;
  final String? userEmail;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.7)],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: avatarPath != null
                ? AssetImage(avatarPath!)
                : null,
            child: avatarPath == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (userEmail != null)
                  Text(
                    userEmail!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    role.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.primary,
    required this.isDark,
    this.currentRoute,
  });
  final IconData icon;
  final String label;
  final String route;
  final String? currentRoute;
  final Color primary;
  final bool isDark;

  bool get _isSelected => currentRoute == route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: _isSelected
              ? primary
              : (isDark
                    ? AppColor.darkTextSecondary
                    : AppColor.lightTextSecondary),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: _isSelected ? FontWeight.w700 : FontWeight.w500,
            color: _isSelected
                ? primary
                : (isDark ? AppColor.darkText : AppColor.lightText),
          ),
        ),
        selected: _isSelected,
        selectedTileColor: primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        onTap: () {
          Navigator.pop(context); // close drawer
          if (currentRoute != route) {
            Navigator.pushNamed(context, route);
          }
        },
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.logout_rounded,
          size: 22,
          color: AppColor.error.withValues(alpha: 0.8),
        ),
        title: Text(
          "log_out".tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.error.withValues(alpha: 0.9),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(context, '/logout', (_) => false);
        },
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}
