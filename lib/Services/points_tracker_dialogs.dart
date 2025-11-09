import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../Models/points_model.dart';
import '../../Providers/points_provider.dart';
import 'points_tracker_helpers.dart';

class PointsTrackerDialogs {
  // Rate App Dialog
  static void showRateAppDialog(BuildContext context, PointsProvider pointsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star_rate_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Rate Our App'),
          ],
        ),
        content: const Text('Love our app? Rate us on the store and earn 50 points!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              pointsProvider.addPoints(PointsType.rateApp);
              Navigator.pop(context);
              PointsTrackerHelpers.showSuccessMessage(context, '🎉 Thanks for rating! +50 points');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  // App Feedback Dialog
  static void showAppFeedbackDialog(BuildContext context, PointsProvider pointsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.feedback_rounded, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('App Feedback'),
          ],
        ),
        content: const Text('Help us improve by sharing your feedback and earn 50 points!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              pointsProvider.addPoints(PointsType.appFeedback);
              Navigator.pop(context);
              PointsTrackerHelpers.showSuccessMessage(context, '🎉 Thanks for your feedback! +50 points');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Share Feedback'),
          ),
        ],
      ),
    );
  }

  // More Points Info Dialog
  static void showMorePointsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('How to Earn Points'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PointsTrackerHelpers.buildPointsRule('Make Appointment', '+10 points', 'For each appointment booked'),
              PointsTrackerHelpers.buildPointsRule('Arrive On Time', '+10 points', 'For punctual arrivals'),
              PointsTrackerHelpers.buildPointsRule('Rate Shop', '+15 points', 'After service completion'),
              PointsTrackerHelpers.buildPointsRule('Shop Feedback', '+20 points', 'Share your experience'),
              PointsTrackerHelpers.buildPointsRule('Invite Friend', '+25 points', 'Share with friends'),
              PointsTrackerHelpers.buildPointsRule('Rate App', '+50 points', 'One-time reward'),
              PointsTrackerHelpers.buildPointsRule('App Feedback', '+50 points', 'One-time reward'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // Invite Friend Function
  static void inviteFriend(BuildContext context, PointsProvider pointsProvider) {
    pointsProvider.addPoints(PointsType.inviteFriend);
    PointsTrackerHelpers.showSuccessMessage(context, 'Friend invited! +25 points');
  }
}

