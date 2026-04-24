/// RBAC (Role-Based Access Control) for Na3eeman
///
/// UserRole — all actor types in the system
/// SubscriptionTier — commercial offering levels
/// AppPermission — granular permissions checked at the widget/feature level

// ─────────────────────────────────────────────────────────────────────────────
// USER ROLES
// ─────────────────────────────────────────────────────────────────────────────

/// All actor types in the Na3eeman ecosystem.
enum UserRole {
  /// End customer (books appointments).
  customer,

  /// Individual barber exposed to clients (no management scope).
  barber,

  /// Salon employee working under an owner.
  employee,

  /// Manages scheduling & staff; limited financial access.
  manager,

  /// Front-desk operator; creates/edits appointments.
  receptionist,

  /// Assistant tasks only (materials, cleaning, etc.).
  helper,

  /// Full salon owner; all salon-level permissions.
  owner,

  /// Owner who also works as an employee.
  ownerEmployee,

  /// Pure business owner who doesn't work in the salon.
  ownerOwner,

  /// Administrative role for salon/platform management.
  admin,

  /// Trainee or junior staff.
  intern,

  /// App-level god mode. Developer / platform administrator.
  superAdmin,

  /// Co-Founder — shares all Owner permissions and pages.
  cofounder;

  bool get isStaff =>
      [barber, employee, manager, receptionist, helper, owner, ownerEmployee, ownerOwner, intern, admin, cofounder].contains(this);

  bool get isOwnerEquivalent =>
      [owner, ownerEmployee, ownerOwner, cofounder].contains(this);

  bool get isAdmin => this == admin || this == superAdmin;

  String get displayName {
    switch (this) {
      case customer:
        return 'Customer';
      case barber:
        return 'Barber';
      case employee:
        return 'Employee';
      case manager:
        return 'Manager';
      case receptionist:
        return 'Receptionist';
      case helper:
        return 'Helper';
      case owner:
        return 'Owner';
      case ownerEmployee:
        return 'Owner (Employee)';
      case ownerOwner:
        return 'Owner (Manager)';
      case admin:
        return 'Admin';
      case intern:
        return 'Intern';
      case superAdmin:
        return 'Super Admin';
      case cofounder:
        return 'Co-Founder';
    }
  }

  String get value => name.toUpperCase();
}

extension UserRoleExtension on UserRole {
  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'CUSTOMER':
        return UserRole.customer;
      case 'BARBER':
        return UserRole.barber;
      case 'EMPLOYEE':
        return UserRole.employee;
      case 'MANAGER':
        return UserRole.manager;
      case 'RECEPTIONIST':
        return UserRole.receptionist;
      case 'HELPER':
        return UserRole.helper;
      case 'OWNER':
        return UserRole.owner;
      case 'OWNER_EMPLOYEE':
        return UserRole.ownerEmployee;
      case 'OWNER_OWNER':
        return UserRole.ownerOwner;
      case 'ADMIN':
        return UserRole.admin;
      case 'INTERN':
        return UserRole.intern;
      case 'SUPERADMIN':
      case 'SUPER_ADMIN':
        return UserRole.superAdmin;
      case 'COFOUNDER':
      case 'CO_FOUNDER':
        return UserRole.cofounder;
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
  UserRole.helper: {AppPermission.viewBookings},
  UserRole.receptionist: {
    AppPermission.viewBookings,
    AppPermission.createBooking,
    AppPermission.cancelAnyBooking,
    AppPermission.rescheduleBooking,
    AppPermission.viewCustomerList,
  },
  UserRole.barber: {
    AppPermission.viewBookings,
    AppPermission.viewCustomerList,
    AppPermission.viewReports,
  },
  UserRole.employee: {
    AppPermission.viewBookings,
    AppPermission.viewCustomerList,
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
  UserRole.ownerEmployee: {
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
  UserRole.ownerOwner: {
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
    ...AppPermission.values, // Admins get everything for now
  },
  UserRole.intern: {
    AppPermission.viewBookings,
    AppPermission.viewCustomerList,
  },
  UserRole.superAdmin: {
    // Super Admin has ALL permissions — populated dynamically
    ...AppPermission.values,
  },
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
};

/// Convenience extension to check permissions on a role.
extension UserRolePermissions on UserRole {
  bool can(AppPermission permission) =>
      _rolePermissions[this]?.contains(permission) ?? false;
}
