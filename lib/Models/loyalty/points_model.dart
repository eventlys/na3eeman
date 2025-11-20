class PointsModel {
  final String id;
  final int userId;
  final int points;
  final PointsType type;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PointsModel({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory PointsModel.fromJson(Map<String, dynamic> json) {
    return PointsModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as int,
      points: json['points'] as int,
      type: PointsTypeExtension.fromString(json['type'] as String? ?? 'other'),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'type': type.value,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

enum PointsType {
  appointmentComplete('appointment_complete'),
  reviewWrite('review_write'),
  referral('referral'),
  rewardRedeem('reward_redeem'),
  other('other');

  final String value;

  const PointsType(this.value);
}

class PointsTypeExtension {
  static PointsType fromString(String value) {
    for (PointsType type in PointsType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return PointsType.other;
  }

  static String toDisplayString(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return 'Appointment Completed';
      case PointsType.reviewWrite:
        return 'Review Written';
      case PointsType.referral:
        return 'Customer Referral';
      case PointsType.rewardRedeem:
        return 'Reward Redeemed';
      case PointsType.other:
        return 'Other';
    }
  }
}

class PointsTransaction {
  final String id;
  final int userId;
  final int points;
  final PointsType type;
  final String description;
  final DateTime timestamp;
  final int? appointmentId;
  final int? referralId;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.description,
    required this.timestamp,
    this.appointmentId,
    this.referralId,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] as int,
      points: json['points'] as int,
      type: PointsTypeExtension.fromString(json['type'] as String? ?? 'other'),
      description: json['description'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      appointmentId: json['appointment_id'] as int?,
      referralId: json['referral_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'type': type.value,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'appointment_id': appointmentId,
      'referral_id': referralId,
    };
  }
}
