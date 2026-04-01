import 'package:flutter/material.dart';
// import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/profit_graph.dart';
import '../widgets/inventory_alert_card.dart';
import '../widgets/offers_card.dart';
import 'package:easy_localization/easy_localization.dart';

class ShopOwnerDashboard extends StatefulWidget {
  const ShopOwnerDashboard({super.key});

  @override
  State<ShopOwnerDashboard> createState() => _ShopOwnerDashboardState();
}

class _ShopOwnerDashboardState extends State<ShopOwnerDashboard> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    _loadData();
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    sidebarController.toggleSidebar();
  }

  void _loadData() {
    // Refresh logic
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('owner_dashboard'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards Row
              Row(
                children: [
                  Expanded(child: _buildStatCard('Revenue', '\$1,250', Icons.payments_rounded, AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Bookings', '48', Icons.calendar_today_rounded, Theme.of(context).primaryColor)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Low Stock', '3 Items', Icons.inventory_2_rounded, AppColors.error)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Growth', '+12%', Icons.trending_up_rounded, AppColors.pink)),
                ],
              ),

              const SizedBox(height: 32),

              // Profit Graph Section
              _buildSectionHeader('Revenue Overview', () {}),
              const SizedBox(height: 16),
              const ProfitGraph(
                startDate: null,
                endDate: null,
                branchId: null,
              ),

              const SizedBox(height: 32),

              // Inventory Alerts
              _buildSectionHeader('Stock Alerts', () {}),
              const SizedBox(height: 16),
              const InventoryAlertCard(),

              const SizedBox(height: 32),

              // Active Offers
              _buildSectionHeader('Promotions', () {}),
              const SizedBox(height: 16),
              const OffersCard(),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButtonStyled(
        icon: Icons.add_rounded,
        label: 'new_action'.tr(),
        onPressed: () {},
      ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text('view_all'.tr(), style: TextStyle(color: Theme.of(context).primaryColor)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
