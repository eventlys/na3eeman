class AdCampaignModel {
  final int id;
  final String name;
  final String details;
  final int durationDays;
  final int rewardPoints;
  final bool isActive;
  final DateTime? createdAt;
  final int salonId;

  const AdCampaignModel({
    required this.id,
    required this.name,
    required this.details,
    required this.durationDays,
    required this.rewardPoints,
    this.isActive = true,
    this.createdAt,
    required this.salonId,
  });

  factory AdCampaignModel.fromMap(Map<String, dynamic> map) {
    return AdCampaignModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? 'New Campaign',
      details: map['details'] as String? ?? '',
      durationDays: map['duration_days'] as int? ?? 0,
      rewardPoints: map['reward_points'] as int? ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      salonId: map['salon_id'] as int? ?? (map['salon'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'duration_days': durationDays,
      'reward_points': rewardPoints,
      'is_active': isActive,
      'salon': salonId,
    };
  }

  AdCampaignModel copyWith({
    int? id,
    String? name,
    String? details,
    int? durationDays,
    int? rewardPoints,
    bool? isActive,
    DateTime? createdAt,
    int? salonId,
  }) {
    return AdCampaignModel(
      id: id ?? this.id,
      name: name ?? this.name,
      details: details ?? this.details,
      durationDays: durationDays ?? this.durationDays,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      salonId: salonId ?? this.salonId,
    );
  }
}
