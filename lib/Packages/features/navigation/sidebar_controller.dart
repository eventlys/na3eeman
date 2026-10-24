import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Providers/features/auth_provider.dart';
import '../../../Services/ui/overlay_service.dart';
import '../../../Services/ui/sidebar_navigation_service.dart';

class SidebarController with ChangeNotifier {
  late AnimationController _animationController;
  late Animation<double> animation;

  bool get isOpen => _animationController.isCompleted;

  void init(TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void toggleSidebar() {
    if (isOpen) {
      closeSidebar();
    } else {
      openSidebar();
    }
  }

  void openSidebar() {
    _animationController.forward();
    notifyListeners();
  }

  void closeSidebar() {
    _animationController.reverse();
    notifyListeners();
  }

  // @override
  // void dispose() {
  //   _animationController.dispose();
  // }

  // Navigation Methods
  void navigateToSettings() {
    closeSidebar();
    SideNavigationService.navigateToSettings();
  }

  void navigateToFavorites() {
    closeSidebar();
    SideNavigationService.navigateToFavorites();
  }

  // Overlay Methods
  void showPrivacyPolicy() {
    closeSidebar();
    OverlayService.showPrivacyPolicy();
  }

  void showSecurityPolicy() {
    closeSidebar();
    OverlayService.showSecurityPolicy();
  }

  void showAppRules() {
    closeSidebar();
    OverlayService.showAppRules();
  }

  void showInviteFriends() {
    closeSidebar();
    OverlayService.showInviteFriends();
  }

  void showContactUs() {
    closeSidebar();
    OverlayService.showContactUs();
  }

  void showReportSalon() {
    closeSidebar();
    OverlayService.showReportSalon();
  }

  void showUserReports() {
    closeSidebar();
    OverlayService.showUserReports();
  }

  void showFAQs() {
    closeSidebar();
    // Implementation for FAQs overlay or navigation
  }

  void showUserGuides() {
    closeSidebar();
    // Implementation for User Guides overlay or navigation
  }

  void showLogoutConfirmation() {
    closeSidebar();
    OverlayService.showLogoutConfirmation(
      onConfirm: () {
        // Logout goes through the app's AuthProvider so the full auth state
        // (user, profiles, secure storage) is cleared, not just the service.
        final context = SideNavigationService.navigatorKey.currentContext;
        if (context != null) {
          Provider.of<AuthProvider>(context, listen: false).logout();
        }
        SideNavigationService.navigateToLogin();
      },
    );
  }
}
