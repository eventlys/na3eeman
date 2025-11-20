enum StaffRole {
  owner('OWNER', 'Owner'),
  subOwner('SUB_OWNER', 'Sub Owner'),
  branchManager('BRANCH_MANAGER', 'Branch Manager'),
  barber('BARBER', 'Barber'),
  assistant('ASSISTANT', 'Assistant'),
  receptionist('RECEPTIONIST', 'Receptionist'),
  cleaner('CLEANER', 'Cleaner');

  final String value;
  final String displayName;

  const StaffRole(this.value, this.displayName);
}

class StaffRoleExtension {
  static StaffRole fromString(String value) {
    for (StaffRole role in StaffRole.values) {
      if (role.value == value.toUpperCase()) {
        return role;
      }
    }
    return StaffRole.barber; // default
  }

  static String toDisplayString(String value) {
    return fromString(value).displayName;
  }

  static List<StaffRole> get managerialRoles => [
    StaffRole.owner,
    StaffRole.subOwner,
    StaffRole.branchManager,
  ];

  static List<StaffRole> get serviceRoles => [
    StaffRole.barber,
    StaffRole.assistant,
  ];

  static List<StaffRole> get supportRoles => [
    StaffRole.receptionist,
    StaffRole.cleaner,
  ];

  static bool canManageStaff(StaffRole role) {
    return managerialRoles.contains(role);
  }

  static bool canManageAppointments(StaffRole role) {
    return [
      StaffRole.owner,
      StaffRole.subOwner,
      StaffRole.branchManager,
      StaffRole.barber,
      StaffRole.receptionist,
    ].contains(role);
  }

  static bool canProcessPayments(StaffRole role) {
    return [
      StaffRole.owner,
      StaffRole.subOwner,
      StaffRole.branchManager,
      StaffRole.barber,
      StaffRole.receptionist,
    ].contains(role);
  }
}
