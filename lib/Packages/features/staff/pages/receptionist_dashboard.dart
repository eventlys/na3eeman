import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart'; // Added
import 'receptionist/receptionist_inventory_page.dart'; // Added
import 'receptionist/receptionist_products_page.dart'; // Added
import 'receptionist/receptionist_feedback_page.dart'; // Added
import 'receptionist/receptionist_shop_profile_page.dart'; // Added
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import 'package:easy_localization/easy_localization.dart';

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
        title: Text('receptionist_desk'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildQuickAction(
                  'Latest Appointments', 
                  Icons.calendar_today_rounded, 
                  Theme.of(context).primaryColor,
                  onTap: () => _showLatestAppointmentsModal(context),
                ),
                _buildQuickAction(
                  'Our Products', 
                  Icons.shopping_basket_rounded, 
                  AppColors.pink,
                  onTap: () => _navigateToProductsPage(context),
                ),
                _buildQuickAction(
                  'Customer Feedback', 
                  Icons.assessment_rounded, 
                  AppColors.cream600,
                  onTap: () => _navigateToFeedbackPage(context, false),
                ),
                _buildQuickAction(
                  'Staff Feeds & Requests', 
                  Icons.message_rounded, 
                  AppColors.success,
                  onTap: () => _navigateToFeedbackPage(context, true),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Pending Payments Widget
            DashboardSectionHeader(title: 'pending_payments'.tr(), actionText: 'View All'),
            const SizedBox(height: 16),
            _buildPendingPaymentItem('Mohammed Ali', '\$45.00', 'Haircut + Styling'),
            _buildPendingPaymentItem('Zaid Hassan', '\$15.00', 'Beard Trim'),

            const SizedBox(height: 32),

            // Barber Schedules Overview
            const DashboardSectionHeader(title: 'Staff Timeline', actionText: 'Schedule'),
            const SizedBox(height: 16),
            _buildBarberStatusItem('Jafar', 'Busy', AppColors.error, 'Finishing in 10m'),
            _buildBarberStatusItem('Yousif', 'Available', AppColors.success, 'Next @ 2:00 PM'),
            _buildBarberStatusItem('Karim', 'On Break', AppColors.warning, 'Back in 15m'),

            const SizedBox(height: 32),

            // Inventory Count Preview
            DashboardSectionHeader(title: 'inventory_management'.tr()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceptionistInventoryPage(startWithStaff: true))),
                    child: DashboardSummaryCard(
                      title: 'Staff Items',
                      value: '12 Low',
                      icon: Icons.person_pin_circle_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceptionistInventoryPage(startWithStaff: false))),
                    child: DashboardSummaryCard(
                      title: 'Shared Items',
                      value: '5 Left',
                      icon: Icons.layers_rounded,
                      color: AppColors.pink,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Campaigns (Offers/Ads) Section
            DashboardSectionHeader(title: 'active_campaigns'.tr()),
            const SizedBox(height: 16),
            _buildCampaignList(context),

            const SizedBox(height: 32),

            // Shop Management Section
            DashboardSectionHeader(title: 'shop_management'.tr()),
            const SizedBox(height: 16),
            _buildShopManagementCard(context),

            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonStyled(
        icon: Icons.campaign_rounded,
        label: 'Promotions',
        onPressed: () => _showCampaignModal(context),
      ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  void _showCampaignModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Text('create_promotion'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildModalActionButton(context, Icons.local_offer_rounded, 'Create Offer', AppColors.blue, () {
              Navigator.pop(context);
              _showCreateOfferDialog(context);
            }),
            const SizedBox(height: 12),
            _buildModalActionButton(context, Icons.ads_click_rounded, 'Create Ad', AppColors.pink, () {
              Navigator.pop(context);
              _showCreateAdDialog(context);
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCampaignDetailsModal(BuildContext context, String title, String subtitle, String status, Color statusColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: isDark ? AppColors.almostBlack600 : AppColors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
            const Divider(height: 32),
            _buildDetailRow(context, 'Status', status, statusColor),
            _buildDetailRow(context, 'Duration', '7 Days', Theme.of(context).primaryColor),
            _buildDetailRow(context, 'Standard Price', '\$12.00', Theme.of(context).primaryColor),
            const SizedBox(height: 24),
            PrimaryButton(text: 'close'.tr(), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.almostBlack300)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
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

  Widget _buildCampaignList(BuildContext context) {
    return Column(
      children: [
        _buildCampaignItem('Summer Bundle Offer', '20% Discount applied', 'Active', AppColors.success, 'Exp: May 5'),
        _buildCampaignItem('Free Haircut Referral', 'Uses 500 Loyalty points', 'Expired', AppColors.almostBlack300, 'Re-Activate ⟳'),
      ],
    );
  }

  Widget _buildCampaignItem(String title, String subtitle, String status, Color statusColor, String actionText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = status == 'Expired';

    return GestureDetector(
      onTap: () => _showCampaignDetailsModal(context, title, subtitle, status, statusColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 8),
              if (isExpired) 
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Renewing $title...'))),
                  child: Text(actionText, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
            ],
          ),
        ],
      ),
    ),
    );
  }

  void _showCreateOfferDialog(BuildContext context) {
    final List<String> availableServices = ['Classic Haircut', 'Beard Grooming', 'Premium Shave', 'Facial Scrub'];
    final Set<String> selectedServices = {};
    DateTimeRange? selectedRange;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('create_offer'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogField('Offer Title / Name'),
                const SizedBox(height: 12),
                _buildDialogField('Special Price (\$)', keyboard: TextInputType.number),
                const SizedBox(height: 16),
                
                Text('include_options'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: availableServices.map((service) {
                    final isSelected = selectedServices.contains(service);
                    return FilterChip(
                      label: Text(service, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.almostBlack400)),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor,
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) selectedServices.add(service);
                          else selectedServices.remove(service);
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),
                Text('validity_period'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (range != null) {
                      setDialogState(() => selectedRange = range);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.almostBlack300.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.date_range_rounded, size: 18, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedRange != null 
                              ? '${selectedRange!.start.toString().split(' ')[0]} to ${selectedRange!.end.toString().split(' ')[0]}' 
                              : 'Select Date Range',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('offer_success'.tr())));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text('create'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('create_ad'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Campaign Name'),
              const SizedBox(height: 12),
              _buildDialogField('Duration Days', keyboard: TextInputType.number),
              const SizedBox(height: 12),
              _buildDialogField('Details/Text', maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ad_campaign_launched'.tr())));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
            child: Text('launch'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildShopManagementCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceptionistShopProfilePage())),
      child: DashboardCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.storefront_rounded, color: Theme.of(context).primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('manage_shop'.tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('Location, products & descriptions', style: TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.almostBlack300),
          ],
        ),
      ),
    );
  }

  void _showLatestAppointmentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAppointmentsModalContent(context),
    );
  }

  void _navigateToProductsPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceptionistProductsPage()));
  }

  void _navigateToFeedbackPage(BuildContext context, bool isStaff) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReceptionistFeedbackPage(startWithStaff: isStaff)));
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
              const Text('Latest Appointments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildAppointmentListItem(
                  employee: 'Karim (Barber)',
                  dateTime: 'Today @ 3:00 PM',
                  price: '\$45.00',
                  products: 'Hair wax, Face cream',
                  offer: 'None',
                ),
                _buildAppointmentListItem(
                  employee: 'Jafar (Barber)',
                  dateTime: 'Today @ 4:30 PM',
                  price: '\$35.00',
                  products: 'None',
                  offer: 'Summer Package (10% off)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentListItem({
    required String employee,
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
        color: isDark ? AppColors.almostBlack500 : AppColors.almostBlack50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(employee, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(price, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(dateTime, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Products Included:', style: TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              Text(products, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Offer Applied:', style: TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              Text(offer, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showPendingPaymentModal(BuildContext context, String customer, String amount, String service) {
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
            Text('Payment Action: $customer', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Amount Details: $amount for $service', style: const TextStyle(color: AppColors.almostBlack300)),
            const SizedBox(height: 24),
            _buildModalActionButton(context, Icons.notification_important_rounded, 'Remind Customer', AppColors.pink, () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification reminder sent!')));
            }),
            const SizedBox(height: 12),
            _buildModalActionButton(context, Icons.person_search_rounded, 'Check With Employee', Theme.of(context).primaryColor, () {
              Navigator.pop(context);
            }),
            const SizedBox(height: 12),
            _buildModalActionButton(context, Icons.report_problem_rounded, 'Report Customer', AppColors.error, () {
              Navigator.pop(context);
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModalActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPaymentItem(String customer, String amount, String service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showPendingPaymentModal(context, customer, amount, service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pink.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  void _showStaffTimelineModal(BuildContext context, String name, String status, Color statusColor, String note) {
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
            Row(
              children: [
                CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), child: Icon(Icons.person, color: statusColor)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Note/Status Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(note, style: const TextStyle(color: AppColors.almostBlack300)),
            const Divider(height: 32),
            const Text('Full Day Schedule Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildTimelineScheduleItem('09:00 AM', 'Available'),
            _buildTimelineScheduleItem('10:00 AM', 'Busy (Haircut - Ali)'),
            _buildTimelineScheduleItem('11:00 AM', 'Available'),
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
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(child: Text(detail, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildBarberStatusItem(String name, String status, Color statusColor, String note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showStaffTimelineModal(context, name, status, statusColor, note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
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
