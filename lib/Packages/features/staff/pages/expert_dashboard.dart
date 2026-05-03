import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
// import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/today_appointments_overview.dart';
import '../widgets/time_clock_widget.dart';
// import 'package:intl/intl.dart';
// import '../../../../Services/api/api_service.dart';
// import '../../../../Services/api/endpoints.dart';
// import '../../appointments/widgets/appointments_list.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  int _todayAppointmentsCount = 0; // Added for header count update
  final String _selectedFilter = 'All'; // Inside TodayAppointmentsOverview now but keep or remove if unneeded
  // List<Map<String, dynamic>> _todayAppointments = []; // Removed

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

  void _loadData() async {
    // Load Inventory items
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadInventoryItems(salonId: authProvider.user?.salonId);
  }

// Rest of body logic is simplified via TodayAppointmentsOverview Wrap

  Widget _buildAIInsightsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'AI Staff Assistant'.tr(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            Icons.star_rounded,
            'Most Loyal Today',
            'Ahmed Mohammed (15 visits)',
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            Icons.trending_up_rounded,
            'Busiest Period',
            '2:00 PM - 5:00 PM',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // Welcome Header
              // Text(
              //   'Hello, ${user?.firstName ?? "Member"}! 👋',
              //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),
              // Text(
              //   'You have $_todayAppointmentsCount appointments scheduled for today.',
              // ),
              
              // const SizedBox(height: 16),
              // ── Time Clock ─────────────────────────────────────────
              const TimeClockWidget(),

              const SizedBox(height: 24),
              
              _buildAIInsightsSection(context),
              
              const SizedBox(height: 32),
              
              TodayAppointmentsOverview(
                onCountLoaded: (count) {
                  setState(() {
                    _todayAppointmentsCount = count;
                  });
                },
              ),
              
              const SizedBox(height: 32),

              const FeedbackSection(),

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

// _buildSectionHeader and _buildSummaryCard removed

// _buildAppointmentStatesFilter removed (extracted)

// Rest of helper layout is now simplified inside child widget

// _buildToolCard removed
}
