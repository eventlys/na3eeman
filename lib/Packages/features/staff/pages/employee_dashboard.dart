import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
// import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/tools_inventory_overview.dart';
import '../widgets/today_appointments_overview.dart';
// import 'package:intl/intl.dart';
// import '../../../../Services/api/api_service.dart';
// import '../../../../Services/api/endpoints.dart';
import 'package:easy_localization/easy_localization.dart';
// import '../../appointments/widgets/appointments_list.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  int _todayAppointmentsCount = 0; // Added for header count update
  String _selectedFilter = 'All'; // Inside TodayAppointmentsOverview now but keep or remove if unneeded
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
    await inventoryProvider.loadInventoryItems(shopId: authProvider.user?.shopId);
  }

// Rest of body logic is simplified via TodayAppointmentsOverview Wrap

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
        title: Text('${user?.specialization ?? "Staff"} Dashboard', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              // Welcome Header
              Text(
                'Hello, ${user?.firstName ?? "Member"}! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You have $_todayAppointmentsCount appointments scheduled for today.',
              ),
              
              const SizedBox(height: 32),
              
              TodayAppointmentsOverview(
                onCountLoaded: (count) {
                  setState(() {
                    _todayAppointmentsCount = count;
                  });
                },
              ),
              
              const SizedBox(height: 32),

              // Inventory & Tools Section
              DashboardSectionHeader(title: 'tools_inventory'.tr()),
              const SizedBox(height: 16),
              const ToolsAndInventoryOverview(),

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
