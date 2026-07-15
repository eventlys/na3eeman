import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Multi-branch comparison map (Empire tier).
/// Uses real salon leaderboard data from OwnerProvider.leaderboard.
/// Per-salon branch comparison requires a multi-branch backend — currently
/// shows per-expert performance as a proxy until branch-level analytics land.
class BranchComparisonMapWidget extends StatelessWidget {
  const BranchComparisonMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owner = context.watch<OwnerProvider>();
    final leaderboard = owner.leaderboard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.map_rounded, size: 18, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              "branch_comparison".tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
          _EmptySectionPlaceholder(
            icon: Icons.map_outlined,
            message: 'No branch data yet. Add staff to see performance here.',
          ),
        ...leaderboard.take(3).toList().asMap().entries.map((entry) {
          final idx = entry.key;
          final s = entry.value;
          final name = (s['name'] as String?) ?? 'Staff ${idx + 1}';
          final earnings = (s['total_earnings'] as num?)?.toDouble() ?? 0.0;
          final bookings = (s['total_appointments'] as num?)?.toInt() ?? 0;
          // Derive a synthetic occupancy % from bookings (capped at 100%)
          final occupancy = (bookings * 10).clamp(0, 100);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                if (idx == 0)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  )
                else
                  const SizedBox(width: 26),
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
                          Expanded(
                            child: LinearProgressIndicator(
                              value: occupancy / 100,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.teal,
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$occupancy%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'JD ${earnings.toStringAsFixed(0)}',
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

class _EmptySectionPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptySectionPlaceholder({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
