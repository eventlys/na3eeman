class HelpFeedback {
  final int id;
  final int userId;
  final String? userName;
  final String? userRole;
  final String content;
  final String feedbackType;
  final String? feedbackTypeDisplay;
  final String status;
  final String? statusDisplay;
  final bool isValuable;
  final bool isReviewed;
  final String? adminNotes;
  final DateTime createdAt;

  HelpFeedback({
    required this.id,
    required this.userId,
    this.userName,
    this.userRole,
    required this.content,
    required this.feedbackType,
    this.feedbackTypeDisplay,
    required this.status,
    this.statusDisplay,
    required this.isValuable,
    required this.isReviewed,
    this.adminNotes,
    required this.createdAt,
  });

  factory HelpFeedback.fromJson(Map<String, dynamic> json) {
    return HelpFeedback(
      id: json['id'],
      userId: json['user'],
      userName: json['user_name'],
      userRole: json['user_role'],
      content: json['content'],
      feedbackType: json['feedback_type'],
      feedbackTypeDisplay: json['feedback_type_display'],
      status: json['status'],
      statusDisplay: json['status_display'],
      isValuable: json['is_valuable'] ?? false,
      isReviewed: json['is_reviewed'] ?? false,
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
