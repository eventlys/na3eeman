import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Retail sales snapshot for Studio tier.
class RetailSnapshotWidget extends StatelessWidget {
  const RetailSnapshotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owner = context.watch<OwnerProvider>();
    final snapshot = owner.retailSnapshot;

    final salesToday = '\$${snapshot['sales_today'] ?? 0.0}';
    final itemsSold = '${snapshot['items_sold_today'] ?? 0}';
    final avgSale = '\$${snapshot['avg_sale_price'] ?? 0.0}';
    final weeklySales = snapshot['weekly_sales'] as List? ?? [0,0,0,0,0,0,0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.storefront_rounded, size: 18, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text('retail_snapshot'.tr(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (owner.isAnalyticsLoading)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatTile('Sales Today', salesToday, Icons.sell_rounded, theme.primaryColor),
            _StatTile('Items Sold', itemsSold, Icons.inventory_2_rounded, theme.colorScheme.secondary),
            _StatTile('Avg. Sale', avgSale, Icons.analytics_rounded, Colors.green),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 100,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(weeklySales.length, (i) {
                final double val = (weeklySales[i] as num?)?.toDouble() ?? 0.0;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: val == 0 ? 5 : val, // Min height for visibility
                    color: theme.primaryColor.withOpacity(val == 0 ? 0.3 : 1),
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ]);
              }),
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 16,
                    getTitlesWidget: _dayLabel,
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _dayLabel(double val, TitleMeta meta) {
  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final index = val.toInt();
  if (index >= 0 && index < days.length) {
    return Text(days[index], style: const TextStyle(fontSize: 10, color: Colors.grey));
  }
  return const Text('');
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
