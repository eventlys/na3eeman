import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'package:na3eeman/Providers/features/owner_provider.dart';
// import 'package:na3eeman/core/config/subscription_config.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/notifications/notifications_bottom_sheet.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/dashboard/dashboard_widgets.dart';

import 'package:na3eeman/Packages/features/navigation/sidebar.dart';
import 'package:na3eeman/Packages/features/navigation/sidebar_controller.dart';
import 'package:na3eeman/Packages/features/salon/pages/feedback_management_page.dart';
import '../widgets/artisan/daily_earnings_widget.dart';

// Artisan standalone
import 'package:na3eeman/Packages/features/staff/widgets/tools_inventory_overview.dart';
import 'package:na3eeman/Packages/features/staff/widgets/today_appointments_overview.dart';
import 'package:na3eeman/Packages/features/subscription/widgets/subscription_details_modal.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/widgets/dev_account_switcher.dart';
import 'package:na3eeman/Packages/features/owner/widgets/campaign_management_widgets.dart';
import 'package:na3eeman/Packages/features/owner/widgets/assign_tip_modal.dart';
import '../widgets/shared/practitioner_mode_toggle.dart';
import 'package:easy_localization/easy_localization.dart';

/// Tier-aware Owner Dashboard.
///
/// Reads [OwnerProvider] and builds the appropriate widget set for the user's
/// active subscription tier. No hardcoded tier checks in the UI — only
/// [OwnerProvider.canAccess] and [OwnerProvider.dashboardWidgets].
class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage>
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
            onRefresh: () async {
              // Future: call owner.refresh() to re-fetch from backend
            },
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Subscription banner ────────────────────────────────
                  if (!owner.isSubscriptionActive)
                    _SubscriptionBanner(
                        expired: true, daysLeft: owner.daysRemaining),
                  if (owner.isRenewalWarning && owner.isSubscriptionActive)
                    _SubscriptionBanner(
                        expired: false, daysLeft: owner.daysRemaining),

                  // ── Tier header ────────────────────────────────────────
                  _TierHeader(owner: owner),
                  const SizedBox(height: 24),

                  // Manager Dashboard overlay for expired
                  if (!owner.isSubscriptionActive)
                    Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildUniversalDashboardWidgets(context, owner),
                        ),
                      ),
                    )
                  else
                    ..._buildUniversalDashboardWidgets(context, owner),



                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
          bottomNavigationBar: owner.isSubscriptionActive 
              ? _buildQuickActionsBottomBar(context, owner)
              : null,
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
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: [
            IconButtonStyled(
              icon: Icons.menu_rounded,
              onPressed: _sidebarController.toggleSidebar,
            ),
            const SizedBox(width: 8),
            const GlobalSearchBar(),
          ],
        ),
      ),
      actions: [
        const PractitionerModeToggle(),
        const SizedBox(width: 8),
        IconButtonStyled(
          icon: Icons.notifications_none_rounded,
          onPressed: () => NotificationsBottomSheet.show(context),
        ),
      ],
    );
  }

  Widget _buildQuickActionsBottomBar(BuildContext context, OwnerProvider owner) {
    return SafeArea(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(context, 'Offers', Icons.local_offer_rounded, Colors.orange, () => CampaignManagement.showCreateOfferDialog(context)),
            _buildBottomNavItem(context, 'Ads', Icons.campaign_rounded, Colors.purple, () => CampaignManagement.showCreateAdDialog(context)),
            _buildBottomNavItem(context, 'Feedback', Icons.rate_review_rounded, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackManagementPage()))),
            _buildBottomNavItem(context, 'Tip', Icons.attach_money_rounded, Colors.green, () => AssignTipModal.show(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }


  List<Widget> _buildUniversalDashboardWidgets(
      BuildContext context, OwnerProvider owner) {
    return [
      const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: TodayAppointmentsOverview(),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: DashboardCard(child: DailyEarningsWidget()),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionHeader(title: AppLocalizations.of(context)!.toolsInventory),
            const SizedBox(height: 12),
            const ToolsAndInventoryOverview(),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: FeedbackSection(),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

// _DashboardCard is removed and replaced by shared DashboardCard

class _TierHeader extends StatelessWidget {
  final OwnerProvider owner;
  const _TierHeader({required this.owner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = owner.tier;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.welcomeBack,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _TierBadge(tier: tier),
                  const SizedBox(width: 8),
                  if (owner.isTrial)
                    const _TrialBadge(),
                ],
              ),
            ],
          ),
        ),
        if (owner.daysRemaining != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${owner.daysRemaining} days left',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: owner.isRenewalWarning
                      ? Colors.orange
                      : theme.hintColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(AppLocalizations.of(context)!.onYourPlan,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.hintColor)),
            ],
          ),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  final OwnerSubscriptionTier tier;
  const _TierBadge({required this.tier});

  Color _color(BuildContext context) {
    switch (tier) {
      case OwnerSubscriptionTier.artisan:
        return Colors.teal;
      case OwnerSubscriptionTier.studio:
        return Colors.blue;
      case OwnerSubscriptionTier.elite:
        return Colors.purple;
      case OwnerSubscriptionTier.empire:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            tier.displayName,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TrialBadge extends StatelessWidget {
  const _TrialBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(AppLocalizations.of(context)!.trial,
            style: TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}

class _SubscriptionBanner extends StatelessWidget {
  final bool expired;
  final int? daysLeft;
  const _SubscriptionBanner({required this.expired, this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = expired ? AppColors.error : AppColors.warning;
    final icon = expired ? Icons.error_outline_rounded : Icons.warning_amber_rounded;
    final message = expired
        ? 'Subscription Expired'
        : 'Renewal Warning';
    final subMessage = expired
        ? 'Renew to regain full access to your business tools.'
        : 'Your plan expires in $daysLeft days. Renew now to avoid interruption.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => SubscriptionDetailsModal.show(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subMessage,
                          style: TextStyle(
                            color: color.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
