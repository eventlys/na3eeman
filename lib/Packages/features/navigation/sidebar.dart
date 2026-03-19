import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/ui/menu_item_model.dart';
import '../../../../Providers/features/auth_provider.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/auth/role_permission_manager.dart';
import '../../../../core/theme/colors.dart';
import 'sidebar_controller.dart';
import 'widgets/animated_sidebar_item.dart';
import 'widgets/sidebar_background.dart';
import 'widgets/user_profile_section.dart';

class Sidebar extends StatelessWidget {
  final SidebarController controller;
  final double maxWidth;
  final double minWidth;
  final double widthPercentage;

  const Sidebar({
    super.key,
    required this.controller,
    this.maxWidth = 320,
    this.minWidth = 280,
    this.widthPercentage = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final double calculatedWidth = _calculateWidth(context);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double offsetMultiplier = isRtl ? 1.0 : -1.0;

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) {
        return Visibility(
          visible: controller.animation.value > 0,
          child: Stack(
            children: [
              // Overlay
              GestureDetector(
                onTap: controller.closeSidebar,
                child: Container(
                  color: Colors.black.withValues(alpha: controller.animation.value * 0.4),
                ),
              ),

              // Sidebar
              Positioned(
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                top: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(offsetMultiplier * (1 - controller.animation.value) * calculatedWidth, 0),
                  child: SizedBox(
                    width: calculatedWidth,
                    child: Material(
                      elevation: 16,
                      color: Colors.transparent,
                      child: _buildSidebarContent(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth * widthPercentage).clamp(minWidth, maxWidth);
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Stack(
      children: [
        const SidebarBackground(),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // User Profile
              UserProfileSection(controller: controller),

              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(color: AppColors.almostBlack50),
              ),
              const SizedBox(height: 16),

              // Menu Items
              Expanded(
                child: _buildMenuItems(context),
              ),

              // Footer / Branding
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NA3EMAN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Version 2.0.0',
                      style: TextStyle(color: AppColors.almostBlack300, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final role = user?.role ?? UserRole.customer;

    final List<MenuItem> menuItems = [
      if (RolePermissionManager.canViewAdminDashboard(role))
        MenuItem(
          title: 'Admin Panel',
          assetIcon: 'assets/icons/secure.png',
          delay: 0,
          onTap: () => Navigator.pushNamed(context, '/admin'),
        ),
      if (RolePermissionManager.canAccessShopManagement(role))
        MenuItem(
          title: 'Shop Dashboard',
          assetIcon: 'assets/icons/setting.png',
          delay: 1,
          onTap: () => Navigator.pushNamed(context, '/owner_dashboard'),
        ),
      if (role == UserRole.employee)
        MenuItem(
          title: 'My Schedule',
          assetIcon: 'assets/icons/plus.png',
          delay: 1,
          onTap: () => Navigator.pushNamed(context, '/employee_dashboard'),
        ),
      MenuItem(
        title: 'Settings',
        assetIcon: 'assets/icons/setting.png',
        delay: 3,
        onTap: controller.navigateToSettings,
      ),
      MenuItem(
        title: 'Favorites',
        assetIcon: 'assets/icons/heart.png',
        delay: 4,
        onTap: controller.navigateToFavorites,
      ),
      MenuItem(
        title: 'Invite Friends',
        assetIcon: 'assets/icons/plus.png',
        delay: 5,
        onTap: controller.showInviteFriends,
      ),
      MenuItem(
        title: 'Privacy Policy',
        assetIcon: 'assets/icons/lock.png',
        delay: 6,
        onTap: controller.showPrivacyPolicy,
      ),
      MenuItem(
        title: 'Logout',
        assetIcon: 'assets/icons/exit.png',
        delay: 7,
        onTap: controller.showLogoutConfirmation,
      ),
    ];


    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return AnimatedSidebarItem(
          item: item,
          animation: controller.animation,
          delay: item.delay,
        );
      },
    );
  }
}
