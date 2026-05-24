import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../Providers/features/admin_analytics_provider.dart';
import '../../../../Providers/features/offers_provider.dart';
import '../../../../Models/salon/offer_model.dart';
import '../../../../Models/salon/ad_campaign_model.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import 'admin_user_requests_page.dart';
import 'admin_faq_management.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchOverview();
      context.read<OffersProvider>().loadCampaigns(
        1,
      ); // Default salon for admin preview
    });
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminProvider = context.watch<AdminAnalyticsProvider>();
    final offersProvider = context.watch<OffersProvider>();
    final overview = adminProvider.overview;
    final primary = Theme.of(context).primaryColor;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(adminProvider),
          body: RefreshIndicator(
            onRefresh: () => adminProvider.fetchOverview(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loading bar
                  if (adminProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.lg),
                      child: LinearProgressIndicator(),
                    ),

                  // Error banner
                  if (adminProvider.error != null)
                    _buildErrorBanner(adminProvider.error!),

                  // ── KPI Row 1 ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          "total_users".tr(),
                          overview?['total_users']?.toString() ?? '—',
                          Icons.people_rounded,
                          primary,
                          growth: 'this_week_growth'.tr(
                            args: [
                              overview?['new_users_7d']?.toString() ?? '0',
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: _buildKpiCard(
                          "active_salons".tr(),
                          overview?['total_salons']?.toString() ?? '—',
                          Icons.storefront_rounded,
                          AppColors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),

                  // ── KPI Row 2 ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          "appointments".tr(),
                          overview?['total_appointments']?.toString() ?? '—',
                          Icons.calendar_month_rounded,
                          AppColors.success,
                          growth: 'this_week_growth'.tr(
                            args: [
                              overview?['new_appointments_7d']?.toString() ??
                                  '0',
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: _buildKpiCard(
                          "revenue".tr(),
                          'amount_jod_value'.tr(
                            args: [
                              overview?['total_revenue']?.toString() ?? '0',
                            ],
                          ),
                          Icons.payments_rounded,
                          AppColors.cream600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // ── Real-Time Monitoring ───────────────────────────────────
                  _buildSectionHeader("realtime_metrics".tr(), null),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildMonitoringRow(isDark),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // ── System Health ──────────────────────────────────────────
                  _buildSectionHeader(
                    "system_health".tr(),
                    "view_api_logs".tr(),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildHealthTile(
                    "api_status".tr(),
                    '99.9% Uptime',
                    AppColors.success,
                    Icons.cloud_done_rounded,
                    isDark,
                  ),
                  _buildHealthTile(
                    "cache_status".tr(),
                    'Connected',
                    AppColors.success,
                    Icons.memory_rounded,
                    isDark,
                  ),
                  _buildHealthTile(
                    "db_status".tr(),
                    'Active',
                    AppColors.success,
                    Icons.storage_rounded,
                    isDark,
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // ── Admin Modules ──────────────────────────────────────────
                  _buildSectionHeader("admin_modules".tr(), null),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildModuleGrid(),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // ── Insights ───────────────────────────────────────────────
                  _buildSectionHeader("insights".tr(), "analyze_trends".tr()),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildInsightCard(
                    "growth_insight".tr(),
                    Icons.trending_up_rounded,
                    AppColors.success,
                    isDark,
                  ),
                  _buildInsightCard(
                    "top_categories_insight".tr(),
                    Icons.bar_chart_rounded,
                    primary,
                    isDark,
                  ),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // ── Promotion & Campaign Monitoring ───────────────────────
                  _buildSectionHeader("campaign_performance".tr(), null),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildPerformanceAnalytics(offersProvider),
                  const SizedBox(height: AppSpacing.sectionSpacing),

                  // ── Feedback ───────────────────────────────────────────────
                  const FeedbackSection(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AdminAnalyticsProvider provider) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: IconButtonStyled(
        icon: Icons.menu_rounded,
        onPressed: sidebarController.toggleSidebar,
      ),
      actions: [
        IconButtonStyled(
          icon: Icons.notifications_none_rounded,
          onPressed: () => NotificationsBottomSheet.show(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            provider.fetchOverview();
            AppSnackBar.info(context, 'dashboard_refreshed'.tr());
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  // ─── KPI Card ────────────────────────────────────────────────────────────────

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? growth,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: AppSpacing.brXl,
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.05)
              : AppColors.almostBlack50,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: AppSpacing.brSm,
                ),
                child: Icon(icon, color: color, size: AppSpacing.iconMd),
              ),
              if (growth != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: AppSpacing.brSm,
                  ),
                  child: Text(
                    growth,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: AppSpacing.fontXs,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSpacing.fontXl,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: AppSpacing.fontSm,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Monitoring Row ──────────────────────────────────────────────────────────

  Widget _buildMonitoringRow(bool isDark) {
    final metrics = [
      ('247', "active_users".tr(), Icons.person_rounded, AppColors.blue),
      (
        '68%',
        "conversion_rate".tr(),
        Icons.sync_alt_rounded,
        AppColors.success,
      ),
      ('3.2%', "churn_rate".tr(), Icons.trending_down_rounded, AppColors.error),
      (
        '4m32s',
        "avg_session_time".tr(),
        Icons.timer_rounded,
        Theme.of(context).primaryColor,
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.cardGap),
        itemBuilder: (_, i) {
          final (value, label, icon, color) = metrics[i];
          return Container(
            width: 120,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.almostBlack600 : Colors.white,
              borderRadius: AppSpacing.brLg,
              border: Border.all(
                color: isDark
                    ? AppColors.white.withOpacity(0.05)
                    : AppColors.almostBlack50,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: AppSpacing.iconMd),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppSpacing.fontLg,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppSpacing.fontXs,
                    color: AppColors.almostBlack300,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Health Tile ─────────────────────────────────────────────────────────────

  Widget _buildHealthTile(
    String name,
    String status,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.listGap),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: AppSpacing.brMd,
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.05)
              : AppColors.almostBlack50,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSpacing.fontMd,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppSpacing.brSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: AppSpacing.fontSm,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Module Grid ─────────────────────────────────────────────────────────────

  Widget _buildModuleGrid() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    final modules = [
      (
        "total_users".tr(),
        Icons.manage_accounts_rounded,
        '/admin/users',
        primary,
      ),
      (
        "revenue".tr(),
        Icons.account_balance_rounded,
        '/admin/finance',
        AppColors.success,
      ),
      (
        "insights".tr(),
        Icons.insights_rounded,
        '/admin/analytics',
        AppColors.blue,
      ),
      (
        "compliance".tr(),
        Icons.verified_user_rounded,
        '/admin/compliance',
        AppColors.warning,
      ),
      (
        "service_requests".tr(),
        Icons.auto_awesome_rounded,
        '/admin/service-requests',
        AppColors.pink,
      ),
      (
        'customer_feedback'.tr(),
        Icons.rate_review_rounded,
        '/admin/feedback-review',
        Colors.teal,
      ),
      (
        "user_requests".tr(),
        Icons.inbox_rounded,
        'user-requests',
        const Color(0xFF6A1B9A),
      ),
      (
        'manage_faqs'.tr(),
        Icons.help_outline_rounded,
        'manage-faqs',
        Colors.orange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.cardGap,
        mainAxisSpacing: AppSpacing.cardGap,
        childAspectRatio: 2.0,
      ),
      itemCount: modules.length,
      itemBuilder: (context, i) {
        final (label, icon, route, color) = modules[i];
        return InkWell(
          onTap: () {
            if (route == 'user-requests') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminUserRequestsPage(),
                ),
              );
            } else if (route == 'manage-faqs') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminFAQManagementPage(),
                ),
              );
            } else {
              Navigator.pushNamed(context, route);
            }
          },
          borderRadius: AppSpacing.brMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.almostBlack600 : Colors.white,
              borderRadius: AppSpacing.brMd,
              border: Border.all(
                color: isDark
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: AppSpacing.brXs,
                  ),
                  child: Icon(icon, color: color, size: AppSpacing.iconMd),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: AppSpacing.fontMd,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Insight Card ─────────────────────────────────────────────────────────────

  Widget _buildInsightCard(
    String text,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.listGap),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : color.withOpacity(0.05),
        borderRadius: AppSpacing.brMd,
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: AppSpacing.fontMd),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error Banner ─────────────────────────────────────────────────────────────

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: AppSpacing.brMd,
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: AppSpacing.fontMd,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppSpacing.fontLg,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            child: Text(
              action,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: AppSpacing.fontMd,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  // ─── Performance Analytics ──────────────────────────────────────────────────

  Widget _buildPerformanceAnalytics(OffersProvider provider) {
    final allItems = [...provider.offers, ...provider.adCampaigns];
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'no_active_campaigns'.tr(),
            style: const TextStyle(color: AppColors.almostBlack300),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return _buildAnalyticsCard(item);
      },
    );
  }

  Widget _buildAnalyticsCard(dynamic item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: AppSpacing.brXl,
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.05)
              : AppColors.almostBlack50,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item is OfferModel
                    ? Icons.local_offer_rounded
                    : Icons.campaign_rounded,
                color: Theme.of(context).primaryColor,
                size: AppSpacing.iconSm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item is OfferModel ? item.title : item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSpacing.fontMd,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: AppSpacing.brSm,
                ),
                child: Text(
                  'active'.tr(),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('impressions'.tr(), '1.2k'),
              _buildStat('clicks'.tr(), '420'),
              _buildStat('conversions'.tr(), '15'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSpacing.fontLg,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSpacing.fontXs,
            color: AppColors.almostBlack300,
          ),
        ),
      ],
    );
  }
}
