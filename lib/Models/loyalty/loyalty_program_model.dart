class LoyaltyProgram {
  final int? id;
  final int pointsPerInvite;
  final int pointsPerRatingApp;
  final int pointsPerReviewSalon;
  final int pointsPerGift;
  final int pointsPerGoodExpertReview;
  final int pointsPerBadExpertReview;
  final int pointsPerAppointment;
  final int pointsPerEarlyArrival;
  final int pointsPerApprovedFeedback;
  final int pointsPerLate5min;
  final int pointsPenaltyNoShow;
  final int pointsPenaltyDelay5min;
  final int pointsPenaltyDelay10min;
  final int pointsPenaltyDelay15min;
  final double pointsPerTipDollar;
  final int pointsRedemptionRate;
  final int freeHaircutAfter;
  final bool isActive;

  LoyaltyProgram({
    this.id,
    required this.pointsPerInvite,
    required this.pointsPerRatingApp,
    required this.pointsPerReviewSalon,
    required this.pointsPerGift,
    required this.pointsPerGoodExpertReview,
    required this.pointsPerBadExpertReview,
    required this.pointsPerAppointment,
    required this.pointsPerEarlyArrival,
    required this.pointsPerApprovedFeedback,
    required this.pointsPerLate5min,
    required this.pointsPenaltyNoShow,
    required this.pointsPenaltyDelay5min,
    required this.pointsPenaltyDelay10min,
    required this.pointsPenaltyDelay15min,
    required this.pointsPerTipDollar,
    required this.pointsRedemptionRate,
    required this.freeHaircutAfter,
    this.isActive = true,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgram(
      id: json['id'],
      pointsPerInvite: json['points_per_invite'] ?? 0,
      pointsPerRatingApp: json['points_per_rating_app'] ?? 0,
      pointsPerReviewSalon: json['points_per_review_salon'] ?? 0,
      pointsPerGift: json['points_per_gift'] ?? 0,
      pointsPerGoodExpertReview: json['points_per_good_expert_review'] ?? 0,
      pointsPerBadExpertReview: json['points_per_bad_expert_review'] ?? 0,
      pointsPerAppointment: json['points_per_appointment'] ?? 0,
      pointsPerEarlyArrival: json['points_per_early_arrival'] ?? 0,
      pointsPerApprovedFeedback: json['points_per_approved_feedback'] ?? 0,
      pointsPerLate5min: json['points_per_late_5min'] ?? 0,
      pointsPenaltyNoShow: json['points_penalty_no_show'] ?? 0,
      pointsPenaltyDelay5min: json['points_penalty_delay_5min'] ?? 0,
      pointsPenaltyDelay10min: json['points_penalty_delay_10min'] ?? 0,
      pointsPenaltyDelay15min: json['points_penalty_delay_15min'] ?? 0,
      pointsPerTipDollar: (json['points_per_tip_dollar'] ?? 0.0).toDouble(),
      pointsRedemptionRate: json['points_redemption_rate'] ?? 200,
      freeHaircutAfter: json['free_haircut_after'] ?? 10,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points_per_invite': pointsPerInvite,
      'points_per_rating_app': pointsPerRatingApp,
      'points_per_review_salon': pointsPerReviewSalon,
      'points_per_gift': pointsPerGift,
      'points_per_good_expert_review': pointsPerGoodExpertReview,
      'points_per_bad_expert_review': pointsPerBadExpertReview,
      'points_per_appointment': pointsPerAppointment,
      'points_per_early_arrival': pointsPerEarlyArrival,
      'points_per_approved_feedback': pointsPerApprovedFeedback,
      'points_per_late_5min': pointsPerLate5min,
      'points_penalty_no_show': pointsPenaltyNoShow,
      'points_penalty_delay_5min': pointsPenaltyDelay5min,
      'points_penalty_delay_10min': pointsPenaltyDelay10min,
      'points_penalty_delay_15min': pointsPenaltyDelay15min,
      'points_per_tip_dollar': pointsPerTipDollar,
      'points_redemption_rate': pointsRedemptionRate,
      'free_haircut_after': freeHaircutAfter,
      'is_active': isActive,
    };
  }
}
