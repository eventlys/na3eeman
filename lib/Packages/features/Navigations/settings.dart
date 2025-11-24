import 'package:flutter/material.dart';
import '../../../Helpers/customized/dialog_helper.dart';
import '../../../Services/ui/language_service.dart';
import '../../../Services/ui/overlay_service.dart';
import '../../../Services/ui/sidebar_navigation_service.dart';
import '../../../Services/ui/theme_service.dart';
import '../../../Services/utils/location_service.dart';
import '../../Core/backgrounds/bd_faded.dart';
import '../../Core/themes/glass_appbar.dart';
import '../../Core/widgets/common/custom_switch_tile.dart';
import '../../Core/widgets/common/section_divider.dart';
import '../../Core/widgets/common/setting_tile.dart';
import '../auth/overlays/change_password_overlay.dart';
import '../profile/widgets/user_info_header.dart';

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
    return FadedBackground(
      startColor: const Color(0xFF806C99),
      endColor: const Color(0xFFDFA8A4),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: CustomScrollView(
          slivers: [
            GlassSliverAppBar(
              title: 'Settings',
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // User Info Section
                  const UserInfoHeader(),
                  const SectionDivider(),
                  const SizedBox(height: 16),

                  // Account Settings
                  _buildSectionHeader('Account Settings'),
                  SettingTile(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  SettingTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () => _showChangePasswordDialog(),
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
                  ValueListenableBuilder<String>(
                    valueListenable: _themeService.themeModeNotifier,
                    builder: (context, themeMode, child) {
                      return SettingTile(
                        icon: _getThemeIcon(themeMode),
                        title: 'Change Theme',
                        subtitle: themeMode,
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
                    icon: Icons.notifications,
                    title: 'Notification Settings',
                    onTap: () => _navigateToNotifications(),
                  ),
                  SettingTile(
                    icon: Icons.security,
                    title: 'Privacy & Security',
                    onTap: () => OverlayService.showPrivacyPolicy(),
                  ),
                  SettingTile(
                    icon: Icons.storage,
                    title: 'Storage Usage',
                    onTap: () => _navigateToStorage(),
                  ),
                  const SizedBox(height: 16),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
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

  void _changeLanguage() {
    DialogHelper.showLanguageBottomSheet(context, _languageService);
  }

  void _changeTheme() {
    DialogHelper.showThemeBottomSheet(context, _themeService);
  }

  void _rateApp() {
    // Open app store link
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirect to App Store')),
    );
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

