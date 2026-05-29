import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../Models/ui/menu_item_model.dart';
import '../../../Providers/features/auth_provider.dart';
import '../../../core/enums/app_enums.dart';
// import '../../../core/auth/role_permission_manager.dart';
import '../../../core/theme/colors.dart';
import 'sidebar_controller.dart';
import 'widgets/animated_sidebar_item.dart';
import 'widgets/sidebar_background.dart';
// import '../../../core/widgets/rules/rules_guide_sheet.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
                  color: Colors.black.withValues(
                    alpha: controller.animation.value * 0.4,
                  ),
                ),
              ),

              // Sidebar
              Positioned(
                left: isRtl ? null : 0,
                right: isRtl ? 0 : null,
                top: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(
                    offsetMultiplier *
                        (1 - controller.animation.value) *
                        calculatedWidth,
                    0,
                  ),
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
              // Menu Items
              Expanded(child: _buildMenuItems(context)),

              // Footer / Branding
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final locale = Localizations.localeOf(context).languageCode;
                        final isArabic = locale == 'ar';

                        String logoPath;
                        if (isArabic) {
                          logoPath = isDark
                              ? 'assets/images/logo_ar_dark.png'
                              : 'assets/images/logo_ar_light.png';
                        } else {
                          logoPath = isDark
                              ? 'assets/images/logo_en_dark.png'
                              : 'assets/images/logo_en_light.png';
                        }

                        return Image.asset(
                          logoPath,
                          width: 120,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData ? snapshot.data!.version : '2.0.0';
                        return Text(
                          'Version $version',
                          style: const TextStyle(
                            color: AppColors.almostBlack300,
                            fontSize: 10,
                          ),
                        );
                      },
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
    final role = user?.userRole ?? UserRole.customer;

    final List<MenuItem> allItems = [
      MenuItem(
        title: 'admin_panel'.tr(),
        assetIcon: 'assets/icons/secure.png',
        delay: 0,
        onTap: () => Navigator.pushNamed(context, '/admin'),
        requiresAuth: true,
        requiredRoles: [UserRole.admin],
      ),
      // if (role == UserRole.owner || role == UserRole.admin)
      //   MenuItem(
      //     // title: ''.tr(),
      //     // assetIcon: 'assets/icons/setting.png',
      //     // delay: 1,
      //     // onTap: () => Navigator.pushNamed(context, '/shop_details', arguments: {'id': user?.salonId ?? 1}),
      //     // requiresAuth: true,
      //     // requiredRoles: [UserRole.owner, UserRole.admin],
      //   ),
      // MenuItem(
      //   title: 'shop_dashboard'.tr(),
      //   assetIcon: 'assets/icons/shop.png',
      //   delay: 1,
      //   onTap: () => Navigator.pushNamed(context, '/shop_details', arguments: {'id': user?.salonId ?? 1}),
      //   requiresAuth: true,
      //   requiredRoles: [
      //     // UserRole.owner,
      //     UserRole.admin,
      //     UserRole.ownerExpert,
      //     // UserRole.cofounder,
      //     UserRole.cofounderExpert,
      //     // UserRole.manager
      //   ],
      // ),
      MenuItem(
        title: 'management'.tr(),
        assetIcon: 'assets/icons/setting.png',
        delay: 1,
        onTap: () => Navigator.pushNamed(context, '/management_dashboard'),
        requiresAuth: true,
        requiredRoles: [
          UserRole.admin,
          UserRole.ownerExpert,
          UserRole.cofounderExpert,
        ],
      ),
      MenuItem(
        title: 'my_times'.tr(),
        assetIcon: 'assets/icons/clock.png',
        delay: 1,
        onTap: () => Navigator.pushNamed(context, '/my_times'),
        requiresAuth: true,
        requiredRoles: [
          UserRole.expert,
          UserRole.intern,
          UserRole.ownerExpert,
          UserRole.cofounderExpert,
        ],
      ),
      // MenuItem(
      //   title: 'Data Management'.tr(),
      //   assetIcon: 'assets/icons/report.png',
      //   delay: 1,
      //   onTap: () {
      //     controller.closeSidebar();
      //     Navigator.pushNamed(context, '/management/data');
      //   },
      //   requiresAuth: true,
      //   requiredRoles: [
      //     UserRole.owner,
      //     UserRole.admin,
      //     UserRole.cofounder,
      //     UserRole.manager,
      //     UserRole.ownerExpert,
      //     UserRole.cofounderExpert
      //   ],
      // ),
      // MenuItem(
      //   title: 'Expenses'.tr(),
      //   assetIcon: 'assets/icons/money.png',
      //   delay: 1,
      //   onTap: () {
      //     controller.closeSidebar();
      //     Navigator.pushNamed(context, '/management/expenses');
      //   },
      //   requiresAuth: true,
      //   requiredRoles: [
      //     UserRole.owner,
      //     UserRole.admin,
      //     UserRole.cofounder,
      //     UserRole.manager,
      //     UserRole.ownerExpert,
      //     UserRole.cofounderExpert
      //   ],
      // ),
      // MenuItem(
      //   title: 'Payroll'.tr(),
      //   assetIcon: 'assets/icons/wallet.png',
      //   delay: 1,
      //   onTap: () {
      //     controller.closeSidebar();
      //     Navigator.pushNamed(context, '/management/payroll');
      //   },
      //   requiresAuth: true,
      //   requiredRoles: [
      //     UserRole.owner,
      //     UserRole.admin,
      //     UserRole.cofounder,
      //     UserRole.manager,
      //     UserRole.ownerExpert,
      //     UserRole.cofounderExpert
      //   ],
      // ),
      // ── Receptionist POS ─────────────────────────────────────────
      // MenuItem(
      //   title: 'pos_terminal'.tr(),
      //   assetIcon: 'assets/icons/plus.png',
      //   delay: 2,
      //   onTap: () {
      //     controller.closeSidebar();
      //     Navigator.pushNamed(context, '/pos');
      //   },
      //   requiresAuth: true,
      //   requiredRoles: [
      //     UserRole.owner,
      //     UserRole.ownerExpert,
      //     UserRole.cofounder,
      //     UserRole.cofounderExpert,
      //     UserRole.manager,
      //     UserRole.receptionist
      //   ],
      // ),
      MenuItem(
        title: 'FAQs'.tr(),
        assetIcon: 'assets/icons/info.png',
        delay: 3,
        onTap: () {
          controller.closeSidebar();
          Navigator.pushNamed(context, '/faq');
        },
      ),
      MenuItem(
        title: 'history'.tr(),
        assetIcon: 'assets/icons/info.png',
        delay: 3,
        onTap: () {
          controller.closeSidebar();
          Navigator.pushNamed(context, '/history');
        },
        requiresAuth: true,
        requiredRoles: [UserRole.customer],
      ),
      MenuItem(
        title: 'settings'.tr(),
        assetIcon: 'assets/icons/setting.png',
        delay: 4,
        onTap: controller.navigateToSettings,
      ),
      MenuItem(
        title: 'logout'.tr(),
        assetIcon: 'assets/icons/exit.png',
        delay: 5,
        onTap: controller.showLogoutConfirmation,
      ),
    ];

    final filteredItems = allItems
        .where((item) => item.isAccessible(role))
        .toList();

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
