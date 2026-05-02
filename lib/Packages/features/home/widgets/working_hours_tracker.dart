import 'package:flutter/material.dart';
import '../../../Core/constants/app_color.dart';

class WorkingHoursTracker extends StatelessWidget {
  final Map<String, dynamic> workingHours;

  const WorkingHoursTracker({
    super.key,
    required this.workingHours,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOpen = workingHours['isOpen'] ?? false;
    final openingTime = workingHours['openingTime'] ?? '09:00';
    final closingTime = workingHours['closingTime'] ?? '20:00';
    final currentStatus = isOpen ? 'Open' : 'Closed';
    final statusColor = isOpen 
        ? (isDark ? AppColor.darkSuccess : AppColor.lightSuccess)
        : (isDark ? AppColor.darkError : AppColor.lightError);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColor.darkCard.withValues(alpha: 0.9)
            : AppColor.lightCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salon Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentStatus,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Hours',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$openingTime - $closingTime',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColor.darkText : AppColor.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
