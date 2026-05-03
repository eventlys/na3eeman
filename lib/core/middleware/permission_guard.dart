import '../enums/user_type.dart';

/// Middleware to enforce role-based permissions and booking restrictions.
class PermissionGuard {
  /// Enforces booking restrictions:
  /// - Customers CANNOT book: Owner, CoFounder, Receptionist, Intern
  /// - Customers CAN ONLY book: OwnerExpert, CoFounderExpert, Expert, Artisan
  static bool canCustomerBook(UserType expertType) {
    const allowedToBook = [
      UserType.ownerExpert,
      UserType.cofounderExpert,
      UserType.expert,
      UserType.artisan,
    ];

    return allowedToBook.contains(expertType);
  }

  /// Returns the correct dashboard route for a given user type.
  static String getDashboardRoute(UserType userType) {
    switch (userType) {
      case UserType.admin:
        return '/admin';
      case UserType.owner:
      case UserType.cofounder:
        return '/management_dashboard';
      case UserType.manager:
      case UserType.ownerExpert:
      case UserType.cofounderExpert:
      case UserType.expert:
      case UserType.artisan:
        return '/expert_dashboard';
      case UserType.receptionist:
        return '/management_dashboard';
      case UserType.intern:
        return '/intern_dashboard';
      case UserType.customer:
        return '/customer_home';
    }
  }

  /// Enforces dashboard access based on permission matrix.
  /// Wire all UI conditionally to real role checks.
  static bool hasAccess(UserType userType, String resource) {
    // This should ideally consume real backend responses via RolePermission manager.
    // For now, it provides a safe local fallback that aligns with backend logic.
    switch (resource) {
      case 'SALON_MANAGEMENT':
        return userType.isManagement || userType == UserType.receptionist;
      case 'FINANCIAL_REPORTS':
        return userType.isManagement && userType != UserType.manager;
      case 'STAFF_MANAGEMENT':
        return userType.isManagement;
      case 'BOOKING_CONTROLS':
        return userType.isExpertType || userType == UserType.receptionist || userType.isManagement;
      default:
        return false;
    }
  }
}
