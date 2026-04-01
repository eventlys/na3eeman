import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Daily earnings breakdown: cash vs card (Artisan tier).
/// Fetches real data from GET /shops/shops/{id}/daily_earnings/
class DailyEarningsWidget extends StatelessWidget {
  const DailyEarningsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owner = context.watch<OwnerProvider>();
    final earnings = owner.dailyEarnings;

    final cash = (earnings['cash'] as num?)?.toDouble() ?? 0.0;
    final card = (earnings['card'] as num?)?.toDouble() ?? 0.0;
    final total = (earnings['total'] as num?)?.toDouble() ?? (cash + card);

    final bool isLoading = owner.isAnalyticsLoading && earnings.isEmpty;

    if (isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // When there is no data yet (first run, no paid appointments today)
    final bool noData = total == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('today_s_earnings'),
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 4),
                Text(
                  'JD ${total.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 80,
              width: 80,
              child: noData
                  ? Center(
                      child: Text('No sales\ntoday',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10, color: theme.hintColor)),
                    )
                  : PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: cash,
                            color: theme.primaryColor,
                            title: '',
                            radius: 30,
                          ),
                          PieChartSectionData(
                            value: card,
                            color: theme.colorScheme.secondary,
                            title: '',
                            radius: 30,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 18,
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Legend(color: theme.primaryColor, label: 'cash'.tr(), amount: cash),
            const SizedBox(width: 24),
            _Legend(
                color: theme.colorScheme.secondary,
                label: 'card'.tr(),
                amount: card),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  const _Legend(
      {required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: JD ${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
