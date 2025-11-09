class WorkingHours {
  final DateTime date;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final bool isWorking;

  WorkingHours({
    required this.date,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.isWorking,
  });

  Duration get scheduledDuration => scheduledEnd.difference(scheduledStart);
  Duration get workedDuration {
    if (actualStart != null && actualEnd != null) {
      return actualEnd!.difference(actualStart!);
    }
    return Duration.zero;
  }

  Duration get remainingTime {
    if (!isWorking || actualStart == null) return scheduledDuration;
    final now = DateTime.now();
    return scheduledEnd.difference(now);
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      date: DateTime.parse(json['date']),
      scheduledStart: DateTime.parse(json['scheduled_start']),
      scheduledEnd: DateTime.parse(json['scheduled_end']),
      actualStart: json['actual_start'] != null ? DateTime.parse(json['actual_start']) : null,
      actualEnd: json['actual_end'] != null ? DateTime.parse(json['actual_end']) : null,
      isWorking: json['is_working'] ?? false,
    );
  }
}
