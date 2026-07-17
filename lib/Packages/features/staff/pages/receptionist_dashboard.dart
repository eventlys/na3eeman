// ignore_for_file: unused_element, unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart'; // Added
import 'receptionist/receptionist_inventory_page.dart'; // Added
// Added
// Added
// Added
import '../../salon/pages/salon_owner_dashboard.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/appointment_provider.dart';
import '../../../../Providers/features/staff_provider.dart';
import '../../../../Providers/features/inventory_provider.dart';
import '../../../../Providers/features/offers_provider.dart';
import '../../../../Providers/features/auth_provider.dart';
import '../../../../Services/enums/appointment_status.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';

class ReceptionistDashboard extends StatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  State<ReceptionistDashboard> createState() => _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends State<ReceptionistDashboard>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);

    // Load data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final salonId = auth.user?.salonId;

      if (salonId != null) {
        context.read<AppointmentProvider>().loadAppointments();
        context.read<StaffProvider>().loadStaff(salonId);
        context.read<InventoryProvider>().loadInventory(salonId);
        context.read<OffersProvider>().loadCampaigns(salonId);
      }
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                children: [
                  IconButtonStyled(
                    icon: Icons.menu_rounded,
                    onPressed: _toggleSidebar,
                  ),
                  const SizedBox(width: 8),
                  const GlobalSearchBar(),
                ],
              ),
            ),
            actions: [
              IconButtonStyled(
                icon: Icons.notifications_none_rounded,
                onPressed: () => NotificationsBottomSheet.show(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnalyticsSection(context),

                const SizedBox(height: 32),

                _buildBigTodayScheduleCard(context),

                const SizedBox(height: 32),

                // Quick Action Buttons (Re-organized)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildQuickAction(
                      "book_for_customer".tr(),
                      Icons.person_add_alt_1_rounded,
                      Theme.of(context).primaryColor,
                      onTap: () => Navigator.pushNamed(context, '/pos'),
                    ),
                    _buildQuickAction(
                      "search_appointments".tr(),
                      Icons.search_rounded,
                      AppColors.blue,
                      onTap: () =>
                          Navigator.pushNamed(context, '/appointments/search'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Pending Payments Widget
                DashboardSectionHeader(
                  title: "pending_payments".tr(),
                  actionText: 'view_all'.tr(),
                ),

                const SizedBox(height: 16),

                Consumer<AppointmentProvider>(
                  builder: (context, provider, _) {
                    // Show appointments that are ACTIVE or DONE but payment is PENDING
                    final pendingAppts = provider.appointments
                        .where(
                          (a) =>
                              (a.status == AppointmentStatus.scheduled ||
                                  a.status == AppointmentStatus.completed ||
                                  a.status == AppointmentStatus.checkedIn) &&
                              (a.paymentStatus == 'PENDING' ||
                                  a.paymentStatus == 'FAILED'),
                        )
                        .toList();

                    if (pendingAppts.isEmpty) {
                      return DashboardCard(
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'all_payments_settled'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: pendingAppts
                          .take(3)
                          .map(
                            (appt) => _buildPendingPaymentItem(
                              appt.id,
                              appt.customerName ??
                                  'Customer #${appt.customerId}',
                              '${appt.totalAmount ?? 0.0} JOD',
                              (appt.services).map((s) => s.name).join(', '),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Expert Schedules Overview
                DashboardSectionHeader(
                  title: 'staff_timeline'.tr(),
                  actionText: 'schedule'.tr(),
                ),

                const SizedBox(height: 16),

                Consumer<StaffProvider>(
                  builder: (context, staffProvider, _) {
                    final staff = staffProvider.staff;
                    if (staff.isEmpty) {
                      return Center(child: Text('no_experts_found'.tr()));
                    }
                    return Column(
                      children: staff.take(3).map((member) {
                        Color statusColor;
                        String statusText = member.status ?? 'available'.tr();

                        switch (statusText.toUpperCase()) {
                          case 'BUSY':
                            statusColor = AppColors.error;
                            break;
                          case 'BREAK':
                            statusColor = AppColors.warning;
                            break;
                          case 'AVAILABLE':
                          default:
                            statusColor = AppColors.success;
                            statusText = 'available'.tr();
                            break;
                        }

                        return _buildExpertStatusItem(
                          member.userId,
                          member.name,
                          statusText,
                          statusColor,
                          member.statusNote ?? 'available'.tr(),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Inventory Count Preview
                DashboardSectionHeader(title: "inventory_management".tr()),

                const SizedBox(height: 16),

                Consumer<InventoryProvider>(
                  builder: (context, inventoryProvider, _) {
                    final consumables = inventoryProvider.consumables;
                    final equipment = inventoryProvider.personalKitItems;
                    final products = inventoryProvider.generalItems;

                    final lowConsumables = consumables
                        .where(
                          (i) =>
                              (i['quantity_in_stock'] ?? 0) <=
                              (i['low_stock_threshold'] ?? 5),
                        )
                        .length;
                    final lowEquipment = equipment
                        .where(
                          (i) =>
                              (i['quantity_in_stock'] ?? 0) <=
                              (i['low_stock_threshold'] ?? 5),
                        )
                        .length;

                    return DashboardCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildInventorySummaryItem(
                                context,
                                'tools'.tr(),
                                'low_stock'.tr(args: [lowEquipment.toString()]),
                                Icons.person_pin_circle_rounded,
                                Theme.of(context).primaryColor,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReceptionistInventoryPage(
                                          startWithTools: true,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildInventorySummaryItem(
                                context,
                                'inventory'.tr(),
                                'left_stock'.tr(
                                  args: [lowConsumables.toString()],
                                ),
                                Icons.layers_rounded,
                                AppColors.pink,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReceptionistInventoryPage(
                                          startWithShared: true,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInventorySummaryItem(
                                context,
                                'products_label'.tr(),
                                'available_count'.tr(
                                  args: [products.length.toString()],
                                ),
                                Icons.shopping_basket_rounded,
                                Colors.orange,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReceptionistInventoryPage(
                                          startWithProducts: true,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Campaigns (Offers/Ads) Section
                DashboardSectionHeader(
                  title: "active_campaigns".tr(),
                  actionText: 'manage_all'.tr(),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/active_campaigns'),
                ),

                const SizedBox(height: 16),

                Consumer<OffersProvider>(
                  builder: (context, offersProvider, _) {
                    final offers = offersProvider.offers;
                    final ads = offersProvider.adCampaigns;

                    if (offers.isEmpty && ads.isEmpty) {
                      return Center(child: Text('no_active_campaigns'.tr()));
                    }

                    return Column(
                      children: [
                        ...offers
                            .take(1)
                            .map(
                              (offer) => _buildCampaignItem(
                                offer.title,
                                offer.description,
                                offer.isActive
                                    ? 'active_status'.tr()
                                    : 'inactive_status'.tr(),
                                offer.isActive
                                    ? AppColors.success
                                    : AppColors.almostBlack300,
                                'exp_date'.tr(
                                  args: [
                                    offer.validityPeriod.toString().split(
                                      ' ',
                                    )[0],
                                  ],
                                ),
                              ),
                            ),
                        ...ads
                            .take(1)
                            .map(
                              (ad) => _buildCampaignItem(
                                ad.name,
                                ad.details,
                                ad.isActive
                                    ? 'active_status'.tr()
                                    : 'inactive_status'.tr(),
                                ad.isActive
                                    ? AppColors.success
                                    : AppColors.almostBlack300,
                                'duration_days'.tr(
                                  args: [ad.durationDays.toString()],
                                ),
                              ),
                            ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Salon Management Section
                DashboardSectionHeader(title: "manage_salon".tr()),

                const SizedBox(height: 16),

                _buildSalonManagementCard(context),

                const SizedBox(height: 32),

                const FeedbackSection(),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  void _showCampaignDetailsModal(
    BuildContext context,
    String title,
    String subtitle,
    String status,
    Color statusColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.almostBlack300,
                fontSize: 13,
              ),
            ),
            const Divider(height: 32),
            _buildDetailRow(context, 'status_label'.tr(), status, statusColor),
            _buildDetailRow(
              context,
              'duration'.tr(),
              'duration_days'.tr(args: ['7']),
              Theme.of(context).primaryColor,
            ),
            _buildDetailRow(
              context,
              'standard_price'.tr(),
              'amount_jod_fixed'.tr(args: ['12.00']),
              Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: "close".tr(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.almostBlack300)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }

  Widget _buildCampaignItem(
    String title,
    String subtitle,
    String status,
    Color statusColor,
    String actionText,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = status == 'Expired';

    return GestureDetector(
      onTap: () => _showCampaignDetailsModal(
        context,
        title,
        subtitle,
        status,
        statusColor,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.1)
                : AppColors.almostBlack50,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.almostBlack300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isExpired)
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('renewing_campaign'.tr(args: [title])),
                      ),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonManagementCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SalonOwnerDashboard()),
      ),
      child: DashboardCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "manage_salon".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'location_products_descriptions'.tr(),
                    style: const TextStyle(
                      color: AppColors.almostBlack300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.almostBlack300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsModalContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'latest_appointments'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, _) {
                final appointments = provider.appointments.take(10).toList();
                if (appointments.isEmpty) {
                  return Center(child: Text('no_appointments_found'.tr()));
                }
                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return _buildAppointmentListItem(
                      expert: appt.expertName ?? 'Expert #${appt.expertId}',
                      dateTime: DateFormat(
                        'date_time_compact'.tr(),
                      ).format(appt.startTime),
                      price: 'amount_jod_fixed'.tr(
                        args: [appt.totalAmount?.toString() ?? '0.00'],
                      ),
                      products:
                          appt.services
                              .where((s) => s.serviceType == 'PRODUCT')
                              .map((s) => s.name)
                              .join(', ')
                              .isEmpty
                          ? 'none'.tr()
                          : appt.services
                                .where((s) => s.serviceType == 'PRODUCT')
                                .map((s) => s.name)
                                .join(', '),
                      offer:
                          appt.services
                              .where((s) => s.serviceType == 'PACKAGE')
                              .map((s) => s.name)
                              .join(', ')
                              .isEmpty
                          ? 'none'.tr()
                          : appt.services
                                .where((s) => s.serviceType == 'PACKAGE')
                                .map((s) => s.name)
                                .join(', '),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentListItem({
    required String expert,
    required String dateTime,
    required String price,
    required String products,
    required String offer,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.almostBlack500
            : AppColors.almostBlack50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.almostBlack50,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expert,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateTime,
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 13,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'products_included_label'.tr(),
                style: const TextStyle(
                  color: AppColors.almostBlack300,
                  fontSize: 12,
                ),
              ),
              Text(
                products,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'offer_applied_label'.tr(),
                style: const TextStyle(
                  color: AppColors.almostBlack300,
                  fontSize: 12,
                ),
              ),
              Text(
                offer,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.1)
                : AppColors.almostBlack50,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingPaymentModal(
    BuildContext context,
    String appointmentId,
    String customer,
    String amount,
    String service,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'payment_action_label'.tr(args: [customer]),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'amount_details_label'.tr(args: [amount, service]),
              style: const TextStyle(color: AppColors.almostBlack300),
            ),
            const SizedBox(height: 24),
            _buildModalActionButton(
              context,
              Icons.check_circle_rounded,
              'confirm_payment'.tr(),
              Colors.green,
              () async {
                Navigator.pop(context);
                try {
                  await appointmentProvider.confirmPayment(appointmentId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('payment_confirmed_msg'.tr())),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'failed_to_confirm_err'.tr(args: [e.toString()]),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _buildModalActionButton(
              context,
              Icons.phone_in_talk_rounded,
              'call_customer'.tr(),
              AppColors.blue,
              () {
                Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('notification_reminder_sent_msg'.tr()),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            _buildModalActionButton(
              context,
              Icons.phone_forwarded_rounded,
              'call_expert'.tr(),
              Colors.indigo,
              () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildModalActionButton(
              context,
              Icons.report_problem_rounded,
              'report_customer'.tr(),
              AppColors.error,
              () {
                Navigator.pop(context);
                _showReportReasonDialog(context, appointmentId);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showReportReasonDialog(BuildContext context, String appointmentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('report_customer'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('reporting_deduct_points_msg'.tr()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Reason for reporting...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              final reason = controller.text;
              if (reason.isEmpty) return;
              Navigator.pop(context);
              try {
                await context.read<AppointmentProvider>().reportCustomer(
                  appointmentId,
                  reason,
                );
                if (context.mounted) {
                  AppSnackBar.success(
                    context,
                    'Customer reported successfully',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.error(context, 'Failed to report: $e');
                }
              }
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildModalActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPaymentItem(
    String id,
    String customer,
    String amount,
    String service,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () =>
          _showPendingPaymentModal(context, id, customer, amount, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.pink.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    service,
                    style: const TextStyle(
                      color: AppColors.almostBlack300,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pink,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffTimelineModal(
    BuildContext context,
    int expertId,
    String name,
    String status,
    Color statusColor,
    String note,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: statusColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Note/Status Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(note, style: const TextStyle(color: AppColors.almostBlack300)),
            const Divider(height: 32),
            const Text(
              'Full Day Schedule Preview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, _) {
                  final todayStr = DateFormat(
                    'yyyy-MM-dd',
                  ).format(DateTime.now());
                  final expertAppts = provider.appointments
                      .where(
                        (a) =>
                            a.expertId == expertId &&
                            DateFormat('yyyy-MM-dd').format(a.startTime) ==
                                todayStr,
                      )
                      .toList();

                  if (expertAppts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.almostBlack300,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No bookings for today',
                            style: TextStyle(color: AppColors.almostBlack300),
                          ),
                        ],
                      ),
                    );
                  }

                  expertAppts.sort(
                    (a, b) => a.startTime.compareTo(b.startTime),
                  );

                  return ListView.builder(
                    itemCount: expertAppts.length,
                    itemBuilder: (context, index) {
                      final appt = expertAppts[index];
                      final time = DateFormat('hh:mm A').format(appt.startTime);
                      final serviceNames = appt.services
                          .map((s) => s.name)
                          .join(', ');
                      return _buildTimelineScheduleItem(
                        time,
                        'Busy ($serviceNames - ${appt.customerName ?? "Customer"})',
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineScheduleItem(String time, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              detail,
              style: const TextStyle(
                color: AppColors.almostBlack300,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertStatusItem(
    int expertId,
    String name,
    String status,
    Color statusColor,
    String note,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showStaffTimelineModal(
        context,
        expertId,
        name,
        status,
        statusColor,
        note,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.1)
                : AppColors.almostBlack50,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: statusColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    note,
                    style: const TextStyle(
                      color: AppColors.almostBlack300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryAlert(String item, String count, bool isCritical) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 16,
            color: isCritical
                ? AppColors.error
                : Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(item, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              color: isCritical ? AppColors.error : AppColors.almostBlack300,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: "performance_analytics".tr()),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _buildBookingStatsCard(context),
        ),
      ],
    );
  }

  Widget _buildBookingStatsCard(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, _) {
        final appointments = provider.appointments;
        final now = DateTime.now();

        final todayCount = appointments
            .where(
              (a) =>
                  a.startTime.year == now.year &&
                  a.startTime.month == now.month &&
                  a.startTime.day == now.day,
            )
            .length;
        final weekCount = appointments
            .where(
              (a) => a.startTime.isAfter(now.subtract(const Duration(days: 7))),
            )
            .length;
        final monthCount = appointments
            .where(
              (a) =>
                  a.startTime.isAfter(now.subtract(const Duration(days: 30))),
            )
            .length;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "bookings_summary".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildStatRow("today".tr(), '$todayCount'),
              const Divider(color: Colors.white24, height: 16),
              _buildStatRow("this_week".tr(), '$weekCount'),
              const Divider(color: Colors.white24, height: 16),
              _buildStatRow("this_month".tr(), '$monthCount'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildBigTodayScheduleCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/staff_schedules'),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.almostBlack500, AppColors.almostBlack600]
                : [AppColors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.05)
                : AppColors.almostBlack50,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.pink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.pink,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "today_schedule".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, MMM d').format(DateTime.now()),
                          style: const TextStyle(
                            color: AppColors.almostBlack300,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.almostBlack200,
                    size: 18,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey[100]!.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Consumer<AppointmentProvider>(
                builder: (context, provider, _) {
                  final now = DateTime.now();
                  final todayAppts = provider.appointments
                      .where(
                        (a) =>
                            a.startTime.year == now.year &&
                            a.startTime.month == now.month &&
                            a.startTime.day == now.day,
                      )
                      .toList();

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 40,
      width: 1,
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }

  Widget _buildScheduleQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12),
        ),
      ],
    );
  }

  // Widget _buildGuideLink(BuildContext context, String title, String hint) {
  //   return Row(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Icon(
  //           Icons.lightbulb_outline_rounded,
  //           color: Theme.of(context).primaryColor,
  //           size: 20,
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               title,
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 14,
  //               ),
  //             ),
  //             Text(
  //               hint,
  //               style: const TextStyle(
  //                 color: AppColors.almostBlack300,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const Icon(
  //         Icons.arrow_forward_ios_rounded,
  //         size: 14,
  //         color: AppColors.almostBlack300,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildCustomerSearchItem(String name, String phone) {
    return ListTile(
      leading: CircleAvatar(child: Text(name[0])),
      title: Text(name),
      subtitle: Text(phone),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {},
    );
  }

  void _showSearchAppointmentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "search_appointments".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDialogField('search_by_name_phone_id'.tr()),
            const SizedBox(height: 16),
            Expanded(
              child: Center(child: Text('search_results_appear_here'.tr())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.almostBlack300,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );

    return Expanded(
      flex: fullWidth ? 2 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.almostBlack500
                : AppColors.almostBlack50.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: content,
        ),
      ),
    );
  }
}
