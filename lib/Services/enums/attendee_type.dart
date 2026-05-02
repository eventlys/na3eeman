enum AttendeeType {
  self('SELF'),
  friend('FRIEND'),
  child('CHILD');

  final String value;
  const AttendeeType(this.value);
}

class AttendeeTypeExtension {
  static AttendeeType fromString(String value) {
    return AttendeeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendeeType.self,
    );
  }
}
