/// Defines all user types in the Na3eeman ecosystem.
/// Strictly mapped to Backend `UserType` enum.
enum UserType {
  /// Platform administrator.
  admin,

  /// Salon owner.
  owner,

  /// Salon co-founder.
  cofounder,

  /// Branch or salon manager.
  manager,

  /// Owner who also provides services.
  ownerExpert,

  /// Co-founder who also provides services.
  cofounderExpert,

  /// Independent artisan or top-tier service provider.
  artisan,

  /// Standard service provider.
  expert,

  /// Front-desk staff.
  receptionist,

  /// Junior staff or trainee.
  intern,

  /// End customer who books services.
  customer;

  String get value => name.toUpperCase();

  static UserType fromString(String value) {
    final cleanValue = value.toUpperCase().replaceAll('_', '');
    return UserType.values.firstWhere(
      (e) => e.name.toUpperCase() == cleanValue,
      orElse: () => UserType.customer,
    );
  }

  bool get isStaff => this != customer;

  bool get isManagement => [
    admin,
    owner,
    cofounder,
    manager,
    ownerExpert,
    cofounderExpert,
  ].contains(this);

  bool get isExpertType =>
      [ownerExpert, cofounderExpert, artisan, expert].contains(this);

  String get displayName {
    switch (this) {
      case admin:
        return 'Admin';
      case owner:
        return 'Owner';
      case cofounder:
        return 'Co-Founder';
      case manager:
        return 'Manager';
      case ownerExpert:
        return 'Owner Expert';
      case cofounderExpert:
        return 'Co-Founder Expert';
      case artisan:
        return 'Artisan';
      case expert:
        return 'Expert';
      case receptionist:
        return 'Receptionist';
      case intern:
        return 'Intern';
      case customer:
        return 'Customer';
    }
  }
}
