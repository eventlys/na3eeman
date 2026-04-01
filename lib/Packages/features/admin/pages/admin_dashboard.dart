import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../Providers/features/admin_analytics_provider.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    
    // Fetch real data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchOverview();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminProvider = context.watch<AdminAnalyticsProvider>();
    final overview = adminProvider.overview;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('admin_portal'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
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
            onRefresh: () => adminProvider.fetchOverview(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (adminProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: LinearProgressIndicator(),
                    ),
                  
                  if (adminProvider.error != null)
                    _buildErrorNotification(adminProvider.error!),

                  // Platform Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'total_users'.tr(), 
                          overview?['total_users']?.toString() ?? '...', 
                          Icons.people_rounded, 
                          Theme.of(context).primaryColor,
                          growth: '+${overview?['new_users_7d'] ?? 0}'
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'active_shops'.tr(), 
                          overview?['total_shops']?.toString() ?? '...', 
                          Icons.storefront_rounded, 
                          AppColors.pink
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'appointments'.tr(), 
                          overview?['total_appointments']?.toString() ?? '...', 
                          Icons.calendar_month_rounded, 
                          AppColors.success,
                          growth: '+${overview?['new_appointments_7d'] ?? 0}'
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKpiCard(
                          'revenue'.tr(), 
                          '${overview?['total_revenue']?.toString() ?? '0'} SAR', 
                          Icons.payments_rounded, 
                          AppColors.cream600
                        )
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // System Health / API Monitor
                  _buildSectionHeader('system_health'.tr(), 'view_api_logs'.tr()),
                  const SizedBox(height: 16),
                  _buildHealthMonitor('api_status'.tr(), '99.9% Uptime', AppColors.success),
                  _buildHealthMonitor('cache_status'.tr(), 'Connected', AppColors.success),
                  _buildHealthMonitor('db_status'.tr(), 'Active', AppColors.success),

                  const SizedBox(height: 32),

                  // Admin Modules
                  _buildSectionHeader('admin_modules'.tr(), 'settings'.tr()),
                  const SizedBox(height: 16),
                  _buildModuleGrid(),

                  const SizedBox(height: 32),

                  // Critical Updates / Alerts
                  _buildSectionHeader('insights'.tr(), 'analyze_trends'.tr()),
                  const SizedBox(height: 16),
                  _buildInsightCard('growth_insight'.tr()),
                  _buildInsightCard('top_categories_insight'.tr()),

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

  Widget _buildErrorNotification(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(error, style: const TextStyle(color: AppColors.error, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String text) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: isDark ? AppColors.almostBlack600 : AppColors.blue.withOpacity(0.05),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.blue.withOpacity(0.1)),
       ),
       child: Row(
         children: [
           const Icon(Icons.lightbulb_outline_rounded, color: AppColors.blue),
           const SizedBox(width: 16),
           Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
         ],
       ),
     );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, {String? growth}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(growth, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHealthMonitor(String name, String status, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildModuleGrid() {
    final modules = [
      {'label': 'users', 'icon': Icons.manage_accounts_rounded, 'route': '/admin/users'},
      {'label': 'finance', 'icon': Icons.account_balance_rounded, 'route': '/admin/finance'},
      {'label': 'analytics', 'icon': Icons.insights_rounded, 'route': '/admin/analytics'},
      {'label': 'compliance', 'icon': Icons.verified_user_rounded, 'route': '/admin/compliance'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final m = modules[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, m['route'] as String),
          borderRadius: BorderRadius.circular(16),
          child: _buildModuleTile((m['label'] as String).tr(), m['icon'] as IconData),
        );
      },
    );
  }

  Widget _buildModuleTile(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {},
          child: Text(action, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
