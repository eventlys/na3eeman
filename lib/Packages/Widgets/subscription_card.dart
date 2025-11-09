import 'package:flutter/material.dart';
import '../../Models/subscription.dart';
import '../../Utils/constants.dart';
import '../../Utils/formatters.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onUpgrade;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: subscription.status == "Active"
                      ? AppColors.successColor.withValues(alpha: 0.2)
                      : AppColors.warningColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription.status,
                    style: TextStyle(
                      color: subscription.status == "Active"
                        ? AppColors.successColor
                        : AppColors.warningColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              subscription.planName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${Formatters.formatCurrency(subscription.price)}/month',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textColor.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.primaryColor),
                SizedBox(width: 8),
                Text(
                  '${subscription.daysRemaining} days remaining',
                  style: TextStyle(
                    color: subscription.daysRemaining < 7
                      ? AppColors.errorColor
                      : AppColors.textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: subscription.features.map((feature) => Chip(
                label: Text(feature),
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: AppColors.primaryColor),
              )).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Upgrade Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

