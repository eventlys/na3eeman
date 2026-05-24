class WorkingHours {
  final DateTime date;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
  final bool isWorking;
  final int? staffId;
  final int? salonId;

  WorkingHours({
    required this.date,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.isWorking,
    this.staffId,
    this.salonId,
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

  bool get isOnBreak {
    if (actualStart == null || !isWorking) return false;
    final now = DateTime.now();
    // Assuming break is middle 30 minutes of shift
    final breakStart = scheduledStart.add(scheduledDuration ~/ 3);
    final breakEnd = breakStart.add(Duration(minutes: 30));
    return now.isAfter(breakStart) && now.isBefore(breakEnd);
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      date: DateTime.parse(json['date']),
      scheduledStart: DateTime.parse(json['scheduled_start']),
      scheduledEnd: DateTime.parse(json['scheduled_end']),
      actualStart: json['actual_start'] != null
          ? DateTime.parse(json['actual_start'])
          : null,
      actualEnd: json['actual_end'] != null
          ? DateTime.parse(json['actual_end'])
          : null,
      isWorking: json['is_working'] ?? false,
      staffId: json['staff'] as int?,
      salonId: json['salon'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'scheduled_start': scheduledStart.toIso8601String(),
      'scheduled_end': scheduledEnd.toIso8601String(),
      'actual_start': actualStart?.toIso8601String(),
      'actual_end': actualEnd?.toIso8601String(),
      'is_working': isWorking,
      'staff': staffId,
      'salon': salonId,
    };
  }
}
