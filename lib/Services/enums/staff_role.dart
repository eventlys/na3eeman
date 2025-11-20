// lib/core/enums/staff_role.dart
enum StaffRole {
  owner,
  subOwner,
  // owner,
  barber,
  // assistant,
  // receptionist,
  // cleaner
}

extension StaffRoleExtension on StaffRole {
  String get value {
    switch (this) {
      case StaffRole.owner: return 'OWNER';
      case StaffRole.subOwner: return 'SUB_OWNER';
      // case StaffRole.owner: return 'Owner';
      case StaffRole.barber: return 'BARBER';
      // case StaffRole.assistant: return 'ASSISTANT';
      // case StaffRole.receptionist: return 'RECEPTIONIST';
      // case StaffRole.cleaner: return 'CLEANER';
    }
  }

  String get displayName {
    switch (this) {
      case StaffRole.owner: return 'Owner';
      case StaffRole.subOwner: return 'Sub Owner';
      // case StaffRole.branchManager: return 'Branch Manager';
      case StaffRole.barber: return 'Barber';
      // case StaffRole.assistant: return 'Assistant';
      // case StaffRole.receptionist: return 'Receptionist';
      // case StaffRole.cleaner: return 'Cleaner';
    }
  }

  static StaffRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER': return StaffRole.owner;
      case 'SUB_OWNER': return StaffRole.subOwner;
      // case 'BRANCH_MANAGER': return StaffRole.branchManager;
      case 'BARBER': return StaffRole.barber;
      // case 'ASSISTANT': return StaffRole.assistant;
      // case 'RECEPTIONIST': return StaffRole.receptionist;
      // case 'CLEANER': return StaffRole.cleaner;
      default: return StaffRole.barber;
    }
  }
}
