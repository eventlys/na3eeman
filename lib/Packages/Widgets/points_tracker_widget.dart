import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/points_model.dart';
import '../../Providers/points_provider.dart';
import '../../Services/points_service.dart';
import '../../Services/points_tracker_dialogs.dart';
import '../../Services/points_tracker_helpers.dart';

class PointsTrackerWidget extends StatelessWidget {
  const PointsTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        final availableActions = PointsType.values
            .where((type) => pointsProvider.canEarnPoints(type))
            .toList();

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
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withValues(alpha:0.15),
            //     blurRadius: 12,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
            border: Border.all(
              color: Color(0x80ffffff),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with points and progress
              _buildHeader(context, pointsProvider),
              const SizedBox(height: 16),

              // Available actions
              if (availableActions.isNotEmpty) ...[
                _buildAvailableActions(context, pointsProvider, availableActions),
                const SizedBox(height: 16),
              ],

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
            // boxShadow: [
            //   BoxShadow(
            //     color: Color(0x80806C99),
            //     blurRadius: 8,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
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
                '${pointsProvider.points.totalPoints} pts',
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

  Widget _buildAvailableActions(BuildContext context, PointsProvider pointsProvider, List<PointsType> availableActions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Available Rewards',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showAvailableActionsPopup(context, pointsProvider, availableActions),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${availableActions.length} available',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAvailableActionsPopup(BuildContext context, PointsProvider pointsProvider, List<PointsType> availableActions) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Rewards',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Complete these actions to earn points:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ...availableActions.map((type) => _buildPopupActionCard(context, pointsProvider, type)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupActionCard(BuildContext context, PointsProvider pointsProvider, PointsType type) {
    final pointsValue = PointsService.getPointsValue(type);
    final description = PointsService.pointsDescriptions[type]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PointsTrackerHelpers.getActionColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              PointsTrackerHelpers.getActionIcon(type),
              color: PointsTrackerHelpers.getActionColor(type),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  PointsTrackerHelpers.getActionSubtitle(type),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PointsTrackerHelpers.getActionColor(type),
                  PointsTrackerHelpers.getActionColor(type).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '+$pointsValue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, PointsProvider pointsProvider) {
    final hasQuickActions = pointsProvider.canEarnPoints(PointsType.rateApp) ||
                           pointsProvider.canEarnPoints(PointsType.appFeedback);
    if (!hasQuickActions) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (pointsProvider.canEarnPoints(PointsType.rateApp))
              PointsTrackerHelpers.buildQuickActionChip(
                context,
                'Rate App',
                Icons.star_rate_rounded,
                Colors.orange,
                () => PointsTrackerDialogs.showRateAppDialog(context, pointsProvider),
              ),
            if (pointsProvider.canEarnPoints(PointsType.appFeedback))
              PointsTrackerHelpers.buildQuickActionChip(
                context,
                'Feedback',
                Icons.feedback_rounded,
                Colors.purple,
                () => PointsTrackerDialogs.showAppFeedbackDialog(context, pointsProvider),
              ),
            if (pointsProvider.canEarnPoints(PointsType.appFeedback))
              PointsTrackerHelpers.buildQuickActionChip(
                context,
                'Invite a friend',
                Icons.feedback_rounded,
                Colors.green,
                () => PointsTrackerDialogs.inviteFriend(context, pointsProvider),
              ),
          ],
        ),
      ],
    );
  }

}

