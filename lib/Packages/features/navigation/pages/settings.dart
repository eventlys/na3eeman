// ignore_for_file: unrelated_type_equality_checks, unused_local_variable
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../Models/subscription/subscription_plan_model.dart';
import '../../../../Services/ui/overlay_service.dart';
import '../../../../Services/ui/sidebar_navigation_service.dart';
import '../../../../Services/utils/location_service.dart';
import '../../../Core/constants/app_roles.dart';
import '../../auth/overlays/change_password_overlay.dart';
import '../../../../Providers/app_providers.dart';
import '../../../../Providers/locale_provider.dart';
import '../../../../Providers/features/auth_provider.dart';
import '../../../../Providers/features/subscription_provider.dart';
import '../../../../../core/widgets/rules/rules_guide_sheet.dart';
import '../../../../Services/core/user_service.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../Routes/route_names.dart';
import '../../../../core/theme/spacing.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocationService _locationService = LocationService();
  List<SubscriptionPlan>? _plans;
  bool _isLoadingPlans = false;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    if (_plans != null) return;
    setState(() => _isLoadingPlans = true);
    try {
      final plans = await context
          .read<SubscriptionProvider>()
          .getSubscriptionPlans();
      if (mounted) {
        setState(() {
          _plans = plans.map((p) => SubscriptionPlan.fromJson(p)).toList();
          _isLoadingPlans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPlans = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "settings".tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppSpacing.fontLg,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconMd,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: AppSpacing.listGap),

          // Account Settings
          _buildSectionHeader('account_settings'.tr()),
          _buildCleanTile(
            icon: Icons.person_outline_rounded,
            title: "profile".tr(),
            onTap: () => Navigator.pushNamed(context, RouteNames.profile),
          ),
          _buildCleanTile(
            icon: Icons.lock_outline_rounded,
            title: "change_password".tr(),
            onTap: () => _showChangePasswordDialog(),
          ),
          if (user?.role == UserRole.owner ||
              user?.role == UserRole.receptionist)
            _buildCleanTile(
              icon: Icons.card_membership_rounded,
              title: 'subscription_management'.tr(),
              onTap: () => _showSubscriptionManagementModal(),
            ),

          const SizedBox(height: AppSpacing.sectionGap),

          // App Preferences
          _buildSectionHeader('app_preferences'.tr()),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              final isArabic = context.locale.languageCode == 'ar';
              return _buildSwitchTile(
                icon: Icons.language_rounded,
                title: 'language'.tr(),
                subtitle: isArabic ? 'العربية' : 'English',
                value: isArabic,
                onChanged: (val) async {
                  final newLocale = val
                      ? const Locale('ar', 'EG')
                      : const Locale('en', 'US');
                  await context.setLocale(newLocale);
                  await localeProvider.setLocale(
                    Locale(newLocale.languageCode),
                  );
                },
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSwitchTile(
                icon: themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: 'dark_mode'.tr(),
                subtitle: themeProvider.isDark
                    ? 'dark_theme'.tr()
                    : 'light_theme'.tr(),
                value: themeProvider.isDark,
                onChanged: (val) {
                  themeProvider.toggleBrightness();
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _locationService.locationEnabledNotifier,
            builder: (context, isEnabled, child) {
              return _buildSwitchTile(
                icon: Icons.location_on_outlined,
                title: 'location_privacy'.tr(),
                subtitle: isEnabled ? 'always_on'.tr() : 'off'.tr(),
                value: isEnabled,
                onChanged: (value) => _locationService.toggleLocation(value),
              );
            },
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // Support & Feedback
          _buildSectionHeader('support_feedback'.tr()),
          _buildCleanTile(
            icon: Icons.star_outline_rounded,
            title: 'rate_us'.tr(),
            onTap: () => _rateApp(),
          ),
          _buildCleanTile(
            icon: Icons.feedback_outlined,
            title: 'send_feedback'.tr(),
            onTap: () => OverlayService.showFeedback(),
          ),
          _buildCleanTile(
            icon: Icons.report_problem_outlined,
            title: 'report_a_problem'.tr(),
            onTap: () => _showReportProblemDialog(),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // More
          _buildSectionHeader('more'.tr()),
          _buildCleanTile(
            icon: Icons.security_outlined,
            title: 'privacy_security'.tr(),
            onTap: () => _showPrivacyPolicy(),
          ),
          _buildCleanTile(
            icon: Icons.rule_rounded,
            title: 'app_rules'.tr(),
            onTap: () => _showAppRules(),
          ),
          _buildCleanTile(
            icon: Icons.help_outline_rounded,
            title: 'user_guides'.tr(),
            onTap: () => _showUserGuide(),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Delete Account
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TextButton.icon(
              icon: const Icon(
                Icons.person_remove_rounded,
                color: Colors.red,
                size: AppSpacing.iconMd,
              ),
              label: Text(
                "delete_account".tr(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: () => _showDeleteAccountConfirmation(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.brSm),
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: TextButton.icon(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: AppSpacing.iconMd,
              ),
              label: Text(
                "logout".tr(),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onPressed: () => OverlayService.showLogoutConfirmation(
                onConfirm: () {
                  SideNavigationService.navigateToLogin();
                },
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.brSm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildCleanTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: _buildLeadingIcon(context, icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: AppSpacing.fontSm,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: AppSpacing.iconBase,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      leading: _buildLeadingIcon(context, icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: AppSpacing.fontSm, color: Colors.grey[600]),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).primaryColor,
        ),
      ),
      onTap: () => onChanged(!value),
    );
  }

  /// Shared leading icon box for settings tiles: same padding, radius, and
  /// icon size everywhere so icons align across rows.
  Widget _buildLeadingIcon(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
        borderRadius: AppSpacing.brSm,
      ),
      child: Icon(
        icon,
        color: Theme.of(context).primaryColor,
        size: AppSpacing.iconMd,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showSubscriptionManagementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.pageV),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppSpacing.brSheet,
        ),
        child: Column(
          children: [
            Text(
              'subscription_plans'.tr(),
              style: const TextStyle(
                fontSize: AppSpacing.fontXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: _isLoadingPlans
                  ? const Center(child: CircularProgressIndicator())
                  : _plans == null || _plans!.isEmpty
                  ? Center(
                      child: Text(
                        'no_plans_available'.tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageH,
                      ),
                      child: Row(
                        children: _plans!
                            .map(
                              (plan) => _buildSubscriptionCard(
                                plan.name,
                                '\$${plan.price.toStringAsFixed(0)}/mo',
                                plan.features,
                                isRecommended: plan.isPopular,
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    String title,
    String price,
    List<String> features, {
    bool isRecommended = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      margin: const EdgeInsets.only(
        right: AppSpacing.md,
        bottom: AppSpacing.pageH,
        top: AppSpacing.listGap,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isRecommended
            ? Theme.of(context).primaryColor
            : (isDark ? Colors.grey[900] : Colors.white),
        borderRadius: AppSpacing.brXl,
        border: Border.all(
          color: isRecommended
              ? Colors.transparent
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
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
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: AppSpacing.xs,
              ),
              margin: const EdgeInsets.only(bottom: AppSpacing.listGap),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppSpacing.brLg,
              ),
              child: Text(
                'recommended'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSpacing.fontXs,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: AppSpacing.fontLg,
              fontWeight: FontWeight.bold,
              color: isRecommended
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            price,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isRecommended
                  ? Colors.white
                  : Theme.of(context).primaryColor,
            ),
          ),
          const Divider(height: AppSpacing.xl),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: features
                  .map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: isRecommended ? Colors.white : Colors.green,
                            size: AppSpacing.iconSm,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isRecommended
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700]),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/subscription/upgrade',
                  arguments: {'title': title, 'price': price},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecommended
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                foregroundColor: isRecommended
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppSpacing.brSm),
                elevation: 0,
              ),
              child: Text('select_plan'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
    final url = Uri.parse('market://details?id=com.na3eman.app');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fall back to the web Play Store link if the market app isn't available.
      final webUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.na3eman.app',
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        AppSnackBar.error(context, 'could_not_open_app_store'.tr());
      }
    }
  }

  void _showReportProblemDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('report_a_problem'.tr()),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.brLg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('describe_problem'.tr()),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'enter_details_here'.tr(),
                border: OutlineInputBorder(borderRadius: AppSpacing.brSm),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackBar.success(context, 'report_submitted_thanks'.tr());
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.brSm),
            ),
            child: Text('submit'.tr()),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    RulesGuideSheet.showPrivacySheet(context);
  }

  void _showAppRules() {
    RulesGuideSheet.showRulesSheet(context);
  }

  void _showUserGuide() {
    RulesGuideSheet.showGuideSheet(context);
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_account'.tr()),
        content: Text('delete_account_confirmation_desc'.tr()),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.brLg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                final userService = UserService();
                await userService.deactivateMyAccount();
                if (!mounted) return;
                Navigator.pop(context); // hide loading
                // Clear auth state and navigate to login
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
                SideNavigationService.navigateToLogin();
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context); // hide loading
                AppSnackBar.error(context, 'Error: ${e.toString()}');
              }
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
