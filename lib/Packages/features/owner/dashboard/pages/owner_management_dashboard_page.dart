import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/notifications/notifications_bottom_sheet.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/dashboard/dashboard_widgets.dart';

import 'package:na3eeman/Packages/features/navigation/sidebar.dart';
import 'package:na3eeman/Packages/features/navigation/sidebar_controller.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/widgets/dev_account_switcher.dart';
import 'package:na3eeman/core/config/subscription_config.dart';
import 'package:easy_localization/easy_localization.dart';

// Studio
import '../widgets/studio/team_leaderboard_widget.dart';
import '../widgets/studio/retail_snapshot_widget.dart';
import '../widgets/studio/low_stock_alert_widget.dart';
import '../widgets/studio/switch_view_toggle_widget.dart';

// Elite
import '../widgets/elite/resource_occupancy_widget.dart';
import '../widgets/elite/consumable_waste_meter_widget.dart';
import '../widgets/elite/commission_calculator_widget.dart';
import '../widgets/elite/compliance_tracker_widget.dart';

// Empire
import '../widgets/empire/branch_comparison_map_widget.dart';
import '../widgets/empire/global_stock_value_widget.dart';
import '../widgets/empire/inter_branch_transfers_widget.dart';
import '../widgets/empire/unified_profit_loss_widget.dart';

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
    
    // Load analytics data for Studio+ tiers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final owner = context.read<OwnerProvider>();
      if (owner.tier.index >= OwnerSubscriptionTier.studio.index) {
        owner.loadDashboardAnalytics();
      }
    });
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
            onRefresh: () async {},
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!owner.isSubscriptionActive)
                    Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildTierWidgets(context, owner),
                        ),
                      ),
                    )
                  else
                    ..._buildTierWidgets(context, owner),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
        Sidebar(controller: _sidebarController),
        if (kDebugMode)
          const Positioned(
            bottom: 30,
            right: 20,
            child: DevAccountSwitcher(),
          ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context, OwnerProvider owner) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('management_dashboard'.tr(),
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
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: CircleAvatar(
            radius: 17,
            backgroundColor:
                Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.person,
                color: Theme.of(context).primaryColor, size: 20),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  List<Widget> _buildTierWidgets(BuildContext context, OwnerProvider owner) {
    final widgetMap = _buildWidgetMap(context, owner);
    final activeWidgets = owner.dashboardWidgets;
    
    // Fallback message for Artisan tier
    if (activeWidgets.isEmpty || owner.tier == OwnerSubscriptionTier.artisan) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Center(
            child: Text(
              'No management widgets available.\nUpgrade your plan to access advanced analytics.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).hintColor, 
                fontSize: 14, 
                height: 1.5
              ),
            ),
          ),
        )
      ];
    }

    return activeWidgets.map((key) {
      final widget = widgetMap[key];
      if (widget == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: DashboardCard(child: widget),
      );
    }).toList();
  }

  Map<DashboardWidgetKey, Widget> _buildWidgetMap(
      BuildContext context, OwnerProvider owner) {
    return {
      // Studio
      DashboardWidgetKey.teamLeaderboard: const TeamLeaderboardWidget(),
      DashboardWidgetKey.retailSnapshot: const RetailSnapshotWidget(),
      DashboardWidgetKey.lowStockAlert: const LowStockAlertWidget(),
      DashboardWidgetKey.switchViewToggle: const SwitchViewToggleWidget(),

      // Elite
      DashboardWidgetKey.resourceOccupancy:
          const ResourceOccupancyWidget(),
      DashboardWidgetKey.consumableWasteMeter:
          const ConsumableWasteMeterWidget(),
      DashboardWidgetKey.commissionCalculator:
          const CommissionCalculatorWidget(),
      DashboardWidgetKey.complianceTracker:
          const ComplianceTrackerWidget(),

      // Empire
      DashboardWidgetKey.branchComparisonMap:
          const BranchComparisonMapWidget(),
      DashboardWidgetKey.globalStockValue:
          const GlobalStockValueWidget(),
      DashboardWidgetKey.interBranchTransfers:
          const InterBranchTransfersWidget(),
      DashboardWidgetKey.unifiedProfitLoss:
          const UnifiedProfitLossWidget(),
    };
  }
}
