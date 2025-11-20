

import '../../Models/staff/staff_role.dart';

enum UserRole {
  owner,
  customer,
  barber,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.owner: return 'OWNER';
      case UserRole.customer: return 'CUSTOMER';
      case UserRole.barber: return 'BARBER';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.owner: return 'Shop Owner';
      case UserRole.customer: return 'Customer';
      case UserRole.barber: return 'Barber';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER': return UserRole.owner;
      case 'CUSTOMER': return UserRole.customer;
      case 'BARBER': return UserRole.barber;
      default: return UserRole.customer;
    }
  }

  // Helper to convert between UserRole and StaffRole
  StaffRole toStaffRole() {
    switch (this) {
      case UserRole.owner: return StaffRole.owner;
      case UserRole.barber: return StaffRole.barber;
      case UserRole.customer:
        throw Exception('Customer cannot be converted to StaffRole');
    }
  }
}
