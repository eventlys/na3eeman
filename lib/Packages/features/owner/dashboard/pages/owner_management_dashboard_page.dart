import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/notifications/notifications_bottom_sheet.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/dashboard/dashboard_widgets.dart';

import 'package:na3eeman/Packages/features/navigation/sidebar.dart';
import 'package:na3eeman/Packages/features/navigation/sidebar_controller.dart';
import 'package:na3eeman/core/config/subscription_config.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';

import 'revenue_controls_page.dart';
import 'voucher_management_page.dart';

class OwnerManagementDashboardPage extends StatefulWidget {
  const OwnerManagementDashboardPage({super.key});

  @override
  State<OwnerManagementDashboardPage> createState() => _OwnerManagementDashboardPageState();
}

class _OwnerManagementDashboardPageState extends State<OwnerManagementDashboardPage>
    with SingleTickerProviderStateMixin {
  late SidebarController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = SidebarController();
    _sidebarController.init(this);
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context, owner),
          body: RefreshIndicator(
            onRefresh: () async {
              await owner.loadDashboardAnalytics();
            },
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // ── Staff & Operations Section ─────────────────
                   _buildSection(
                     context,
                     title: 'Staff & Operations',
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'Scheduling',
                         subtitle: 'Manage staff schedules & rotations',
                         icon: Icons.calendar_month_rounded,
                         color: Theme.of(context).primaryColor,
                         onTap: () => Navigator.pushNamed(context, '/employee_schedule'),
                       ),
                       _buildDashboardModule(
                         context,
                         title: AppLocalizations.of(context)!.employeeManagement,
                         subtitle: 'Hire, detach and monitor staff',
                         icon: Icons.people_alt_rounded,
                         color: AppColors.blue,
                         onTap: () => Navigator.pushNamed(context, '/staff'),
                         isEnabled: owner.canAccess(FeatureKey.viewStaffList),
                       ),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // ── Revenue & Financials Section ───────────────
                   _buildSection(
                     context,
                     title: 'Revenue & Financials',
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'Payment Setup',
                         subtitle: 'Configure deposits, CliQ & policies',
                         icon: Icons.account_balance_rounded,
                         color: Colors.green,
                         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RevenueControlsPage())),
                         isEnabled: owner.canAccess(FeatureKey.paymentManagement),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'Prepaid Vouchers',
                         subtitle: 'Manage gift cards & packages',
                         icon: Icons.confirmation_num_rounded,
                         color: Colors.orange,
                         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoucherManagementPage())),
                         isEnabled: owner.canAccess(FeatureKey.vouchers),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'Loyalty & Points',
                         subtitle: 'Rewards mapping & rules',
                         icon: Icons.stars_rounded,
                         color: AppColors.pink,
                         onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Points configuration coming soon'))),
                         isEnabled: owner.canAccess(FeatureKey.loyaltySystem),
                       ),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // ── Inventory & Assets Section ────────────────
                   _buildSection(
                     context,
                     title: 'Inventory & Stock',
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'Retail Inventory',
                         subtitle: 'Track products and sales',
                         icon: Icons.inventory_2_rounded,
                         color: AppColors.blue,
                         onTap: () => Navigator.pushNamed(context, '/management/products'),
                         isEnabled: owner.canAccess(FeatureKey.inventoryRetail),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'Stock Management',
                         subtitle: 'Manage salon supplies',
                         icon: Icons.layers_rounded,
                         color: AppColors.cream600,
                         onTap: () => Navigator.pushNamed(context, '/management/inventory'),
                         isEnabled: owner.canAccess(FeatureKey.inventoryRetail),
                       ),
                     ],
                   ),

                   const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
        Sidebar(controller: _sidebarController),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: title),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDashboardModule(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
            boxShadow: [
              if (!isDark)
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
                  ],
                ),
              ),
              if (!isEnabled)
                const Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey)
              else
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.almostBlack200),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, OwnerProvider owner) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.managementDashboard,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(owner.tierDisplayName,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).hintColor)),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButtonStyled(
        icon: Icons.menu_rounded,
        onPressed: _sidebarController.toggleSidebar,
      ),
      actions: [
        IconButtonStyled(
          icon: Icons.notifications_none_rounded,
          onPressed: () => NotificationsBottomSheet.show(context),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
