import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../Models/intern/intern_models.dart';

class MonthlyTargetWidget extends StatelessWidget {
  final InternTarget target;
  final bool isNumericView;

  const MonthlyTargetWidget({
    super.key,
    required this.target,
    this.isNumericView = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack700 : AppColors.almostBlack50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  target.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'By ${target.setByName}',
                  style: const TextStyle(fontSize: 10, color: AppColors.almostBlack300),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isNumericView
                        ? '${target.currentValue}/${target.targetValue} Sessions'
                        : '${target.percentageCompletion.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                target.percentageCompletion >= 100 ? Icons.check_circle_rounded : Icons.pending_rounded,
                color: target.percentageCompletion >= 100 ? Colors.green : Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: target.currentValue / target.targetValue,
            backgroundColor: AppColors.almostBlack100.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              target.percentageCompletion >= 100 ? Colors.green : Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
