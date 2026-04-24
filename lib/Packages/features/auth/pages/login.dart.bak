import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Models/auth/user_model.dart';
import 'package:na3eeman/Packages/Core/constants/app_roles.dart';
import 'package:na3eeman/Services/ui/navigation_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/Providers/locale_provider.dart';
import 'package:na3eeman/Services/security_service.dart';
import 'package:na3eeman/Providers/main_providers.dart';
import 'package:na3eeman/Helpers/login_helper.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/dashboard/dashboard_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _selectedGender = 'male';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  String _getLogoAsset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    if (isArabic) {
      return isDark ? 'assets/images/logo_ar_dark.png' : 'assets/images/logo_ar_light.png';
    } else {
      return isDark ? 'assets/images/logo_en_dark.png' : 'assets/images/logo_en_light.png';
    }
  }

  void _showLanguageDialog() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: localeProvider.locale.languageCode == 'en' ? Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: const Text('العربية'),
              trailing: localeProvider.locale.languageCode == 'ar' ? Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                localeProvider.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBiometricLogin() async {
    final securityService = SecurityService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final bool canCheck = await securityService.isBiometricAvailable();
    if (!canCheck) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometrics not available on this device')),
        );
      }
      return;
    }

    final bool success = await securityService.authenticate(
      reason: AppLocalizations.of(context)!.loginWithBiometrics,
    );

    if (success) {
      await authProvider.loadSavedAuth();
      if (authProvider.isAuthenticated && mounted) {
        final userRole = authProvider.userType?.name.toLowerCase() ?? 'customer';
        final user = authProvider.user;
        final String? tier = user?.subscriptionTier?.name.toUpperCase();
        NavigationService.navigateToHomeBasedOnRole(context, userRole, tier: tier);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login with password first to enable biometrics')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await authProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        Navigator.pop(context); // Remove loading indicator

        if (success) {
          final userRole = authProvider.userType?.name.toLowerCase() ?? 'customer';
          final user = authProvider.user;
          final String? tier = user?.subscriptionTier?.name.toUpperCase();
          NavigationService.navigateToHomeBasedOnRole(context, userRole, tier: tier);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')), 
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [AppColors.almostBlack700, AppColors.almostBlack800]
                  : [AppColors.white, AppColors.creamyBackground.withOpacity(0.5)],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.language_rounded),
                            onPressed: _showLanguageDialog,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),

                      // Official Logo Asset
                      Center(
                        child: Image.asset(
                          _getLogoAsset(context),
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.cut_rounded,
                            size: 80,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.emailIsRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible 
                                      ? Icons.visibility_off_outlined 
                                      : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.passwordIsRequired;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: l10n.signIn,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _handleBiometricLogin,
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(l10n.loginWithBiometrics),
                      ),
                      
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.donTHaveAnAccountSignUp.split('?')[0] + '?'),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/signup'),
                            child: Text(l10n.signUp),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      if (kDebugMode) _buildTestingSection(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TESTING QUICK ACCESS SECTION (Real Login)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTestingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? AppColors.almostBlack600 : AppColors.cream600)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                AppLocalizations.of(context)!.searchServicesSalons, // Using an existing key as a label for testing
                style: TextStyle(color: AppColors.almostBlack400, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider(color: isDark ? AppColors.almostBlack600 : AppColors.cream600)),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(12),
            isSelected: [_selectedGender == 'male', _selectedGender == 'female'],
            onPressed: (index) => setState(() => _selectedGender = index == 0 ? 'male' : 'female'),
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(AppLocalizations.of(context)!.male)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text(AppLocalizations.of(context)!.female)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildQuickAccessCard(
          title: 'System Admin',
          subtitle: 'Full platform control',
          icon: Icons.admin_panel_settings_outlined,
          color: Colors.blue,
          onTap: () => _quickAccessLogin('admin@na3eeman.com'),
        ),
        _buildQuickAccessCard(
          title: 'Customer',
          subtitle: '${_selectedGender[0].toUpperCase() + _selectedGender.substring(1)} profile',
          icon: Icons.person_outline_rounded,
          color: AppColors.pink,
          onTap: () => _quickAccessLogin('${_selectedGender}_customer1@test.com'),
        ),
        _buildQuickAccessCard(
          title: 'Employee / Barber',
          subtitle: 'Operational dashboard',
          icon: Icons.content_cut_rounded,
          color: Colors.orange,
          onTap: () => _quickAccessLogin('employee1@test.com'),
        ),
        _buildQuickAccessCard(
          title: 'Receptionist',
          subtitle: 'Front-desk management',
          icon: Icons.support_agent_outlined,
          color: Colors.teal,
          onTap: () => _quickAccessLogin('reception1@test.com'),
        ),
        _buildQuickAccessCard(
          title: 'Intern',
          subtitle: 'Task list & learning',
          icon: Icons.school_outlined,
          color: Colors.deepPurple,
          onTap: () => _quickAccessLogin('intern1@test.com'),
        ),

        const SizedBox(height: 16),
        Text('Business Owners (By Tier)',
          style: TextStyle(
            color: isDark ? AppColors.cream : AppColors.almostBlack600,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        _buildQuickAccessCard(
          title: 'Owner - Empire',
          subtitle: 'Multi-branch & Analytics',
          icon: Icons.domain_rounded,
          color: Colors.indigo,
          onTap: () => _quickAccessLogin('empire@owner.com'),
        ),
        _buildQuickAccessCard(
          title: 'Owner - Elite',
          subtitle: 'Premium Spa & Resource Mgmt',
          icon: Icons.workspace_premium_outlined,
          color: Colors.amber[700],
          onTap: () => _quickAccessLogin('elite@owner.com'),
        ),
        _buildQuickAccessCard(
          title: 'Owner - Studio (Basic)',
          subtitle: 'Small team management',
          icon: Icons.storefront_rounded,
          color: Colors.green,
          onTap: () => _quickAccessLogin('basic@owner.com'),
        ),
        _buildQuickAccessCard(
          title: 'Owner - Artisan',
          subtitle: 'Solo practitioner',
          icon: Icons.store_mall_directory_outlined,
          color: Colors.brown,
          onTap: () => _quickAccessLogin('artisian@owner.com'),
        ),
        _buildQuickAccessCard(
          title: 'Owner - Expired',
          subtitle: 'Renew subscription screen',
          icon: Icons.history_rounded,
          color: Colors.red,
          onTap: () => _quickAccessLogin('expired@owner.com'),
        ),
        _buildQuickAccessCard(
          title: 'Co-Founder',
          subtitle: 'Shared owner access & data IO',
          icon: Icons.group_work_rounded,
          color: Colors.deepOrange,
          onTap: () => _quickAccessLogin('cofounder@test.com'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? AppColors.almostBlack500 : AppColors.almostBlack50),
      ),
      color: isDark ? AppColors.almostBlack600 : AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: TextStyle(color: isDark ? AppColors.cream600 : AppColors.almostBlack400, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.login_rounded, color: isDark ? AppColors.almostBlack400 : AppColors.almostBlack200, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _quickAccessLogin(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'Password123!';
    });
    _handleLogin();
  }
}
