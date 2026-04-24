import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AdminSubscriptionManagementPage extends StatelessWidget {
  const AdminSubscriptionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Subscription Control', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard('Active Subscriptions', '1,240', AppColors.success, context),
            const SizedBox(height: 24),
            const Text('Revenue by Tier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTierProgress('Basic', 0.4, '\$12,000', Theme.of(context).primaryColor, context),
            _buildTierProgress('Gold', 0.25, '\$25,000', AppColors.cream600, context),
            _buildTierProgress('Premium', 0.2, '\$45,000', AppColors.pink, context),
            _buildTierProgress('Business', 0.15, '\$80,000', AppColors.success, context),
            
            const SizedBox(height: 32),
            const Text('Recent Upgrades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildUpgradeLog('Gentlemen Lounge', 'Basic → Premium', '10m ago', context),
            _buildUpgradeLog('Royal Cut', 'Gold → Business', '1h ago', context),
            _buildUpgradeLog('Modern Styles', 'New Subscription: Basic', '3h ago', context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTierProgress(String label, double percent, String revenue, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(revenue, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeLog(String salon, String change, String time, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(salon, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(change, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.almostBlack200, fontSize: 10)),
        ],
      ),
    );
  }
}
