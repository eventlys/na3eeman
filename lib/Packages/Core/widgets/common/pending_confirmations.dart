import 'package:flutter/material.dart';
import '../../constants/app_color.dart';

class PendingConfirmations extends StatelessWidget {
  final List<dynamic> pendingConfirmations;
  final Function(int) onConfirmationSuccess;

  const PendingConfirmations({
    super.key,
    required this.pendingConfirmations,
    required this.onConfirmationSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending Confirmations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.darkText : AppColor.lightText,
            ),
          ),
          const SizedBox(height: 12),
          ...pendingConfirmations.map((confirmation) => _ConfirmationItem(
                confirmation: confirmation,
                onConfirm: () {
                  final id = confirmation['id'] as int;
                  onConfirmationSuccess(id);
                },
              )),
        ],
      ),
    );
  }
}

class _ConfirmationItem extends StatelessWidget {
  final dynamic confirmation;
  final VoidCallback onConfirm;

  const _ConfirmationItem({
    required this.confirmation,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColor.darkBackground.withValues(alpha: 0.5)
            : AppColor.lightBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? AppColor.darkTextHint.withValues(alpha: 0.2)
              : AppColor.lightTextHint.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  confirmation['customerName'] ?? 'Customer',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? AppColor.darkText : AppColor.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  confirmation['service'] ?? 'Service',
                  style: TextStyle(
                    color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  confirmation['time'] ?? 'Time',
                  style: TextStyle(
                    color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
              foregroundColor: AppColor.light,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
