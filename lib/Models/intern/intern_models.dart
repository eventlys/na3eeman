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

class InternTarget {
  final int id;
  final String title;
  final int targetValue;
  final int currentValue;
  final double percentageCompletion;
  final String setByName;
  final DateTime period;

  InternTarget({
    required this.id,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    required this.percentageCompletion,
    required this.setByName,
    required this.period,
  });

  factory InternTarget.fromJson(Map<String, dynamic> json) {
    return InternTarget(
      id: json['id'],
      title: json['title'],
      targetValue: json['target_value'],
      currentValue: json['current_value'],
      percentageCompletion: (json['percentage_completion'] as num).toDouble(),
      setByName: json['set_by_name'],
      period: DateTime.parse(json['period']),
    );
  }
}
