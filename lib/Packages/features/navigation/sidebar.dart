import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../Models/ui/menu_item_model.dart';
import '../../../../Providers/features/auth_provider.dart';
import '../../../../core/enums/app_enums.dart';
// import '../../../../core/auth/role_permission_manager.dart';
import '../../../../core/theme/colors.dart';
import 'sidebar_controller.dart';
import 'widgets/animated_sidebar_item.dart';
import 'widgets/sidebar_background.dart';
// import 'widgets/user_profile_section.dart';
// import 'package:na3eeman/Packages/features/owner/widgets/campaign_management_widgets.dart';

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
    final bool isRtl = Directionality.of(context).name == 'rtl';
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
              // UserProfileSection(controller: controller),

              // const SizedBox(height: 24),
              // const Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 24.0),
              //   child: Divider(color: AppColors.almostBlack50),
              // ),
              // const SizedBox(height: 16),

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
                    Text('na3eeman'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
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

    final List<MenuItem> allItems = [
      MenuItem(
        title: 'admin_panel'.tr(),
        assetIcon: 'assets/icons/secure.png',
        delay: 0,
        onTap: () => Navigator.pushNamed(context, '/admin'),
        requiresAuth: true,
        requiredRoles: [UserRole.admin],
      ),
      if (role == UserRole.owner || role == UserRole.admin)
        MenuItem(
          title: 'shop_dashboard'.tr(),
          assetIcon: 'assets/icons/setting.png',
          delay: 1,
          onTap: () => Navigator.pushNamed(context, '/shop_details', arguments: {'id': user?.shopId ?? 1}),
          requiresAuth: true,
          requiredRoles: [UserRole.owner, UserRole.admin],
        ),
      if (role == UserRole.owner || role == UserRole.admin)
        MenuItem(
          title: 'management'.tr(),
          assetIcon: 'assets/icons/setting.png',
          delay: 1,
          onTap: () => Navigator.pushNamed(context, '/management_dashboard'),
          requiresAuth: true,
          requiredRoles: [UserRole.owner, UserRole.admin],
        ),
      MenuItem(
        title: 'my_schedule'.tr(),
        assetIcon: 'assets/icons/plus.png',
        delay: 1,
        onTap: () => Navigator.pushNamed(context, '/employee_schedule'),
        requiresAuth: true,
        requiredRoles: [UserRole.employee],
      ),
      MenuItem(
        title: 'intern_activity'.tr(),
        assetIcon: 'assets/icons/setting.png',
        delay: 1,
        onTap: () {
          controller.closeSidebar();
          Navigator.pushNamed(context, '/intern_activity');
        },
        requiresAuth: true,
        requiredRoles: [UserRole.intern],
      ),
      // Owner + Receptionist ONLY: Offers Section
      MenuItem(
        title: 'active_campaigns'.tr(),
        assetIcon: 'assets/icons/plus.png',
        delay: 2,
        onTap: () {
          controller.closeSidebar();
          Navigator.pushNamed(context, '/active_campaigns');
        },
        requiresAuth: true,
        requiredRoles: [UserRole.owner, UserRole.receptionist],
      ),
      MenuItem(
        title: 'feedback'.tr(),
        assetIcon: 'assets/icons/setting.png',
        delay: 2,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('feedback_display'.tr())));
        },
        requiresAuth: true,
        requiredRoles: [UserRole.owner, UserRole.receptionist],
      ),
      MenuItem(
        title: 'settings'.tr(),
        assetIcon: 'assets/icons/setting.png',
        delay: 3,
        onTap: controller.navigateToSettings,
      ),
      MenuItem(
        title: 'tell_others'.tr(),
        assetIcon: 'assets/icons/plus.png',
        delay: 4,
        onTap: controller.showInviteFriends,
      ),
      MenuItem(
        title: 'share_link'.tr(),
        assetIcon: 'assets/icons/plus.png',
        delay: 5,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('shop_link_copied'.tr())));
        },
      ),
      MenuItem(
        title: 'privacy_policy'.tr(),
        assetIcon: 'assets/icons/lock.png',
        delay: 6,
        onTap: controller.showPrivacyPolicy,
      ),
      MenuItem(
        title: 'logout'.tr().tr(),
        assetIcon: 'assets/icons/exit.png',
        delay: 7,
        onTap: controller.showLogoutConfirmation,
      ),
    ];

    final filteredItems = allItems.where((item) => item.isAccessible(role)).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return AnimatedSidebarItem(
          item: item,
          animation: controller.animation,
          delay: index, // Apply sequential delay base on sequence
        );
      },
    );
  }
}
