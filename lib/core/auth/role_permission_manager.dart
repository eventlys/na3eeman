import '../../core/enums/app_enums.dart';
// import '../../Models/auth/user_model.dart';

class RolePermissionManager {
  static bool canAccessShopManagement(UserRole role) {
    return [UserRole.owner, UserRole.admin].contains(role);
  }

  static bool canManageInventory(UserRole role) {
    return [UserRole.owner, UserRole.receptionist, UserRole.admin].contains(role);
  }

  static bool canManageFinancials(UserRole role) {
    return [UserRole.owner, UserRole.admin].contains(role);
  }

  static bool canManageAppointments(UserRole role) {
    return [
      UserRole.owner,
      UserRole.employee,
      UserRole.receptionist,
      UserRole.admin,
    ].contains(role);
  }

  static bool canViewAllBarberSchedules(UserRole role) {
    return [UserRole.owner, UserRole.receptionist, UserRole.admin].contains(role);
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
        return '/owner_dashboard';
      case UserRole.admin:
        return '/admin_dashboard';
      case UserRole.employee:
        return '/employee_dashboard';
      case UserRole.receptionist:
        return '/receptionist_dashboard';
      case UserRole.intern:
        return '/intern_dashboard';
      case UserRole.customer:
      default:
        return '/home';
    }
  }
}
