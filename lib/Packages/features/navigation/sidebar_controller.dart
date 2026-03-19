import 'package:flutter/material.dart';
import '../../../Services/api/auth_service.dart';
import '../../../Services/api/api_service.dart';
import '../../../Services/repositories/auth_repository.dart';
import '../../../Services/ui/overlay_service.dart';
import '../../../Services/ui/sidebar_navigation_service.dart';


class SidebarController with ChangeNotifier {
  late AnimationController _animationController;
  late Animation<double> animation;
  late final AuthService _authService;

  bool get isOpen => _animationController.isCompleted;

  void init(TickerProvider vsync) {
    _authService = AuthService(AuthRepository(ApiService())); // Initialize to prevent late initialization error
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

  void showReportShop() {
    closeSidebar();
    OverlayService.showReportShop();
  }

  void showUserReports() {
    closeSidebar();
    OverlayService.showUserReports();
  }

  void showLogoutConfirmation() {
    closeSidebar();
    OverlayService.showLogoutConfirmation(
      onConfirm: () {
        _authService.logout();
        SideNavigationService.navigateToLogin();
      },
    );
  }
}

