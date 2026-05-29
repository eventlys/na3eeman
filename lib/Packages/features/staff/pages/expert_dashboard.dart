import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/api/endpoints.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/today_appointments_overview.dart';
import '../widgets/time_clock_widget.dart';
import '../widgets/tools_inventory_overview.dart';

class ExpertDashboard extends StatefulWidget {
  const ExpertDashboard({super.key});

  @override
  State<ExpertDashboard> createState() => _ExpertDashboardState();
}

class _ExpertDashboardState extends State<ExpertDashboard>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  int _todayAppointmentsCount = 0;
  final String _selectedFilter = 'All';
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

  Map<String, dynamic>? _expertInsights;
  bool _isInsightsLoading = false;

  void _loadData() async {
    // Load Inventory items
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final inventoryProvider = Provider.of<InventoryProvider>(
      context,
      listen: false,
    );

    setState(() => _isInsightsLoading = true);

    try {
      final apiService = ApiService();
      final insights = await apiService.get(Endpoints.expertInsights);
      setState(() {
        _expertInsights = insights;
      });
    } catch (e) {
      debugPrint('error_loading_insights'.tr(args: [e.toString()]));
    } finally {
      setState(() => _isInsightsLoading = false);
    }

    await inventoryProvider.loadInventoryItems(
      salonId: authProvider.user?.salonId,
    );
  }

  // Widget _buildAIInsightsSection(BuildContext context) {
  //   if (_isInsightsLoading && _expertInsights == null) {
  //     return const Center(child: CircularProgressIndicator(color: Colors.white));
  //   }

  //   final insights = (_expertInsights?['insights'] as List<dynamic>?) ?? [];

  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha:0.8)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Theme.of(context).primaryColor.withValues(alpha:0.3),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const Icon(Icons.psychology, color: Colors.white, size: 28),
  //             const SizedBox(width: 12),
  //             Text(
  //               'ai_staff_assistant'.tr(),
  //               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 20),
  //         if (insights.isEmpty)
  //           Text(
  //             'no_insights_available_yet_complete_more_appointments'.tr(),
  //             style: const TextStyle(color: Colors.white70, fontSize: 14),
  //           )
  //         else
  //           ...insights.map((item) {
  //             return Padding(
  //               padding: const EdgeInsets.only(bottom: 16),
  //               child: _buildInsightItem(
  //                 _getIconForInsight(item['icon']),
  //                 _getTranslatedInsightLabel(item['label']),
  //                 _getTranslatedInsightValue(item['value']),
  //               ),
  //             );
  //           }),
  //       ],
  //     ),
  //   );
  // }

  IconData _getIconForInsight(String? iconName) {
    switch (iconName) {
      case 'star_rounded':
        return Icons.star_rounded;
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      case 'event_available':
        return Icons.event_available;
      default:
        return Icons.insights_rounded;
    }
  }

  String _getTranslatedInsightLabel(String? key) {
    if (key == null) return '';
    return key.tr();
  }

  String _getTranslatedInsightValue(String? value) {
    if (value == null) return '';
    // Check if value matches any of our known freq or status keys
    return value.tr();
  }

  Widget _buildInsightItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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
                  // Welcome Header
                  Text(
                    'hello_user_name'.tr(args: [user?.firstName ?? "Member"]) +
                        " 👋",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'today_appointments_count_msg'.tr(
                      args: [_todayAppointmentsCount.toString()],
                    ),
                  ),

                  // const SizedBox(height: 16),
                  // ── Time Clock ─────────────────────────────────────────
                  const TimeClockWidget(),

                  // const SizedBox(height: 24),

                  // _buildAIInsightsSection(context),

                  // const SizedBox(height: 32),

                  // const ToolsAndInventoryOverview(),
                  const SizedBox(height: 32),

                  TodayAppointmentsOverview(
                    todayEarnings: (_expertInsights?['today_earnings'] as num?)
                        ?.toDouble(),
                    completedToday: _expertInsights?['completed_today'] as int?,
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
}
