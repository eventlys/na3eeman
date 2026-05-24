/// RBAC (Role-Based Access Control) for Na3eeman
///
/// UserRole — all actor types in the system
/// SubscriptionTier — commercial offering levels
/// AppPermission — granular permissions checked at the widget/feature level
library;

// ─────────────────────────────────────────────────────────────────────────────
// USER ROLES
// ─────────────────────────────────────────────────────────────────────────────

/// All actor types in the Na3eeman ecosystem.
enum UserRole {
  /// End customer (books appointments).
  customer,

  /// Expert practitioner (replaces Expert and Expert).
  expert,

  /// Trainee or junior staff.
  intern,

  /// Front-desk operator; creates/edits appointments.
  receptionist,

  /// Full salon owner; all salon-level permissions.
  owner,

  /// Branch or salon manager.
  manager,

  /// Owner who also provides services.
  ownerExpert,

  /// Co-Founder of the salon.
  cofounder,

  /// Co-Founder who also provides services.
  cofounderExpert,

  /// Independent artisan or top-tier service provider.
  artisan,

  /// Administrative role for salon/platform management.
  admin;

  bool get isStaff => [
    expert,
    intern,
    receptionist,
    owner,
    manager,
    ownerExpert,
    cofounder,
    cofounderExpert,
    artisan,
    admin,
  ].contains(this);

  bool get isOwnerEquivalent =>
      [owner, manager, ownerExpert, cofounder, cofounderExpert].contains(this);

  bool get isAdmin => this == admin;

  String get displayName {
    switch (this) {
      case customer:
        return 'Customer';
      case expert:
        return 'Expert';
      case intern:
        return 'Intern';
      case receptionist:
        return 'Receptionist';
      case owner:
        return 'Owner';
      case manager:
        return 'Manager';
      case ownerExpert:
        return 'Owner Expert';
      case cofounder:
        return 'Co-Founder';
      case cofounderExpert:
        return 'Co-Founder Expert';
      case artisan:
        return 'Artisan';
      case admin:
        return 'Admin';
    }
  }

  String get value => name.toUpperCase();
}

extension UserRoleExtension on UserRole {
  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'CUSTOMER':
        return UserRole.customer;
      case 'EXPERT':
      case 'EMPLOYEE':
        return UserRole.expert;
      case 'INTERN':
      case 'HELPER':
        return UserRole.intern;
      case 'RECEPTIONIST':
        return UserRole.receptionist;
      case 'OWNER':
      case 'OWNER_OWNER':
        return UserRole.owner;
      case 'MANAGER':
        return UserRole.manager;
      case 'OWNER_EXPERT':
      case 'OWNER_EMPLOYEE':
        return UserRole.ownerExpert;
      case 'COFOUNDER':
      case 'CO_FOUNDER':
        return UserRole.cofounder;
      case 'COFOUNDER_EXPERT':
        return UserRole.cofounderExpert;
      case 'ARTISAN':
        return UserRole.artisan;
      case 'ADMIN':
      case 'SUPERADMIN':
      case 'SUPER_ADMIN':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBSCRIPTION TIERS
// ─────────────────────────────────────────────────────────────────────────────

/// Commercial subscription level of a salon or staff account.
enum SubscriptionTier {
  basic,
  gold,
  elite,
  premium,
  business;

  /// Numeric rank — used for comparisons (`tier >= SubscriptionTier.gold`).
  int get rank {
    switch (this) {
      case basic:
        return 0;
      case gold:
        return 1;
      case elite:
        return 2;
      case premium:
        return 3;
      case business:
        return 4;
    }
  }

  /// Returns true if this tier meets or exceeds [required].
  bool meets(SubscriptionTier required) => rank >= required.rank;

  String get displayName {
    switch (this) {
      case basic:
        return 'Basic';
      case gold:
        return 'Gold';
      case elite:
        return 'Elite';
      case premium:
        return 'Premium';
      case business:
        return 'Business';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Granular permission flags checked by [RBACProvider].
enum AppPermission {
  // Booking
  viewBookings,
  createBooking,
  cancelAnyBooking,
  rescheduleBooking,

  // Customers
  viewCustomerList,
  editCustomerProfile,
  banCustomer,

  // Staff
  viewStaffList,
  manageStaff,
  setStaffRoles,

  // Finance
  viewSalonRevenue,
  viewPayoutRequests,
  approvePayouts,
  viewSubscriptionRevenue,

  // Reports
  viewReports,
  downloadReports,

  // Salon Management
  editSalonProfile,
  manageSessions,
  manageServices,

  // Analytics
  viewAnalytics,
  viewPeakHours,

  // Admin (Super Admin only)
  accessAdminDashboard,
  banAnyUser,
  verifyAccounts,
  resolveDisputes,
  viewSystemHealth,
  viewAllSalons,
  viewGlobalRevenue,
}

/// Defines which permissions are granted per role.
const Map<UserRole, Set<AppPermission>> _rolePermissions = {
  UserRole.customer: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.rescheduleBooking,
  },
  UserRole.receptionist: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
  },
  UserRole.expert: {
    AppPermission.viewBookings,
    AppPermission.viewCustomerList,
    AppPermission.viewReports,
    AppPermission.manageServices,
    AppPermission.manageSessions,
  },
  UserRole.manager: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
    AppPermission.viewStaffList,
    AppPermission.manageStaff,
    AppPermission.viewSalonRevenue,
    AppPermission.viewReports,
    AppPermission.downloadReports,
    AppPermission.viewAnalytics,
    AppPermission.viewPeakHours,
    AppPermission.manageServices,
    AppPermission.manageSessions,
  },
  UserRole.owner: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
    AppPermission.editCustomerProfile,
    AppPermission.viewStaffList,
    AppPermission.manageStaff,
    AppPermission.setStaffRoles,
    AppPermission.viewSalonRevenue,
    AppPermission.viewPayoutRequests,
    AppPermission.viewReports,
    AppPermission.downloadReports,
    AppPermission.editSalonProfile,
    AppPermission.manageSessions,
    AppPermission.manageServices,
    AppPermission.viewAnalytics,
    AppPermission.viewPeakHours,
  },
  UserRole.ownerExpert: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
    AppPermission.editCustomerProfile,
    AppPermission.viewStaffList,
    AppPermission.manageStaff,
    AppPermission.setStaffRoles,
    AppPermission.viewSalonRevenue,
    AppPermission.viewPayoutRequests,
    AppPermission.viewReports,
    AppPermission.downloadReports,
    AppPermission.editSalonProfile,
    AppPermission.manageSessions,
    AppPermission.manageServices,
    AppPermission.viewAnalytics,
    AppPermission.viewPeakHours,
  },
  UserRole.admin: {
    ...AppPermission.values, // Admins get everything
  },
  UserRole.intern: {AppPermission.viewBookings, AppPermission.viewCustomerList},
  UserRole.cofounder: {
    // Co-Founder has identical permissions to Owner
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
    AppPermission.editCustomerProfile,
    AppPermission.banCustomer,
    AppPermission.viewStaffList,
    AppPermission.manageStaff,
    AppPermission.setStaffRoles,
    AppPermission.viewSalonRevenue,
    AppPermission.viewPayoutRequests,
    AppPermission.approvePayouts,
    AppPermission.viewSubscriptionRevenue,
    AppPermission.viewReports,
    AppPermission.downloadReports,
    AppPermission.editSalonProfile,
    AppPermission.manageSessions,
    AppPermission.manageServices,
    AppPermission.viewAnalytics,
    AppPermission.viewPeakHours,
  },
  UserRole.cofounderExpert: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
    AppPermission.editCustomerProfile,
    AppPermission.viewStaffList,
    AppPermission.manageStaff,
    AppPermission.setStaffRoles,
    AppPermission.viewSalonRevenue,
    AppPermission.viewPayoutRequests,
    AppPermission.viewReports,
    AppPermission.downloadReports,
    AppPermission.editSalonProfile,
    AppPermission.manageSessions,
    AppPermission.manageServices,
    AppPermission.viewAnalytics,
    AppPermission.viewPeakHours,
  },
  UserRole.artisan: {
    AppPermission.viewBookings,
    AppPermission.viewCustomerList,
    AppPermission.viewReports,
    AppPermission.manageServices,
    AppPermission.manageSessions,
  },
};

/// Convenience extension to check permissions on a role.
extension UserRolePermissions on UserRole {
  bool can(AppPermission permission) =>
      _rolePermissions[this]?.contains(permission) ?? false;
}
