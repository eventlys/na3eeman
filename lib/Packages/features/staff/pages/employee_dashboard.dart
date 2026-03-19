import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
// import '../../appointments/widgets/appointments_list.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load employee specific data
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${user?.specialization ?? "Staff"} Dashboard', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButtonStyled(
            icon: Icons.notifications_none_rounded,
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Hello, ${user?.firstName ?? "Member"}! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You have 5 appointments scheduled for today.',
                style: TextStyle(color: isDark ? AppColors.cream600 : AppColors.almostBlack300),
              ),
              
              const SizedBox(height: 32),

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Today\'s Profit', '\$120.00', Icons.account_balance_wallet_rounded, AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Completed', '3', Icons.check_circle_rounded, Theme.of(context).primaryColor)),
                ],
              ),

              const SizedBox(height: 32),

              // Appointment States Section
              _buildSectionHeader('Today\'s Appointments', () {}),
              const SizedBox(height: 16),
              _buildAppointmentStatesFilter(),
              const SizedBox(height: 12),
              // Simplified appointment list placeholders for now
              _buildAppointmentItem('Ahmed Al-Rashid', '10:00 AM', 'Haircut', 'Waiting', AppColors.warning),
              _buildAppointmentItem('Sara Khalid', '11:45 AM', 'Beard Trim', 'Done', AppColors.success),
              _buildAppointmentItem('Omar Bakr', '01:30 PM', 'Massage', 'Pending Payment', AppColors.pink),

              const SizedBox(height: 32),

              // Inventory & Tools Section
              _buildSectionHeader('Tools & Inventory', () {}),
              const SizedBox(height: 16),
              _buildToolCard('Personal Kit', '8/10 Items Ready', Icons.handyman_rounded),
              const SizedBox(height: 12),
              _buildToolCard('Consumables', 'Low Stock: Shaving Cream', Icons.inventory_2_rounded, isAlert: true),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButtonStyled(
        icon: Icons.add_rounded,
        label: 'New Booking',
        onPressed: () {},
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: Text('View List', style: TextStyle(color: Theme.of(context).primaryColor))),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAppointmentStatesFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', true),
          _buildFilterChip('Waiting', false),
          _buildFilterChip('Done', false),
          _buildFilterChip('Pending Payment', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? AppColors.white : Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildAppointmentItem(String name, String time, String service, String status, Color statusColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$time • $service', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, String subtitle, IconData icon, {bool isAlert = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAlert ? AppColors.error.withOpacity(0.3) : (isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isAlert ? AppColors.error : Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: isAlert ? AppColors.error : AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.almostBlack200),
        ],
      ),
    );
  }
}
