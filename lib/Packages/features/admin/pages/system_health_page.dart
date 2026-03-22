import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AdminSystemHealthPage extends StatelessWidget {
  const AdminSystemHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('System Health', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('API Response Times', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildMetricsCard('Core API', '120ms', AppColors.success),
            _buildMetricsCard('Auth Service', '240ms', AppColors.success),
            _buildMetricsCard('Payment Gateway', '850ms', AppColors.warning),
            _buildMetricsCard('Media Storage', '1.2s', AppColors.error),

            const SizedBox(height: 32),
            const Text('Active Workers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildWorkerStatus('Email Dispatcher', 'Running', AppColors.success),
            _buildWorkerStatus('Push Service', 'Idle', Theme.of(context).primaryColor),
            _buildWorkerStatus('Backup Job', 'Failed (Retry in 5m)', AppColors.error),

            const SizedBox(height: 32),
            const Text('Server Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCapacityGauge('CPU Usage', 0.45, 'Optimal', context),
            _buildCapacityGauge('Memory usage', 0.78, 'High', context),
            _buildCapacityGauge('Disk IO', 0.12, 'Low', context),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(String service, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWorkerStatus(String name, String status, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildCapacityGauge(String label, double percent, String note, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${(percent * 100).toInt()}% • $note', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              color: percent > 0.8 ? AppColors.error : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
