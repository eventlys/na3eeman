
enum StaffRole {
  owner,
  subOwner,
  employee,
  receptionist,
  intern,
  @Deprecated('Use employee instead')
  barber,
}

extension StaffRoleExtension on StaffRole {
  String get value {
    switch (this) {
      case StaffRole.owner: return 'OWNER';
      case StaffRole.subOwner: return 'SUB_OWNER';
      case StaffRole.employee: return 'EMPLOYEE';
      case StaffRole.receptionist: return 'RECEPTIONIST';
      case StaffRole.intern: return 'INTERN';
      case StaffRole.barber: return 'BARBER';
    }
  }

  String get displayName {
    switch (this) {
      case StaffRole.owner: return 'Owner';
      case StaffRole.subOwner: return 'Sub Owner';
      case StaffRole.employee: return 'Employee';
      case StaffRole.receptionist: return 'Receptionist';
      case StaffRole.intern: return 'Intern';
      case StaffRole.barber: return 'Barber';
    }
  }

  static StaffRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER': return StaffRole.owner;
      case 'SUB_OWNER': return StaffRole.subOwner;
      case 'EMPLOYEE': return StaffRole.employee;
      case 'BARBER': return StaffRole.employee;
      case 'RECEPTIONIST': return StaffRole.receptionist;
      case 'INTERN': return StaffRole.intern;
      default: return StaffRole.employee;
    }
  }
}
