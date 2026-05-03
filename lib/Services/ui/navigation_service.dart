import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_roles.dart';

class NavigationService {
  static void navigateToHomeBasedOnRole(BuildContext context, String role, {String? tier}) {
    final userRole = UserRoleExtension.fromString(role);
    
    switch (userRole) {
      case UserRole.customer:
        Navigator.pushNamedAndRemoveUntil(context, '/customer_home', (route) => false);
        break;
      case UserRole.expert:
      case UserRole.artisan:
      case UserRole.ownerExpert:
      case UserRole.cofounderExpert:
      case UserRole.manager:
        Navigator.pushNamedAndRemoveUntil(context, '/expert_home', (route) => false);
        break;
      case UserRole.intern:
        Navigator.pushNamedAndRemoveUntil(context, '/intern_dashboard', (route) => false);
        break;
      case UserRole.receptionist:
        Navigator.pushNamedAndRemoveUntil(context, '/receptionist_dashboard', (route) => false);
        break;
      case UserRole.owner:
      case UserRole.cofounder:
        Navigator.pushNamedAndRemoveUntil(context, '/management_dashboard', (route) => false);
        break;
      case UserRole.admin:
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(context, '/customer_home', (route) => false);
    }
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  static void navigateToSalonDetails(BuildContext context, Map<String, dynamic> salonData) {
    Navigator.pushNamed(context, '/salon-details', arguments: {'salonData': salonData});
  }

  static void navigateToBooking(BuildContext context, Map<String, dynamic> salonData, List<Map<String, dynamic>> services) {
    Navigator.pushNamed(context, '/book-appointment', arguments: {
      'salonData': salonData,
      'selectedServices': services,
    });
  }
}
