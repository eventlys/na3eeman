import '../../Packages/Core/constants/app_roles.dart';
import '../../core/enums/app_enums.dart';

class RolePermissionManager {
  static bool canAccessSalonManagement(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.admin].contains(role);
  }

  static bool canEditSalonInfo(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.admin].contains(role);
  }

  static bool canDeleteSalon(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canManageInventory(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.receptionist, UserRole.admin].contains(role);
  }

  static bool canManageFinancials(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.admin].contains(role);
  }

  static bool canManageSubscriptions(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.receptionist, UserRole.admin].contains(role);
  }

  static bool canManageOffersAndAds(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.receptionist, UserRole.admin].contains(role);
  }

  static bool canViewFeedback(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.receptionist, UserRole.admin].contains(role);
  }

  static bool canManageAppointments(UserRole role) {
    // Only management can modify existing appointments of others
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.receptionist, UserRole.admin].contains(role);
  }

  static bool canBookAppointments(UserRole role) {
    // Employees cannot book appointments for themselves or others
    return role == UserRole.customer;
  }

  static bool canViewAllBarberSchedules(UserRole role) {
    return [UserRole.owner, UserRole.ownerEmployee, UserRole.ownerOwner, UserRole.receptionist, UserRole.admin].contains(role);
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
      case UserRole.ownerOwner:
        return '/management_dashboard';
      case UserRole.ownerEmployee:
      case UserRole.employee:
        return '/employee_dashboard';
      case UserRole.admin:
        return '/admin_dashboard';
      case UserRole.receptionist:
        return '/receptionist_dashboard';
      case UserRole.intern:
        return '/intern_dashboard';
      case UserRole.customer:
      default:
        return '/customer_home';
    }
  }
}
