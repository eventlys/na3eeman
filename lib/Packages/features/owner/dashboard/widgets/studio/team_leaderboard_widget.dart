import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Team performance leaderboard (Studio tier).
class TeamLeaderboardWidget extends StatelessWidget {
  const TeamLeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();
    final theme = Theme.of(context);
    final leaderboard = owner.leaderboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.leaderboard_rounded,
                  size: 18,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  "team_leaderboard".tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (owner.isAnalyticsLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (leaderboard.isEmpty && !owner.isAnalyticsLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "no_data_available".tr(),
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
            ),
          ),
        ...leaderboard.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final s = entry.value;
          final name = s['name'] ?? 'Staff';
          final bookings = s['total_appointments'] ?? 0;
          final rating = (s['average_rating'] as num?)?.toDouble() ?? 0.0;
          final earnings = '\$${s['total_earnings'] ?? 0}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? Colors.amber
                        : rank == 2
                        ? Colors.grey.shade400
                        : Colors.brown.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$rating  · $bookings books',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  earnings,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
