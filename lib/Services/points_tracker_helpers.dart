import 'package:flutter/material.dart';
import '../../Models/points_model.dart';

class PointsTrackerHelpers {
  // Action styling helpers
  static Color getActionColor(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return Colors.green;
      case PointsType.rateShop:
        return Colors.blue;
      case PointsType.arriveOnTime:
        return Colors.orange;
      case PointsType.shopFeedback:
        return Colors.purple;
      case PointsType.rateApp:
        return Colors.orange;
      case PointsType.appFeedback:
        return Colors.purple;
      case PointsType.makeAppointment:
        return Colors.teal;
    }
  }

  static IconData getActionIcon(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return Icons.person_add_alt_1_rounded;
      case PointsType.rateShop:
        return Icons.star_rate_rounded;
      case PointsType.arriveOnTime:
        return Icons.access_time_rounded;
      case PointsType.shopFeedback:
        return Icons.reviews_rounded;
      case PointsType.rateApp:
        return Icons.star_rate_rounded;
      case PointsType.appFeedback:
        return Icons.feedback_rounded;
      case PointsType.makeAppointment:
        return Icons.calendar_today_rounded;
    }
  }

  static String getActionSubtitle(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return 'Share with friends';
      case PointsType.rateShop:
        return 'After service completion';
      case PointsType.arriveOnTime:
        return 'For each appointment';
      case PointsType.shopFeedback:
        return 'Share your experience';
      case PointsType.rateApp:
        return 'One-time reward';
      case PointsType.appFeedback:
        return 'One-time reward';
      case PointsType.makeAppointment:
        return 'For each booking';
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
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
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade600),
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
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        points,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Success message helper
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

