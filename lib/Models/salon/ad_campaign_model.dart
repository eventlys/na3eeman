class AdCampaignModel {
  final int id;
  final String name;
  final String details;
  final int durationDays;
  final int rewardPoints;
  final DateTime? createdAt;
  final int salonId;

  const AdCampaignModel({
    required this.id,
    required this.name,
    required this.details,
    required this.durationDays,
    required this.rewardPoints,
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
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
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
      'salon': salonId,
    };
  }
}
