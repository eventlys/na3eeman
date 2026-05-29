import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AdminUserAnalyticsPage extends StatelessWidget {
  const AdminUserAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'User Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Active Users (DAU)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChartPlaceholder('DAU: 5,240 (↑ 12%)', context),

            const SizedBox(height: 32),
            const Text(
              'User Retention',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRetentionRow('Day 1', '68%', AppColors.success),
            _buildRetentionRow('Day 7', '42%', Theme.of(context).primaryColor),
            _buildRetentionRow('Day 30', '18%', AppColors.cream600),

            const SizedBox(height: 32),
            const Text(
              'Feature Popularity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureUsage(
              'Salon Search',
              '14.2k clicks',
              0.9,
              Theme.of(context).primaryColor,
              context,
            ),
            _buildFeatureUsage(
              'Booking',
              '3.8k attempts',
              0.6,
              AppColors.pink,
              context,
            ),
            _buildFeatureUsage(
              'Loyalty Check',
              '1.2k clicks',
              0.2,
              AppColors.cream600,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(String label, BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha:0.1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_rounded,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetentionRow(String day, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureUsage(
    String name,
    String value,
    double percent,
    Color color,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.almostBlack300,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
