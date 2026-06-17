import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:na3eeman/Services/ui/navigation_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/Services/security_service.dart';
import 'package:na3eeman/Providers/main_providers.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final String _selectedGender = 'male';
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  String _getLogoAsset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    if (isArabic) {
      return isDark
          ? 'assets/images/logo_ar_dark.png'
          : 'assets/images/logo_ar_light.png';
    } else {
      return isDark
          ? 'assets/images/logo_en_dark.png'
          : 'assets/images/logo_en_light.png';
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
                "select_language".tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              trailing: context.locale.languageCode == 'en'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                await context.setLocale(const Locale('en', 'US'));
                await localeProvider.setLocale(const Locale('en'));
                if (mounted) Navigator.pop(this.context);
              },
            ),
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: const Text('العربية'),
              trailing: context.locale.languageCode == 'ar'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                await context.setLocale(const Locale('ar', 'EG'));
                await localeProvider.setLocale(const Locale('ar'));
                if (mounted) Navigator.pop(this.context);
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
          SnackBar(content: Text('biometrics_not_available'.tr())),
        );
      }
      return;
    }

    final bool success = await securityService.authenticate(
      reason: "login_with_biometrics".tr(),
    );

    if (success) {
      await authProvider.loadSavedAuth();
      if (authProvider.isAuthenticated && mounted) {
        final userRole =
            authProvider.userType?.name.toLowerCase() ?? 'customer';
        final user = authProvider.user;
        final String? tier = user?.subscriptionTier?.name.toUpperCase();
        NavigationService.navigateToHomeBasedOnRole(
          context,
          userRole,
          tier: tier,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('enable_biometrics_message'.tr())),
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
          final userRole =
              authProvider.userType?.name.toLowerCase() ?? 'customer';
          final user = authProvider.user;
          final String? tier = user?.subscriptionTier?.name.toUpperCase();
          NavigationService.navigateToHomeBasedOnRole(
            context,
            userRole,
            tier: tier,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('invalid_email_password'.tr())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    : [
                        AppColors.white,
                        AppColors.creamyBackground.withValues(alpha:0.5),
                      ],
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
                                labelText: "email".tr(),
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "email_is_required".tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "password".tr(),
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "password_is_required".tr();
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
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: Text("forgot_password".tr()),
                        ),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: "sign_in".tr(),
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
                        label: Text("login_with_biometrics".tr()),
                      ),

                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${"don_t_have_an_account_sign_up".tr().split('?')[0]}?',
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signup'),
                            child: Text("sign_up".tr()),
                          ),
                        ],
                      ),
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
}
