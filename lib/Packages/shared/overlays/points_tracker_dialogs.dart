import 'package:flutter/material.dart';
import '../../../Helpers/customized/points_tracker_helpers.dart';
import '../../../Providers/main_providers.dart';
import '../../Core/constants/app_color.dart';
import 'package:easy_localization/easy_localization.dart';

class PointsTrackerDialogs {
  // Rate App Dialog
  static void showRateAppDialog(BuildContext context, PointsProvider pointsProvider, int customerId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.star_rate_rounded, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(
              'Rate Our App',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Love our app? Rate us on the store and earn 25 points!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await pointsProvider.rateApp(customerId: customerId, rating: 5);
                Navigator.pop(context);
                PointsTrackerHelpers.showSuccessMessage(context, '🎉 Thanks for rating! +25 points');
              } catch (error) {
                Navigator.pop(context);
                PointsTrackerHelpers.showErrorMessage(context, 'Failed to add points. Please try again.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: isDark ? AppColor.dark : AppColor.light,
            ),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  // App Feedback Dialog
  static void showAppFeedbackDialog(BuildContext context, PointsProvider pointsProvider, int customerId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.feedback_rounded, color: AppColor.primary),
            const SizedBox(width: 8),
            Text('app_feedback'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Help us improve by sharing your feedback and earn 50 points!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColor.primary),
                ),
                filled: true,
                fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
              ),
              maxLines: 3,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final feedback = feedbackController.text.trim();
              try {
                await pointsProvider.submitAppFeedback(
                  customerId: customerId,
                  feedback: feedback.isNotEmpty ? feedback : null,
                );
                Navigator.pop(context);
                PointsTrackerHelpers.showSuccessMessage(context, '🎉 Thanks for your feedback! +50 points');
              } catch (error) {
                Navigator.pop(context);
                PointsTrackerHelpers.showErrorMessage(context, 'Failed to submit feedback. Please try again.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: isDark ? AppColor.dark : AppColor.light,
            ),
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }

  // More Points Info Dialog
  static void showMorePointsDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(
              'How to Earn Points',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPointsRule(context, 'Complete Appointment', '+50 points', 'For each completed appointment'),
              _buildPointsRule(context, 'Write Review', '+25 points', 'Share your experience'),
              _buildPointsRule(context, 'Refer Friend', '+100 points', 'Invite friends to join'),
              _buildPointsRule(context, 'Rate App', '+25 points', 'One-time reward'),
              _buildPointsRule(context, 'App Feedback', '+50 points', 'One-time reward'),
              _buildPointsRule(context, 'Other Activities', '+10 points', 'Various engagement activities'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Invite Friend Dialog
  static void showInviteFriendDialog(BuildContext context, PointsProvider pointsProvider, int customerId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final TextEditingController friendNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColor.primary),
            const SizedBox(width: 8),
            Text(
              'Invite Friend',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invite a friend to join and earn 100 points when they sign up!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: friendNameController,
              decoration: InputDecoration(
                hintText: "Friend's name (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColor.primary),
                ),
                filled: true,
                fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
              ),
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(),
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final friendName = friendNameController.text.trim();
              try {
                await pointsProvider.inviteFriend(
                  customerId: customerId,
                  friendName: friendName.isNotEmpty ? friendName : null,
                );
                Navigator.pop(context);
                PointsTrackerHelpers.showSuccessMessage(context, '🎉 Friend invited! +100 points');
              } catch (error) {
                Navigator.pop(context);
                PointsTrackerHelpers.showErrorMessage(context, 'Failed to invite friend. Please try again.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: isDark ? AppColor.dark : AppColor.light,
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  // Updated points rule builder to use AppColor
  static Widget _buildPointsRule(BuildContext context, String title, String points, String description) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              points,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
