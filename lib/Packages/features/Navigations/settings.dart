import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helpers/customized/dialog_helper.dart';
import '../../../Services/ui/language_service.dart';
import '../../../Services/ui/overlay_service.dart';
import '../../../Services/ui/sidebar_navigation_service.dart';
import '../../../Services/ui/theme_service.dart';
import '../../../Services/utils/location_service.dart';
import '../../Core/themes/glass_appbar.dart';
import '../../Core/widgets/common/custom_switch_tile.dart';
import '../../Core/widgets/common/setting_tile.dart';
import '../auth/overlays/change_password_overlay.dart';
import 'package:provider/provider.dart';
import '../../../Providers/app_providers.dart';
import '../../../core/enums/app_enums.dart';
import '../../../Providers/features/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeService _themeService = ThemeService();
  final LanguageService _languageService = LanguageService();
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          GlassSliverAppBar(
            title: tr('settings'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Settings
                _buildSectionHeader('Account Settings'),
                SettingTile(
                  icon: Icons.person,
                  title: tr('profile'),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                SettingTile(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () => _showChangePasswordDialog(),
                ),
                if (Provider.of<AuthProvider>(context, listen: false).user?.role == UserRole.owner || Provider.of<AuthProvider>(context, listen: false).user?.role == UserRole.receptionist)
                  SettingTile(
                    icon: Icons.card_membership_rounded,
                    title: 'Subscription Management',
                    onTap: () => _showSubscriptionManagementModal(),
                  ),
                const SizedBox(height: 16),

                // App Preferences
                _buildSectionHeader('App Preferences'),
                ListenableBuilder(
                  listenable: _languageService,
                  builder: (context, child) {
                    return SettingTile(
                      icon: Icons.language,
                      title: 'Change Language',
                      subtitle: _languageService.currentLanguage,
                      onTap: () => _changeLanguage(),
                    );
                  },
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    final themeName = themeProvider.isDark ? 'Dark' : 'Light';
                    return SettingTile(
                      icon: _getThemeIcon(themeName),
                      title: 'Change Theme',
                      subtitle: themeName,
                      onTap: () => _changeTheme(),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _locationService.locationEnabledNotifier,
                  builder: (context, isEnabled, child) {
                    return CustomSwitchTile(
                      icon: Icons.location_on,
                      title: 'Location Privacy',
                      subtitle: isEnabled ? 'Enabled' : 'Disabled',
                      value: isEnabled,
                      onChanged: (value) => _locationService.toggleLocation(value),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Support & Feedback
                _buildSectionHeader('Support & Feedback'),
                SettingTile(
                  icon: Icons.star,
                  title: 'Rate Us',
                  onTap: () => _rateApp(),
                ),
                SettingTile(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  onTap: () => OverlayService.showFeedback(),
                ),
                SettingTile(
                  icon: Icons.report_problem,
                  title: 'Report a Problem',
                  onTap: () => OverlayService.showReportProblem(),
                ),
                const SizedBox(height: 16),

                // Additional Suggested Settings
                _buildSectionHeader('More'),
                SettingTile(
                  icon: Icons.security,
                  title: 'Privacy & Security',
                  onTap: () => OverlayService.showPrivacyPolicy(),
                ),
                const SizedBox(height: 16),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: Text(tr('logout'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => OverlayService.showLogoutConfirmation(
                      onConfirm: () {
                        SideNavigationService.navigateToLogin();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  IconData _getThemeIcon(String themeMode) {
    switch (themeMode) {
      case 'Light':
        return Icons.light_mode;
      case 'Dark':
        return Icons.dark_mode;
      case 'System':
        return Icons.phone_iphone;
      default:
        return Icons.light_mode;
    }
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
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Text(tr('subscription_plans'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSubscriptionCard('Basic Plan', '\$29/mo', ['1 Barber Seat', 'Basic Analytics', 'Email Support']),
                    _buildSubscriptionCard('Growth Plan', '\$59/mo', ['Up to 5 Barbers', 'Full Analytics', 'Priority Support'], isRecommended: true),
                    _buildSubscriptionCard('Enterprise', '\$99/mo', ['Unlimited', 'Branch Multi-management', '24/7 Dedicated Support']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(String title, String price, List<String> features, {bool isRecommended = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 20, top: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isRecommended ? Theme.of(context).primaryColor : (isDark ? Colors.grey[900] : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isRecommended ? Colors.transparent : (isDark ? Colors.grey[800]! : Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(tr('recommended'), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isRecommended ? Colors.white : (isDark ? Colors.white : Colors.black))),
          const SizedBox(height: 8),
          Text(price, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isRecommended ? Colors.white : Theme.of(context).primaryColor)),
          const Divider(height: 32, color: Colors.grey),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [Icon(Icons.check_circle, color: isRecommended ? Colors.white : Colors.green, size: 16), const SizedBox(width: 8), Text(f, style: TextStyle(color: isRecommended ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]), fontSize: 13))]),
              )).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscription/upgrade', arguments: {'title': title, 'price': price});
              },
              style: ElevatedButton.styleFrom(backgroundColor: isRecommended ? Colors.white : Theme.of(context).primaryColor, foregroundColor: isRecommended ? Theme.of(context).primaryColor : Colors.white),
              child: Text(tr('select_plan')),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage() {
    DialogHelper.showLanguageBottomSheet(context, _languageService);
  }

  void _changeTheme() {
    DialogHelper.showThemeBottomSheet(context, _themeService);
  }

  Future<void> _rateApp() async {
    final url = Uri.parse('market://details?id=com.example.na3eeman');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open App Store')),
        );
      }
    }
  }

  void _navigateToNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Notification Settings')),
    );
  }

  void _navigateToStorage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Storage Usage')),
    );
  }
}


