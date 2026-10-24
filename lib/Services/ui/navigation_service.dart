// ignore_for_file: unreachable_switch_default
import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_roles.dart';
import '../../Routes/route_names.dart';

class NavigationService {
  static void navigateToHomeBasedOnRole(
    BuildContext context,
    String role, {
    String? tier,
  }) {
    final userRole = UserRoleExtension.fromString(role);

    switch (userRole) {
      case UserRole.customer:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.customerHome,
          (route) => false,
        );
        break;
      case UserRole.expert:
      case UserRole.artisan:
      case UserRole.ownerExpert:
      case UserRole.cofounderExpert:
      case UserRole.manager:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.expertHome,
          (route) => false,
        );
        break;
      case UserRole.intern:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.internDashboard,
          (route) => false,
        );
        break;
      case UserRole.receptionist:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.receptionistDashboard,
          (route) => false,
        );
        break;
      case UserRole.owner:
      case UserRole.cofounder:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.managementDashboard,
          (route) => false,
        );
        break;
      case UserRole.admin:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.admin,
          (route) => false,
        );
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.customerHome,
          (route) => false,
        );
    }
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.profile);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.settings);
  }

  static void navigateToSalonDetails(
    BuildContext context,
    Map<String, dynamic> salonData,
  ) {
    Navigator.pushNamed(
      context,
      '/salon-details',
      arguments: {'salonData': salonData},
    );
  }

  static void navigateToBooking(
    BuildContext context,
    Map<String, dynamic> salonData,
    List<Map<String, dynamic>> services,
  ) {
    Navigator.pushNamed(
      context,
      '/book-appointment',
      arguments: {'salonData': salonData, 'selectedServices': services},
    );
  }
}
