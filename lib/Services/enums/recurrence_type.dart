enum RecurrenceType {
  weekly('WEEKLY'),
  biweekly('BIWEEKLY');

  final String value;
  const RecurrenceType(this.value);
}

class RecurrenceTypeExtension {
  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecurrenceType.weekly,
    );
  }
}
