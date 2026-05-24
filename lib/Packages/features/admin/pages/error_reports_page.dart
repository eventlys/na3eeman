import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AdminErrorReportsPage extends StatelessWidget {
  const AdminErrorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Error Logs & Crashes',
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
              'Critical Crashes (Last 24h)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCrashItem(
              'Null Check Error',
              'User #42 • Android 14',
              '12m ago',
            ),
            _buildCrashItem('Out of Memory', 'User #109 • iOS 17', '1h ago'),

            const SizedBox(height: 32),
            const Text(
              'API Failure Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFailureStat('/auth/login', '2.4%', AppColors.success),
            _buildFailureStat('/bookings/pay', '12.8%', AppColors.error),
            _buildFailureStat('/salons/list', '0.1%', AppColors.success),

            const SizedBox(height: 32),
            const Text(
              'Recent Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLogTile(
              'DEBUG',
              'Init firebase messaging...',
              '2m ago',
              context,
            ),
            _buildLogTile('INFO', 'User @Jafar logged in', '5m ago', context),
            _buildLogTile(
              'WARN',
              'API latency high @ /salons',
              '12m ago',
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrashItem(String title, String device, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, color: AppColors.error),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  device,
                  style: const TextStyle(
                    color: AppColors.almostBlack300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.almostBlack200,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureStat(String endpoint, String rate, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            endpoint,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          Text(
            rate,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile(
    String level,
    String msg,
    String time,
    BuildContext context,
  ) {
    final color = level == 'WARN'
        ? AppColors.warning
        : (level == 'DEBUG'
              ? Theme.of(context).primaryColor
              : AppColors.success);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$level]',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.almostBlack200,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
