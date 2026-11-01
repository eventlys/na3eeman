// ignore_for_file: unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/appointment_provider.dart';
import '../../../../Providers/features/profit_provider.dart';
import '../../../../Providers/features/inventory_provider.dart';
import '../../../../Providers/features/offers_provider.dart';
import '../../../../Providers/features/owner_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/profit_graph.dart';
import '../widgets/inventory_alert_card.dart';
import '../widgets/offers_card.dart';

class SalonOwnerDashboard extends StatefulWidget {
  const SalonOwnerDashboard({super.key});

  @override
  State<SalonOwnerDashboard> createState() => _SalonOwnerDashboardState();
}

class _SalonOwnerDashboardState extends State<SalonOwnerDashboard>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
    final salonId = context.read<OwnerProvider>().activeSalonId;
    context.read<ProfitProvider>().loadProfitData(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );
    context.read<AppointmentProvider>().loadAppointments();
    // Inventory/low-stock need a salon — skip gracefully when none is selected.
    if (salonId != null) {
      context.read<InventoryProvider>().loadLowStockItems(salonId: salonId);
    }
    context.read<OffersProvider>().loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "owner_dashboard".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
                  Consumer3<
                    ProfitProvider,
                    AppointmentProvider,
                    InventoryProvider
                  >(
                    builder: (context, profit, appointments, inventory, child) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildPremiumStatCard(
                                  'income'.tr(),
                                  '${profit.totalRevenue.toStringAsFixed(0)} JOD',
                                  Icons.payments_rounded,
                                  AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPremiumStatCard(
                                  'appointments'.tr(),
                                  '${appointments.appointments.length}',
                                  Icons.calendar_today_rounded,
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPremiumStatCard(
                                  'low_stock'.tr(args: ['']),
                                  '${inventory.lowStockCount}',
                                  Icons.inventory_2_rounded,
                                  AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPremiumStatCard(
                                  'performance'.tr(),
                                  '+12%',
                                  Icons.trending_up_rounded,
                                  AppColors.pink,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Profit Graph Section
                  _buildSectionHeader('profit_reports'.tr(), () {}),
                  const SizedBox(height: 16),
                  const ProfitGraph(
                    startDate: null,
                    endDate: null,
                    branchId: null,
                  ),

                  const SizedBox(height: 32),

                  // Inventory Alerts
                  _buildSectionHeader('inventory_stock'.tr(), () {}),
                  const SizedBox(height: 16),
                  const InventoryAlertCard(),

                  const SizedBox(height: 32),

                  // Active Offers
                  _buildSectionHeader('offers'.tr(), () {}),
                  const SizedBox(height: 16),
                  const OffersCard(),

                  const SizedBox(height: 48),
                ],
              ),
            ),
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
        // TextButton(
        //   onPressed: onSeeAll,
        //   child: Text(
        //     "view_all".tr(),
        //     style: TextStyle(color: Theme.of(context).primaryColor),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildPremiumStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.almostBlack50,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: color.withValues(alpha: 0.1),
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
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
