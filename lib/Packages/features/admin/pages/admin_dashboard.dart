import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin (God Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButtonStyled(
            icon: Icons.shield_rounded,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Stats Row
            Row(
              children: [
                Expanded(child: _buildKpiCard('Total Users', '42.3k', Icons.people_rounded, Theme.of(context).primaryColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Active Shops', '3,872', Icons.storefront_rounded, AppColors.pink)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildKpiCard('Subscriptions', '1.2k', Icons.workspace_premium_rounded, AppColors.success)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Avg. Revenue', '\$89k', Icons.payments_rounded, AppColors.cream600)),
              ],
            ),

            const SizedBox(height: 32),

            // System Health / API Monitor
            _buildSectionHeader('System Health', 'View API Logs'),
            const SizedBox(height: 16),
            _buildHealthMonitor('Backend API', '99.9% Uptime', AppColors.success),
            _buildHealthMonitor('Payment Gateway', 'Active', AppColors.success),
            _buildHealthMonitor('Firebase Auth', 'Partial Outage', AppColors.warning),

            const SizedBox(height: 32),

            // Admin Modules
            _buildSectionHeader('Admin Modules', 'Settings'),
            const SizedBox(height: 16),
            _buildModuleGrid(),

            const SizedBox(height: 32),

            // Error & Crash Logs
            _buildSectionHeader('Critical Errors', 'Clear All'),
            const SizedBox(height: 16),
            _buildErrorLog('Payment Failed (User #202)', 'JSON Parse Error @ /pay', '2m ago'),
            _buildErrorLog('Auth Token Expired', 'Unauthorized @ /profile', '15m ago'),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: Text(action, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHealthMonitor(String name, String status, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    final modules = [
      {'label': 'Users', 'icon': Icons.manage_accounts_rounded, 'route': '/admin/users'},
      {'label': 'Finance', 'icon': Icons.account_balance_rounded, 'route': '/admin/finance'},
      {'label': 'Analytics', 'icon': Icons.insights_rounded, 'route': '/admin/analytics'},
      {'label': 'Subs', 'icon': Icons.loyalty_rounded, 'route': '/admin/subs'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final m = modules[index];
        return _buildModuleTile(m['label'] as String, m['icon'] as IconData);
      },
    );
  }

  Widget _buildModuleTile(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildErrorLog(String title, String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report_rounded, color: AppColors.error),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                Text(message, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 11)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.almostBlack200, fontSize: 10)),
        ],
      ),
    );
  }
}
