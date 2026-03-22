import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';

class ReceptionistDashboard extends StatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  State<ReceptionistDashboard> createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    sidebarController.toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Receptionist Desk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButtonStyled(
          icon: Icons.menu_rounded,
          onPressed: _toggleSidebar,
        ),
        actions: [
          IconButtonStyled(
            icon: Icons.notifications_none_rounded,
            onPressed: () => NotificationsBottomSheet.show(context),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Action Buttons
            Row(
              children: [
                Expanded(child: _buildQuickAction('New Booking', Icons.add_task_rounded, Theme.of(context).primaryColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickAction('Sell Product', Icons.shopping_basket_rounded, AppColors.pink)),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickAction('Reports', Icons.assessment_rounded, AppColors.cream600)),
              ],
            ),

            const SizedBox(height: 32),

            // Pending Payments Widget
            _buildSectionHeader('Pending Payments', 'View All'),
            const SizedBox(height: 16),
            _buildPendingPaymentItem('Mohammed Ali', '\$45.00', 'Haircut + Styling'),
            _buildPendingPaymentItem('Zaid Hassan', '\$15.00', 'Beard Trim'),

            const SizedBox(height: 32),

            // Barber Schedules Overview
            _buildSectionHeader('Barber Status', 'Schedule'),
            const SizedBox(height: 16),
            _buildBarberStatusItem('Jafar', 'Busy', AppColors.error, 'Finishing in 10m'),
            _buildBarberStatusItem('Yousif', 'Available', AppColors.success, 'Next @ 2:00 PM'),
            _buildBarberStatusItem('Karim', 'On Break', AppColors.warning, 'Back in 15m'),

            const SizedBox(height: 32),

            // Inventory Count Preview
            _buildSectionHeader('Inventory Check', 'Full Count'),
            const SizedBox(height: 16),
            _buildInventoryAlert('Disposable Towels', '24 remaining', true),
            _buildInventoryAlert('Sanitizer Spray', '5 bottles left', false),

            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonStyled(
        icon: Icons.search_rounded,
        label: 'Find Customer',
        onPressed: () {},
      ),
        ),
        Sidebar(controller: sidebarController),
      ],
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

  Widget _buildQuickAction(String label, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentItem(String customer, String amount, String service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pink.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(service, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.pink)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarberStatusItem(String name, String status, Color statusColor, String note) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.person, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(note, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInventoryAlert(String item, String count, bool isCritical) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.inventory_2_rounded, size: 16, color: isCritical ? AppColors.error : Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(item, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(count, style: TextStyle(color: isCritical ? AppColors.error : AppColors.almostBlack300, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
