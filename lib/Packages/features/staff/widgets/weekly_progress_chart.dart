import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class WeeklyProgressChart extends StatelessWidget {
  const WeeklyProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack700 : AppColors.almostBlack50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Icon(
                Icons.show_chart_rounded,
                size: 16,
                color: AppColors.almostBlack300,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            days[value.toInt() % 7],
                            style: const TextStyle(
                              color: AppColors.almostBlack300,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 4, Theme.of(context).primaryColor),
                  _makeBarGroup(1, 6, Theme.of(context).primaryColor),
                  _makeBarGroup(2, 3, Theme.of(context).primaryColor),
                  _makeBarGroup(3, 8, Theme.of(context).primaryColor),
                  _makeBarGroup(4, 5, Theme.of(context).primaryColor),
                  _makeBarGroup(5, 7, Theme.of(context).primaryColor),
                  _makeBarGroup(6, 2, Theme.of(context).primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 12,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: AppColors.almostBlack100.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
