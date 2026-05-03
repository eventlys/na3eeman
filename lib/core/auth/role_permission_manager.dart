import '../../Packages/Core/constants/app_roles.dart';
import '../../core/enums/app_enums.dart';

class RolePermissionManager {
  static bool canAccessSalonManagement(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.admin;
  }

  static bool canEditSalonInfo(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.admin;
  }

  static bool canDeleteSalon(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canManageInventory(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.receptionist || role == UserRole.admin;
  }

  static bool canManageFinancials(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.admin;
  }

  static bool canManageSubscriptions(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.receptionist || role == UserRole.admin;
  }

  static bool canManageOffersAndAds(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.receptionist || role == UserRole.admin;
  }

  static bool canViewFeedback(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.receptionist || role == UserRole.admin;
  }

  static bool canManageAppointments(UserRole role) {
    // Only management can modify existing appointments of others
    return role.isOwnerEquivalent || role == UserRole.receptionist || role == UserRole.admin;
  }

  static bool canBookAppointments(UserRole role) {
    // Experts cannot book appointments for themselves or others
    return role == UserRole.customer;
  }

  static bool canViewAllExpertSchedules(UserRole role) {
    return role.isOwnerEquivalent || role == UserRole.receptionist || role == UserRole.admin;
  }

  static bool canViewAdminDashboard(UserRole role) {
    return role == UserRole.admin;
  }

  static bool isStaff(UserRole role) {
    return role != UserRole.customer;
  }

  static String getDefaultRoute(UserRole role) {
    switch (role) {
      case UserRole.owner:
      case UserRole.cofounder:
      case UserRole.manager:
      case UserRole.receptionist:
        return '/management_dashboard';
      case UserRole.ownerExpert:
      case UserRole.cofounderExpert:
      case UserRole.expert:
      case UserRole.artisan:
        return '/expert_dashboard';
      case UserRole.admin:
        return '/admin';
      case UserRole.intern:
        return '/intern_dashboard';
      case UserRole.customer:
      default:
        return '/customer_home';
    }
  }
}
