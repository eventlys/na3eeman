
enum UserRole {
  superAdmin,
  admin,
  owner,
  manager,
  employee,
  receptionist,
  intern,
  customer,
}

extension UserRoleExtension on UserRole {
  bool can(AppPermission permission) {
    switch (this) {
      case UserRole.superAdmin:
        return true;
      case UserRole.owner:
        return true;
      case UserRole.manager:
        return [
          AppPermission.viewAppointments,
          AppPermission.createAppointments,
          AppPermission.viewAnalytics,
          AppPermission.manageEmployees,
        ].contains(permission);
      case UserRole.employee:
      case UserRole.receptionist:
        return [
          AppPermission.viewAppointments,
          AppPermission.createAppointments,
        ].contains(permission);
      default:
        return false;
    }
  }

  bool get isStaff => [
    UserRole.employee,
    UserRole.receptionist,
    UserRole.intern,
    UserRole.manager,
  ].contains(this);

  String get value {
    switch (this) {
      case UserRole.superAdmin: return 'SUPER_ADMIN';
      case UserRole.admin: return 'ADMIN';
      case UserRole.owner: return 'OWNER';
      case UserRole.manager: return 'MANAGER';
      case UserRole.employee: return 'EMPLOYEE';
      case UserRole.receptionist: return 'RECEPTIONIST';
      case UserRole.intern: return 'INTERN';
      case UserRole.customer: return 'CUSTOMER';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'SUPER_ADMIN': return UserRole.superAdmin;
      case 'ADMIN': return UserRole.admin;
      case 'OWNER': return UserRole.owner;
      case 'MANAGER': return UserRole.manager;
      case 'EMPLOYEE': return UserRole.employee;
      case 'BARBER': return UserRole.employee;
      case 'RECEPTIONIST': return UserRole.receptionist;
      case 'INTERN': return UserRole.intern;
      case 'CUSTOMER': return UserRole.customer;
      default: return UserRole.customer;
    }
  }
}

enum SubscriptionTier {
  basic,
  gold,
  elite,
  premium,
  business,
}

extension SubscriptionTierExtension on SubscriptionTier {
  int get rank {
    switch (this) {
      case SubscriptionTier.basic: return 0;
      case SubscriptionTier.gold: return 1;
      case SubscriptionTier.elite: return 2;
      case SubscriptionTier.premium: return 3;
      case SubscriptionTier.business: return 4;
    }
  }

  bool meets(SubscriptionTier required) => rank >= required.rank;
}

enum PointsType {
  booking,
  referral,
  loyalty,
  purchase,
  inviteFriend,
  rateShop,
  arriveOnTime,
  shopFeedback,
  rateApp,
  appFeedback,
  makeAppointment,
  appointmentComplete,
  reviewWrite,
  rewardRedeem,
  other,
}

enum AppPermission {
  manageEmployees,
  manageInventory,
  manageSubscriptions,
  viewAnalytics,
  viewAppointments,
  createAppointments,
  managePayments,
}
