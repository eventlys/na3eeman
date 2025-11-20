// helpers/points_tracker_helpers.dart
import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_color.dart';

enum PointsType {
  appointmentComplete,
  reviewWrite,
  referral,
  rewardRedeem,
  other,
}

class PointsTrackerHelpers {
  // Action styling helpers
  static Color getActionColor(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return AppColor.lightSuccess;
      case PointsType.reviewWrite:
        return AppColor.lightInfo;
      case PointsType.referral:
        return AppColor.lightAccent;
      case PointsType.rewardRedeem:
        return AppColor.primary;
      case PointsType.other:
        return AppColor.lightTextSecondary;
    }
  }

  static Color getActionColorDark(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return AppColor.darkSuccess;
      case PointsType.reviewWrite:
        return AppColor.darkInfo;
      case PointsType.referral:
        return AppColor.darkAccent;
      case PointsType.rewardRedeem:
        return AppColor.primary;
      case PointsType.other:
        return AppColor.darkTextSecondary;
    }
  }

  static IconData getActionIcon(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return Icons.calendar_today_rounded;
      case PointsType.reviewWrite:
        return Icons.star_rate_rounded;
      case PointsType.referral:
        return Icons.person_add_alt_1_rounded;
      case PointsType.rewardRedeem:
        return Icons.card_giftcard_rounded;
      case PointsType.other:
        return Icons.more_horiz_rounded;
    }
  }

  static String getActionSubtitle(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return 'Complete your appointments';
      case PointsType.reviewWrite:
        return 'Share your experience';
      case PointsType.referral:
        return 'Invite friends to join';
      case PointsType.rewardRedeem:
        return 'Redeem your points';
      case PointsType.other:
        return 'Various activities';
    }
  }

  static String getActionTitle(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return 'Complete Appointment';
      case PointsType.reviewWrite:
        return 'Write a Review';
      case PointsType.referral:
        return 'Refer a Friend';
      case PointsType.rewardRedeem:
        return 'Redeem Reward';
      case PointsType.other:
        return 'Other Activity';
    }
  }

  // Get points value for display
  static String getPointsValue(PointsType type) {
    switch (type) {
      case PointsType.appointmentComplete:
        return '+50';
      case PointsType.reviewWrite:
        return '+25';
      case PointsType.referral:
        return '+100';
      case PointsType.rewardRedeem:
        return 'Redeem';
      case PointsType.other:
        return '+10';
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
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
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

  static Widget buildPointsRule(String title, String points, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColor.lightTextHint),
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
}
