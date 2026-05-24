import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_color.dart';

class EarningsChart extends StatelessWidget {
  final dynamic earningsData;

  const EarningsChart({super.key, required this.earningsData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Handle List data (which is what your API returns)
    if (earningsData is List) {
      final List<dynamic> earningsList = earningsData as List;
      return _buildWeeklyChart(earningsList, theme, isDark, context);
    } else {
      return _buildEmptyChart(theme, isDark, context);
    }
  }

  Widget _buildWeeklyChart(
    List<dynamic> earningsList,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    if (earningsList.isEmpty) {
      return _buildEmptyChart(theme, isDark, context);
    }

    // Process the data
    final List<Map<String, dynamic>> chartData = [];
    double maxAmount = 0;

    for (var item in earningsList) {
      if (item is Map<String, dynamic>) {
        final amount = (item['amount'] ?? 0).toDouble();
        chartData.add(item);
        if (amount > maxAmount) maxAmount = amount;
      }
    }

    if (chartData.isEmpty) {
      return _buildEmptyChart(theme, isDark, context);
    }

    final Color cardColor =
        theme.cardTheme.color ??
        (isDark ? AppColor.darkCard : AppColor.lightCard);
    final Color textColor = theme.colorScheme.onSurface;
    final Color textSecondaryColor = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;
    final Color barColor = theme.primaryColor;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "weekly_earnings_trend".tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((day) {
                final amount = (day['amount'] ?? 0).toDouble();
                final date = DateTime.parse(
                  day['date'] ?? DateTime.now().toIso8601String(),
                );

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '\$${amount.toInt()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: barColor.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                barColor.withValues(alpha: 0.9),
                                barColor.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                          height: maxAmount > 0
                              ? (amount / maxAmount) * 150
                              : 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDayAbbreviation(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildStats(chartData, theme, isDark, context),
        ],
      ),
    );
  }

  Widget _buildStats(
    List<Map<String, dynamic>> chartData,
    ThemeData theme,
    bool isDark,
    BuildContext context,
  ) {
    final totalEarnings = chartData
        .map((e) => (e['amount'] ?? 0).toDouble())
        .reduce((a, b) => a + b);
    final totalAppointments = chartData
        .map((e) => (e['appointments'] ?? 0) as int)
        .reduce((a, b) => a + b);
    final averagePerAppointment = totalAppointments > 0
        ? totalEarnings / totalAppointments
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: "total".tr(),
          value: '\$${totalEarnings.toStringAsFixed(0)}',
          color: isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
          theme: theme,
        ),
        _StatItem(
          label: "appointments".tr(),
          value: totalAppointments.toString(),
          color: isDark ? AppColor.darkInfo : AppColor.lightInfo,
          theme: theme,
        ),
        _StatItem(
          label: "average".tr(),
          value: '\$${averagePerAppointment.toStringAsFixed(0)}',
          color: isDark ? AppColor.darkWarning : AppColor.lightWarning,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildEmptyChart(ThemeData theme, bool isDark, BuildContext context) {
    final Color cardColor =
        theme.cardTheme.color ??
        (isDark ? AppColor.darkCard : AppColor.lightCard);
    final Color textColor = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "no_earnings_data_available".tr(),
          style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
        ),
      ),
    );
  }

  String _getDayAbbreviation(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final Color textColor = isDark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: textColor),
        ),
      ],
    );
  }
}
