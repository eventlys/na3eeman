enum PointsType {
  invite('invite'),
  inviteFriend('invite_friend'),
  review('review'),
  reviewWrite('review_write'),
  gifting('gifting'),
  rateSalon('rate_salon'),
  rateApp('rate_app'),
  expertFeedback('expert_feedback'),
  salonFeedback('salon_feedback'),
  appFeedback('app_feedback'),
  makeAppointment('make_appointment'),
  appointmentComplete('appointment_complete'),
  arriveOnTime('arrive_on_time'),
  lateArrival('late_arrival'),
  delay5Min('delay_5_min'),
  delay10Min('delay_10_min'),
  delay15Min('delay_15_min'),
  referral('referral'),
  booking('booking'),
  redeem('redeem'),
  rewardRedeem('reward_redeem'),
  signup('signup'),
  milestoneReached('milestone_reached'),
  tip('tip'),
  other('other');

  final String value;
  const PointsType(this.value);
}

class PointsTypeExtension {
  static PointsType fromString(String value) {
    for (var type in PointsType.values) {
      if (type.value == value || type.name == value) {
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
      case PointsType.makeAppointment:
        return 'Appointment Booked';
      case PointsType.invite:
        return 'Friend Invited';
      case PointsType.arriveOnTime:
        return 'Arrived On Time';
      case PointsType.lateArrival:
        return 'Late Arrival';
      case PointsType.tip:
        return 'Tipped';
      default:
        return type.name.replaceAll('_', ' ').toUpperCase();
    }
  }
}
