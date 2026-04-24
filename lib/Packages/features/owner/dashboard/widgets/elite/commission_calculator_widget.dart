import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Commission calculator for staff (Elite tier).
/// Reads real data from OwnerProvider.leaderboard (team leaderboard endpoint).
/// Commission rate is a fixed 30% applied to each staff member's earnings.
class CommissionCalculatorWidget extends StatelessWidget {
  const CommissionCalculatorWidget({super.key});

  /// Default commission rate (30%). In a production system this would come from
  /// a staff-level setting or a dedicated /commissions/ endpoint.
  static const double _defaultRate = 0.30;

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
            Icon(Icons.calculate_rounded, size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.commissionCalculator,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (owner.isAnalyticsLoading)
              const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
        const SizedBox(height: 14),
        if (leaderboard.isEmpty && !owner.isAnalyticsLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No staff data available.',
                style: TextStyle(color: theme.hintColor, fontSize: 12)),
          ),
        if (leaderboard.isNotEmpty)
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: theme.dividerColor))),
                children: ['Staff', 'Revenue', 'Rate', 'Commission']
                    .map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(h,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: theme.hintColor,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
              ...leaderboard.take(5).map((s) {
                final name = (s['name'] as String?) ?? 'Staff';
                final revenue =
                    (s['total_earnings'] as num?)?.toDouble() ?? 0.0;
                final rate = _defaultRate;
                final comm = revenue * rate;
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('JD ${revenue.toInt()}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('${(rate * 100).toInt()}%'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('JD ${comm.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }
}
