// import 'barber_profile.dart';

class OwnerProfile {
  final int id;
  final int barberProfileId;
  final bool isOwner;
  final bool isWorker;
  final bool isSubscribed;
  final bool hasBranches;
  final bool hasOffers;
  final double avgRating;
  final String? subscriptionTier;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  const OwnerProfile({
    required this.id,
    required this.barberProfileId,
    this.isOwner = true,
    this.isWorker = true,
    this.isSubscribed = false,
    this.hasBranches = false,
    this.hasOffers = false,
    this.avgRating = 0.0,
    this.subscriptionTier,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      id: (json['id'] as int?) ?? 0,
      barberProfileId: (json['barber'] ?? json['id'] as int?) ?? 0, // This is the BarberProfile ID
      isOwner: json['is_owner'] as bool? ?? true,
      isWorker: json['is_worker'] as bool? ?? true,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
      hasBranches: json['has_branches'] as bool? ?? false,
      hasOffers: json['has_offers'] as bool? ?? false,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      subscriptionTier: json['subscription_tier'] as String?,
      subscriptionStartDate: json['subscription_start_date'] != null
          ? DateTime.parse(json['subscription_start_date'] as String)
          : null,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber': barberProfileId,
      'is_owner': isOwner,
      'is_worker': isWorker,
      'is_subscribed': isSubscribed,
      'has_branches': hasBranches,
      'has_offers': hasOffers,
      'avg_rating': avgRating,
      'subscription_tier': subscriptionTier,
      'subscription_start_date': subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
    };
  }

  OwnerProfile copyWith({
    int? id,
    int? barberProfileId,
    bool? isOwner,
    bool? isWorker,
    bool? isSubscribed,
    bool? hasBranches,
    bool? hasOffers,
    double? avgRating,
    String? subscriptionTier,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
  }) {
    return OwnerProfile(
      id: id ?? this.id,
      barberProfileId: barberProfileId ?? this.barberProfileId,
      isOwner: isOwner ?? this.isOwner,
      isWorker: isWorker ?? this.isWorker,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      hasBranches: hasBranches ?? this.hasBranches,
      hasOffers: hasOffers ?? this.hasOffers,
      avgRating: avgRating ?? this.avgRating,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }

  // Helper methods
  bool get isSubscriptionActive {
    if (!isSubscribed || subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  int? get subscriptionDaysRemaining {
    if (!isSubscriptionActive) return null;
    return subscriptionEndDate!.difference(DateTime.now()).inDays;
  }
}
