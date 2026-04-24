import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import 'package:easy_localization/easy_localization.dart';

class PointsTrackerWidget extends StatelessWidget {
  const PointsTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x99FFFFFF),
                Color(0x4DFFFFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0x80ffffff),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with points
              _buildHeader(context, pointsProvider),
              const SizedBox(height: 16),

              // Quick actions
              _buildQuickActions(context, pointsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PointsProvider pointsProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rewards Points',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Earn points and get rewards!',
              style: TextStyle(
                color: Color(0x80000000),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x66c25858), Color(0xCCC25858)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Color(0x80ffffff)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${pointsProvider.currentBalance} pts',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, PointsProvider pointsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.quickActions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickActionChip(
              context,
              'Rate App',
              Icons.star_rate_rounded,
              Colors.orange,
              () => _showRateAppDialog(context, pointsProvider),
            ),
            _buildQuickActionChip(
              context,
              'Feedback',
              Icons.feedback_rounded,
              Colors.purple,
              () => _showAppFeedbackDialog(context, pointsProvider),
            ),
            _buildQuickActionChip(
              context,
              'Invite Friend',
              Icons.person_add_alt_1_rounded,
              Colors.green,
              () => _inviteFriend(context, pointsProvider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
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

  void _showRateAppDialog(BuildContext context, PointsProvider pointsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How would you rate our app?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 2, 3, 4, 5].map((rating) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onPressed: () async {
                    try {
                      // You'll need to get the customer ID from somewhere
                      // For now, using a placeholder
                      final customerId = 1; // Replace with actual customer ID
                      await pointsProvider.rateApp(
                        customerId: customerId,
                        rating: rating,
                      );
                      Navigator.pop(context);
                      _showSuccessMessage(context, 'Thanks for your rating! Points added.');
                    } catch (e) {
                      Navigator.pop(context);
                      _showErrorMessage(context, 'Failed to submit rating');
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _showAppFeedbackDialog(BuildContext context, PointsProvider pointsProvider) {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.appFeedback),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We\'d love to hear your feedback!'),
            SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (feedbackController.text.trim().isNotEmpty) {
                try {
                  // You'll need to get the customer ID from somewhere
                  // For now, using a placeholder
                  final customerId = 1; // Replace with actual customer ID
                  await pointsProvider.submitAppFeedback(
                    customerId: customerId,
                    feedback: feedbackController.text.trim(),
                  );
                  Navigator.pop(context);
                  _showSuccessMessage(context, 'Thanks for your feedback! Points added.');
                } catch (e) {
                  Navigator.pop(context);
                  _showErrorMessage(context, 'Failed to submit feedback');
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
      ),
    );
  }

  void _inviteFriend(BuildContext context, PointsProvider pointsProvider) {
    final TextEditingController friendNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite a Friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Invite a friend to join and earn points!'),
            SizedBox(height: 16),
            TextField(
              controller: friendNameController,
              decoration: InputDecoration(
                hintText: 'Friend\'s name (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // You'll need to get the customer ID from somewhere
                // For now, using a placeholder
                final customerId = 1; // Replace with actual customer ID
                await pointsProvider.inviteFriend(
                  customerId: customerId,
                  friendName: friendNameController.text.trim().isNotEmpty 
                      ? friendNameController.text.trim() 
                      : null,
                );
                Navigator.pop(context);
                _showSuccessMessage(context, 'Friend invited! Points added.');
              } catch (e) {
                Navigator.pop(context);
                _showErrorMessage(context, 'Failed to invite friend');
              }
            },
            child: Text('Invite'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
