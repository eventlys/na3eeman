class InternTask {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  InternTask({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  factory InternTask.fromJson(Map<String, dynamic> json) {
    return InternTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'is_completed': isCompleted,
    };
  }
}

class InternFeedback {
  final int id;
  final int intern;
  final String? internName;
  final int expert;
  final String? expertName;
  final String feedbackText;
  final DateTime createdAt;

  InternFeedback({
    required this.id,
    required this.intern,
    this.internName,
    required this.expert,
    this.expertName,
    required this.feedbackText,
    required this.createdAt,
  });

  factory InternFeedback.fromJson(Map<String, dynamic> json) {
    return InternFeedback(
      id: json['id'],
      intern: json['intern'],
      internName: json['intern_name'],
      expert: json['expert'],
      expertName: json['expert_name'],
      feedbackText: json['feedback_text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class InternAttendanceLog {
  final int id;
  final int userId;
  final String? userName;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String status;
  final String? location;

  InternAttendanceLog({
    required this.id,
    required this.userId,
    this.userName,
    required this.clockIn,
    this.clockOut,
    required this.status,
    this.location,
  });

  factory InternAttendanceLog.fromJson(Map<String, dynamic> json) {
    return InternAttendanceLog(
      id: json['id'],
      userId: json['user'],
      userName: json['user_name'],
      clockIn: DateTime.parse(json['clock_in']),
      clockOut: json['clock_out'] != null ? DateTime.parse(json['clock_out']) : null,
      status: json['status'],
      location: json['location'],
    );
  }
}
