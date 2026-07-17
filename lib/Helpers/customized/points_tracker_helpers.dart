// ignore_for_file: unused_local_variable
// helpers/points_tracker_helpers.dart
import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_color.dart';
import '../../Services/enums/points_types.dart';

class PointsTrackerHelpers {
  // Action styling helpers
  static Color getActionColor(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return AppColor.lightAccent;
      case PointsType.rateSalon:
      case PointsType.salonFeedback:
      case PointsType.reviewWrite:
        return AppColor.lightInfo;
      case PointsType.arriveOnTime:
      case PointsType.appointmentComplete:
      case PointsType.makeAppointment:
        return AppColor.lightSuccess;
      case PointsType.rateApp:
      case PointsType.appFeedback:
        return AppColor.lightWarning;
      case PointsType.rewardRedeem:
        return AppColor.primary;
      case PointsType.other:
      default:
        return AppColor.lightTextSecondary;
    }
  }

  static Color getActionColorDark(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return AppColor.darkAccent;
      case PointsType.rateSalon:
      case PointsType.salonFeedback:
      case PointsType.reviewWrite:
        return AppColor.darkInfo;
      case PointsType.arriveOnTime:
      case PointsType.appointmentComplete:
      case PointsType.makeAppointment:
        return AppColor.darkSuccess;
      case PointsType.rateApp:
      case PointsType.appFeedback:
        return AppColor.darkWarning;
      case PointsType.rewardRedeem:
        return AppColor.primary;
      case PointsType.other:
      default:
        return AppColor.darkTextSecondary;
    }
  }

  static IconData getActionIcon(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return Icons.person_add_alt_1_rounded;
      case PointsType.rateSalon:
      case PointsType.reviewWrite:
        return Icons.star_rate_rounded;
      case PointsType.arriveOnTime:
        return Icons.access_time_rounded;
      case PointsType.salonFeedback:
      case PointsType.appFeedback:
        return Icons.feedback_rounded;
      case PointsType.rateApp:
        return Icons.thumb_up_rounded;
      case PointsType.makeAppointment:
      case PointsType.appointmentComplete:
        return Icons.calendar_today_rounded;
      case PointsType.rewardRedeem:
        return Icons.card_giftcard_rounded;
      case PointsType.other:
      default:
        return Icons.more_horiz_rounded;
    }
  }

  static String getActionSubtitle(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return 'Invite friends to join the app';
      case PointsType.rateSalon:
        return 'Rate your experience at salons';
      case PointsType.arriveOnTime:
        return 'Be punctual for appointments';
      case PointsType.salonFeedback:
        return 'Provide feedback for salons';
      case PointsType.rateApp:
        return 'Rate our application';
      case PointsType.appFeedback:
        return 'Share feedback about the app';
      case PointsType.makeAppointment:
        return 'Book new appointments';
      case PointsType.appointmentComplete:
        return 'Complete your appointments';
      case PointsType.reviewWrite:
        return 'Write detailed reviews';
      case PointsType.referral:
        return 'Refer friends to join';
      case PointsType.rewardRedeem:
        return 'Redeem your points for rewards';
      case PointsType.other:
      default:
        return 'Various activities';
    }
  }

  static String getActionTitle(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return 'Invite Friend';
      case PointsType.rateSalon:
        return 'Rate Salon';
      case PointsType.arriveOnTime:
        return 'Arrive On Time';
      case PointsType.salonFeedback:
        return 'Salon Feedback';
      case PointsType.rateApp:
        return 'Rate App';
      case PointsType.appFeedback:
        return 'App Feedback';
      case PointsType.makeAppointment:
        return 'Make Appointment';
      case PointsType.appointmentComplete:
        return 'Complete Appointment';
      case PointsType.reviewWrite:
        return 'Write Review';
      case PointsType.referral:
        return 'Refer Friend';
      case PointsType.rewardRedeem:
        return 'Redeem Reward';
      case PointsType.other:
      default:
        return 'Other Activity';
    }
  }

  // Get points value for display
  static String getPointsValue(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return '+100';
      case PointsType.appointmentComplete:
        return '+50';
      case PointsType.rateSalon:
      case PointsType.reviewWrite:
      case PointsType.salonFeedback:
        return '+25';
      case PointsType.arriveOnTime:
      case PointsType.rateApp:
      case PointsType.appFeedback:
      case PointsType.makeAppointment:
        return '+10';
      case PointsType.rewardRedeem:
        return 'Redeem';
      case PointsType.other:
      default:
        return '+10';
    }
  }

  // Get actual points value as integer
  static int getPointsAmount(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return 100;
      case PointsType.appointmentComplete:
        return 50;
      case PointsType.rateSalon:
      case PointsType.reviewWrite:
      case PointsType.salonFeedback:
        return 25;
      case PointsType.arriveOnTime:
      case PointsType.rateApp:
      case PointsType.appFeedback:
      case PointsType.makeAppointment:
        return 10;
      case PointsType.rewardRedeem:
        return 0; // Redeeming costs points
      case PointsType.other:
      default:
        return 10;
    }
  }

  // UI component builders
  static Widget buildQuickActionChip(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildPointsRule(
    String title,
    String points,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColor.lightTextHint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.lightSuccess.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        points,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColor.lightSuccess,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: AppColor.lightTextHint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a points action card
  static Widget buildPointsActionCard(
    BuildContext context,
    PointsType type,
    VoidCallback onTap, {
    bool isEnabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? getActionColorDark(type) : getActionColor(type);
    final icon = getActionIcon(type);
    final title = getActionTitle(type);
    final subtitle = getActionSubtitle(type);
    final points = getPointsValue(type);

    final pointsColor = points == 'Redeem'
        ? AppColor.lightAccent
        : AppColor.lightSuccess;
    final pointsBackgroundColor = points == 'Redeem'
        ? AppColor.lightAccent.withValues(alpha: 0.2)
        : AppColor.lightSuccess.withValues(alpha: 0.2);

    final pointsColorDark = points == 'Redeem'
        ? AppColor.darkAccent
        : AppColor.darkSuccess;
    final pointsBackgroundColorDark = points == 'Redeem'
        ? AppColor.darkAccent.withValues(alpha: 0.2)
        : AppColor.darkSuccess.withValues(alpha: 0.2);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? pointsBackgroundColorDark : pointsBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            points,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? pointsColorDark : pointsColor,
            ),
          ),
        ),
        onTap: isEnabled ? onTap : null,
        enabled: isEnabled,
      ),
    );
  }

  // Get description for points history
  static String getPointsDescription(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return 'Invited a friend to join';
      case PointsType.rateSalon:
        return 'Rated a salon experience';
      case PointsType.arriveOnTime:
        return 'Arrived on time for appointment';
      case PointsType.salonFeedback:
        return 'Provided salon feedback';
      case PointsType.rateApp:
        return 'Rated the application';
      case PointsType.appFeedback:
        return 'Provided app feedback';
      case PointsType.makeAppointment:
        return 'Made a new appointment';
      case PointsType.appointmentComplete:
        return 'Completed appointment';
      case PointsType.reviewWrite:
        return 'Wrote a review';
      case PointsType.referral:
        return 'Referred a friend';
      case PointsType.rewardRedeem:
        return 'Redeemed reward';
      case PointsType.other:
      default:
        return 'Other activity';
    }
  }

  // Success message helper
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColor.light),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColor.lightSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Error message helper
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: AppColor.light),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColor.lightError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Get category for grouping points activities
  static String getPointsCategory(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return 'Referral';
      case PointsType.rateSalon:
      case PointsType.reviewWrite:
      case PointsType.salonFeedback:
        return 'Reviews & Feedback';
      case PointsType.arriveOnTime:
      case PointsType.makeAppointment:
      case PointsType.appointmentComplete:
        return 'Appointments';
      case PointsType.rateApp:
      case PointsType.appFeedback:
        return 'App Engagement';
      case PointsType.rewardRedeem:
        return 'Rewards';
      case PointsType.other:
      default:
        return 'Other';
    }
  }
}
