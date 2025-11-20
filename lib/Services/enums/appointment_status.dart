enum AppointmentStatus {
  scheduled('SCHEDULED'),
  checkedIn('CHECKED_IN'),
  pending('PENDING'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  noShow('NO_SHOW');

  final String value;
  const AppointmentStatus(this.value);
}

class AppointmentStatusExtension {
  static AppointmentStatus fromString(String value) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppointmentStatus.scheduled,
    );
  }
}
