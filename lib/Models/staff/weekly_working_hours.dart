class WeeklyWorkingHours {
  final int? id;
  final int? salon;
  final int? expert;
  final int dayOfWeek;
  final String openingTime;
  final String closingTime;
  final bool isClosed;

  WeeklyWorkingHours({
    this.id,
    this.salon,
    this.expert,
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    required this.isClosed,
  });

  factory WeeklyWorkingHours.fromJson(Map<String, dynamic> json) {
    return WeeklyWorkingHours(
      id: json['id'],
      salon: json['salon'],
      expert: json['expert'],
      dayOfWeek: json['day_of_week'] ?? json['dayOfWeek'] ?? 0,
      openingTime: json['opening_time'] ?? json['openingTime'] ?? '10:00',
      closingTime: json['closing_time'] ?? json['closingTime'] ?? '20:00',
      isClosed: json['is_closed'] ?? json['isClosed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon': salon,
      'expert': expert,
      'day_of_week': dayOfWeek,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_closed': isClosed,
    };
  }

  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (dayOfWeek >= 0 && dayOfWeek < days.length) {
      return days[dayOfWeek];
    }
    return 'Unknown';
  }
}
