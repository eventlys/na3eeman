
enum StaffRole {
  owner,
  manager,
  expert,
  receptionist,
  intern,
  ownerExpert,
  cofounder,
  admin,
}

extension StaffRoleExtension on StaffRole {
  String get value {
    switch (this) {
      case StaffRole.owner: return 'OWNER';
      case StaffRole.manager: return 'MANAGER';
      case StaffRole.expert: return 'EXPERT';
      case StaffRole.receptionist: return 'RECEPTIONIST';
      case StaffRole.intern: return 'INTERN';
      case StaffRole.ownerExpert: return 'OWNER_EXPERT';
      case StaffRole.cofounder: return 'COFOUNDER';
      case StaffRole.admin: return 'ADMIN';
    }
  }

  String get displayName {
    switch (this) {
      case StaffRole.owner: return 'Owner';
      case StaffRole.manager: return 'Manager';
      case StaffRole.expert: return 'Expert';
      case StaffRole.receptionist: return 'Receptionist';
      case StaffRole.intern: return 'Intern';
      case StaffRole.ownerExpert: return 'Owner Expert';
      case StaffRole.cofounder: return 'Co-Founder';
      case StaffRole.admin: return 'Admin';
    }
  }

  static StaffRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER': return StaffRole.owner;
      case 'MANAGER': return StaffRole.manager;
      case 'EXPERT':
      case 'EMPLOYEE':
      case 'EXPERT':
        return StaffRole.expert;
      case 'RECEPTIONIST': return StaffRole.receptionist;
      case 'INTERN':
      case 'HELPER':
        return StaffRole.intern;
      case 'OWNER_EXPERT':
      case 'OWNER_EMPLOYEE':
        return StaffRole.ownerExpert;
      case 'COFOUNDER': return StaffRole.cofounder;
      case 'ADMIN': return StaffRole.admin;
      default: return StaffRole.expert;
    }
  }
}
