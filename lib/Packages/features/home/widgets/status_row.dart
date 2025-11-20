import 'package:flutter/material.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';

class StatsRow extends StatelessWidget {
  final int completedOrders;
  final int pendingOrders;

  const StatsRow({
    super.key,
    required this.completedOrders,
    required this.pendingOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Completed',
              value: completedOrders.toString(),
              // color: AppColor.lightSuccess,
              // darkColor: AppColor.darkSuccess,
              icon: AppImages.check,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'Pending',
              value: pendingOrders.toString(),
              // color: AppColor.lightWarning,
              // darkColor: AppColor.darkWarning,
              icon: AppImages.clock,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  // final Color color;
  // final Color darkColor;
  final String icon;

  const _StatCard({
    required this.title,
    required this.value,
    // required this.color,
    // required this.darkColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColor.darkCard.withValues(alpha: 0.9)
            : AppColor.lightCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColor.dark.withValues(alpha: 0.1)
                : AppColor.light.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:  isDark ? AppColor.darkText : AppColor.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
