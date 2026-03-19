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

  /// Shop employee working under an owner.
  employee,

  /// Manages scheduling & staff; limited financial access.
  manager,

  /// Front-desk operator; creates/edits appointments.
  receptionist,

  /// Assistant tasks only (materials, cleaning, etc.).
  helper,

  /// Full shop owner; all shop-level permissions.
  owner,

  /// App-level god mode. Developer / platform administrator.
  superAdmin;

  bool get isStaff =>
      [barber, employee, manager, receptionist, helper, owner].contains(this);

  bool get isAdmin => this == superAdmin;

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
      case superAdmin:
        return 'Super Admin';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBSCRIPTION TIERS
// ─────────────────────────────────────────────────────────────────────────────

/// Commercial subscription level of a shop or staff account.
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
  viewShopRevenue,
  viewPayoutRequests,
  approvePayouts,
  viewSubscriptionRevenue,

  // Reports
  viewReports,
  downloadReports,

  // Shop Management
  editShopProfile,
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
  viewAllShops,
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
    AppPermission.viewShopRevenue,
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
    AppPermission.viewShopRevenue,
    AppPermission.viewPayoutRequests,
    AppPermission.viewReports,
    AppPermission.downloadReports,
    AppPermission.editShopProfile,
    AppPermission.manageSessions,
    AppPermission.manageServices,
    AppPermission.viewAnalytics,
    AppPermission.viewPeakHours,
  },
  UserRole.superAdmin: {
    // Super Admin has ALL permissions — populated dynamically
    ...AppPermission.values,
  },
};

/// Convenience extension to check permissions on a role.
extension UserRolePermissions on UserRole {
  bool can(AppPermission permission) =>
      _rolePermissions[this]?.contains(permission) ?? false;
}
