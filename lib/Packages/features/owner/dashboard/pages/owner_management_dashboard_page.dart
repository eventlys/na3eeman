import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/notifications/notifications_bottom_sheet.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/dashboard/dashboard_widgets.dart';

import 'package:na3eeman/Packages/features/navigation/sidebar.dart';
import 'package:na3eeman/Packages/features/navigation/sidebar_controller.dart';
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
                     title: 'staff_operations'.tr(),
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'scheduling'.tr(),
                         subtitle: 'manage_staff_schedules_rotations'.tr(),
                         icon: Icons.calendar_month_rounded,
                         color: Theme.of(context).primaryColor,
                         onTap: () => Navigator.pushNamed(context, '/expert_schedule'),
                       ),
                       _buildDashboardModule(
                         context,
                         title: "expert_management".tr(),
                         subtitle: 'hire_detach_monitor_staff'.tr(),
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
                     title: 'revenue_financials'.tr(),
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'payment_setup'.tr(),
                         subtitle: 'configure_deposits_cliq_policies'.tr(),
                         icon: Icons.account_balance_rounded,
                         color: Colors.green,
                         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RevenueControlsPage())),
                         isEnabled: owner.canAccess(FeatureKey.paymentManagement),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'prepaid_vouchers'.tr(),
                         subtitle: 'manage_gift_cards_packages'.tr(),
                         icon: Icons.confirmation_num_rounded,
                         color: Colors.orange,
                         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VoucherManagementPage())),
                         isEnabled: owner.canAccess(FeatureKey.vouchers),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'loyalty_points'.tr(),
                         subtitle: 'rewards_mapping_rules'.tr(),
                         icon: Icons.stars_rounded,
                         color: AppColors.pink,
                         onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('points_config_coming_soon'.tr()))),
                         isEnabled: owner.canAccess(FeatureKey.loyaltySystem),
                       ),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // ── Marketing & Customer Section ────────────────
                   _buildSection(
                     context,
                     title: 'marketing_customers'.tr(),
                     children: [
                       _buildDashboardModule(
                         context,
                         title: "active_campaigns".tr(),
                         subtitle: 'manage_offers_ads_promotions'.tr(),
                         icon: Icons.campaign_rounded,
                         color: Colors.purple,
                         onTap: () => Navigator.pushNamed(context, '/active_campaigns'),
                         isEnabled: owner.canAccess(FeatureKey.marketingAds),
                       ),
                       _buildDashboardModule(
                         context,
                         title: "feedback".tr(),
                         subtitle: 'review_customer_ratings_comments'.tr(),
                         icon: Icons.rate_review_rounded,
                         color: Colors.teal,
                         onTap: () => Navigator.pushNamed(context, '/feedback_page'),
                       ),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // ── Analytics & Performance Section ──────────────
                   _buildSection(
                     context,
                     title: 'analytics_performance'.tr(),
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'salon_analytics'.tr(),
                         subtitle: 'performance_growth_peak_hours'.tr(),
                         icon: Icons.analytics_rounded,
                         color: AppColors.blue,
                         onTap: () => Navigator.pushNamed(context, '/management/analytics'),
                         isEnabled: owner.canAccess(FeatureKey.analyticsElite),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'data_management'.tr(),
                         subtitle: 'export_data_manage_history'.tr(),
                         icon: Icons.storage_rounded,
                         color: AppColors.almostBlack300,
                         onTap: () => Navigator.pushNamed(context, '/management/data'),
                         isEnabled: owner.canAccess(FeatureKey.ownerControls),
                       ),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // ── Financial Controls Section ───────────────────
                   _buildSection(
                     context,
                     title: 'financial_controls'.tr(),
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'expense_tracker'.tr(),
                         subtitle: 'log_monitor_operational_costs'.tr(),
                         icon: Icons.account_balance_wallet_rounded,
                         color: Colors.redAccent,
                         onTap: () => Navigator.pushNamed(context, '/management/expenses'),
                         isEnabled: owner.canAccess(FeatureKey.financialControls),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'payroll'.tr(),
                         subtitle: 'manage_staff_salaries_tips'.tr(),
                         icon: Icons.payments_rounded,
                         color: Colors.indigo,
                         onTap: () => Navigator.pushNamed(context, '/management/payroll'),
                         isEnabled: owner.canAccess(FeatureKey.financialControls),
                       ),
                     ],
                   ),

                   const SizedBox(height: 32),

                   // ── Inventory & Assets Section ────────────────
                   _buildSection(
                     context,
                     title: 'inventory_stock'.tr(),
                     children: [
                       _buildDashboardModule(
                         context,
                         title: 'retail_inventory'.tr(),
                         subtitle: 'track_products_sales'.tr(),
                         icon: Icons.inventory_2_rounded,
                         color: AppColors.blue,
                         onTap: () => Navigator.pushNamed(context, '/management/products'),
                         isEnabled: owner.canAccess(FeatureKey.inventoryRetail),
                       ),
                       _buildDashboardModule(
                         context,
                         title: 'stock_management'.tr(),
                         subtitle: 'manage_salon_supplies'.tr(),
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
          Text("management_dashboard".tr(),
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
