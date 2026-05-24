import '../../core/enums/owner_enums.dart';
import '../../core/config/subscription_config.dart';

/// Extended owner profile that drives the tier-based feature system.
///
/// Changes vs the previous model:
/// - `subscriptionTier` is now typed as [OwnerSubscriptionTier] (not raw String)
/// - Added `ownerType` ([OwnerType])
/// - Added `isTrial` and `trialEndsAt`
/// - Added computed `effectiveTier` (falls back to artisan when lapsed)
/// - Added `maxStaff` derived from config (no separate field needed)
class OwnerProfile {
  final int id;
  final int expertProfileId;
  final OwnerType ownerType;
  final bool isOwner;
  final bool isWorker;
  final bool isSubscribed;
  final bool hasBranches;
  final bool hasOffers;
  final double avgRating;
  final OwnerSubscriptionTier subscriptionTier;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isTrial;
  final DateTime? trialEndsAt;
  final int? salonId;

  const OwnerProfile({
    required this.id,
    required this.expertProfileId,
    this.ownerType = OwnerType.expertOwner,
    this.isOwner = true,
    this.isWorker = true,
    this.isSubscribed = false,
    this.hasBranches = false,
    this.hasOffers = false,
    this.avgRating = 0.0,
    this.subscriptionTier = OwnerSubscriptionTier.artisan,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isTrial = false,
    this.trialEndsAt,
    this.salonId,
  });

  // ---------------------------------------------------------------------------
  // COMPUTED PROPERTIES
  // ---------------------------------------------------------------------------

  /// Whether the subscription (or trial) is currently active.
  bool get isSubscriptionActive {
    if (isTrial) {
      if (trialEndsAt == null) return false;
      return DateTime.now().isBefore(trialEndsAt!);
    }
    if (!isSubscribed || subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  /// Returns days remaining on subscription or trial.
  int? get daysRemaining {
    final end = isTrial ? trialEndsAt : subscriptionEndDate;
    if (end == null || !isSubscriptionActive) return null;
    return end.difference(DateTime.now()).inDays;
  }

  /// Effective tier to use for feature access.
  /// Falls back to [OwnerSubscriptionTier.artisan] when subscription lapses.
  OwnerSubscriptionTier get effectiveTier {
    if (!isSubscriptionActive) return OwnerSubscriptionTier.artisan;
    return subscriptionTier;
  }

  /// Max staff from central config. -1 = unlimited.
  int get maxStaff => SubscriptionConfig.maxStaffFor(effectiveTier);

  bool get hasUnlimitedStaff => maxStaff == -1;

  /// True if the owner is both a worker and manager (expertOwner / soloFreelancer).
  bool get isPractitioner =>
      ownerType == OwnerType.expertOwner ||
      ownerType == OwnerType.soloFreelancer;

  /// False when subscriptionEndDate is within 7 days (show renewal banner).
  bool get isRenewalWarning {
    final days = daysRemaining;
    return days != null && days <= 7;
  }

  // ---------------------------------------------------------------------------
  // SERIALIZATION
  // ---------------------------------------------------------------------------

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      id: (json['id'] as int?) ?? 0,
      // Backend Owner model IS the profile — no nested expert field
      expertProfileId: json['id'] as int? ?? 0,
      ownerType: OwnerTypeExtension.fromString(json['owner_type'] as String?),
      isOwner: json['is_owner'] as bool? ?? true,
      isWorker: json['is_worker'] as bool? ?? true,
      // Backend sends 'is_subscription_active'; 'is_subscribed' is Flutter-only fallback
      isSubscribed:
          (json['is_subscription_active'] ?? json['is_subscribed']) as bool? ??
          false,
      hasBranches: json['has_branches'] as bool? ?? false, // not on backend yet
      hasOffers: json['has_offers'] as bool? ?? false, // not on backend yet
      avgRating:
          double.tryParse(
            (json['average_rating'] ?? json['avg_rating'] ?? 0.0).toString(),
          ) ??
          0.0,
      // subscription_tier maps to subscription_type on current backend
      subscriptionTier: OwnerSubscriptionTierExtension.fromString(
        (json['subscription_tier'] ?? json['subscription_type']) as String?,
      ),
      subscriptionStartDate: json['subscription_start_date'] != null
          ? DateTime.parse(json['subscription_start_date'] as String)
          : null,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'] as String)
          : null,
      isTrial: json['is_trial'] as bool? ?? false,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      salonId: json['salon'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expert': expertProfileId,
      'owner_type': ownerType.value,
      'is_owner': isOwner,
      'is_worker': isWorker,
      'is_subscribed': isSubscribed,
      'has_branches': hasBranches,
      'has_offers': hasOffers,
      'avg_rating': avgRating,
      'subscription_tier': subscriptionTier.value,
      'subscription_start_date': subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'is_trial': isTrial,
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'salon': salonId,
    };
  }

  OwnerProfile copyWith({
    int? id,
    int? expertProfileId,
    OwnerType? ownerType,
    bool? isOwner,
    bool? isWorker,
    bool? isSubscribed,
    bool? hasBranches,
    bool? hasOffers,
    double? avgRating,
    OwnerSubscriptionTier? subscriptionTier,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isTrial,
    DateTime? trialEndsAt,
    int? salonId,
  }) {
    return OwnerProfile(
      id: id ?? this.id,
      expertProfileId: expertProfileId ?? this.expertProfileId,
      ownerType: ownerType ?? this.ownerType,
      isOwner: isOwner ?? this.isOwner,
      isWorker: isWorker ?? this.isWorker,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      hasBranches: hasBranches ?? this.hasBranches,
      hasOffers: hasOffers ?? this.hasOffers,
      avgRating: avgRating ?? this.avgRating,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isTrial: isTrial ?? this.isTrial,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      salonId: salonId ?? this.salonId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OwnerProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'OwnerProfile(id=$id, tier=${subscriptionTier.value}, '
      'active=$isSubscriptionActive, trial=$isTrial)';
}
