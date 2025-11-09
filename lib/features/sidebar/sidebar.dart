import 'package:flutter/material.dart';
import 'package:na3eeman/features/sidebar/widgets/animated_sidebar_item.dart';
import '../../Models/menu_item_model.dart';
import 'sidebar_controller.dart';
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
    this.minWidth = 250,
    this.widthPercentage = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate width inside build method where context is available
    final double calculatedWidth = _calculateWidth(context);

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) {
        return Visibility(
          visible: controller.animation.value > 0,
          child: GestureDetector(
            onTap: controller.closeSidebar,
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    width: calculatedWidth,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: _buildSidebarContent(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: controller.closeSidebar,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedWidth = screenWidth * widthPercentage;
    return calculatedWidth.clamp(minWidth, maxWidth);
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Stack(
      children: [
        // Bubble Background
        const SidebarBackground(),

        // Sidebar Content
        Column(
          children: [
            SizedBox(height: 50),
            // User Profile Section
            UserProfileSection(controller: controller),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Color(0x80c25858)),
            ),

            // Menu Items
            Expanded(
              child: _buildMenuItems(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      MenuItem(
        title: 'Settings',
        assetIcon: 'assets/icons/setting.png', // Use asset image
        delay: 0,
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
        title: 'Privacy',
        assetIcon: 'assets/icons/lock.png',
        delay: 1,
        onTap: controller.showPrivacyPolicy,
      ),
      MenuItem(
        title: 'Security',
        assetIcon: 'assets/icons/secure.png',
        delay: 2,
        onTap: controller.showSecurityPolicy,
      ),
      MenuItem(
        title: 'Rules',
        assetIcon: 'assets/icons/star.png',
        delay: 3,
        onTap: controller.showAppRules,
      ),
      MenuItem(
        title: 'Contact Us',
        assetIcon: 'assets/icons/mail_view.png',
        delay: 6,
        onTap: controller.showContactUs,
      ),
      MenuItem(
        title: 'Report Shop',
        assetIcon: 'assets/icons/report.png',
        delay: 7,
        onTap: controller.showReportShop,
      ),
      MenuItem(
        title: 'User Reports',
        assetIcon: 'assets/icons/file_star.png',
        delay: 8,
        onTap: controller.showUserReports,
      ),
      MenuItem(
        title: 'Logout',
        assetIcon: 'assets/icons/exit.png',
        delay: 9,
        onTap: controller.showLogoutConfirmation,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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

