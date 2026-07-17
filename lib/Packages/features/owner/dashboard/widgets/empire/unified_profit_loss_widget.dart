// ignore_for_file: unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Unified Profit & Loss view for Empire tier.
/// Revenue data comes from retail_snapshot (sales_today + weekly_sales).
/// Expenses are not yet tracked by the backend — shown as N/A with a roadmap note.
class UnifiedProfitLossWidget extends StatelessWidget {
  const UnifiedProfitLossWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owner = context.watch<OwnerProvider>();
    final snapshot = owner.retailSnapshot;

    final salesToday = (snapshot['sales_today'] as num?)?.toDouble() ?? 0.0;
    final weeklySales =
        snapshot['weekly_sales'] as List? ?? [0, 0, 0, 0, 0, 0, 0];

    // Calculate weekly total from the flat list
    final weeklyTotal = weeklySales.fold<double>(
      0.0,
      (sum, v) => sum + ((v as num?)?.toDouble() ?? 0.0),
    );

    // Expenses tracking is a future feature — show as placeholder
    const expenses = 0.0;
    final net = weeklyTotal - expenses;

    // Build FlSpots from weekly_sales (7-element list)
    final spots = List.generate(weeklySales.length, (i) {
      final val = (weeklySales[i] as num?)?.toDouble() ?? 0.0;
      return FlSpot(i.toDouble(), val);
    });

    final bool hasData = weeklyTotal > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.account_balance_rounded,
              size: 18,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              "unified_pl".tr(),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PLStat(
              'Revenue (7d)',
              'JD ${(weeklyTotal / 1000).toStringAsFixed(1)}k',
              Colors.green,
            ),
            _PLStat(
              'Today',
              'JD ${salesToday.toStringAsFixed(0)}',
              theme.primaryColor,
            ),
            _PLStat(
              'Expenses',
              expenses == 0
                  ? 'N/A'
                  : '-JD ${(expenses / 1000).toStringAsFixed(1)}k',
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Roadmap note for expenses
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '💡 Expense tracking coming soon. Revenue data is live.',
            style: TextStyle(fontSize: 10, color: Colors.orange),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: hasData
              ? LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: theme.primaryColor,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'No revenue data for this week yet.',
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PLStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PLStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ],
  );
}
