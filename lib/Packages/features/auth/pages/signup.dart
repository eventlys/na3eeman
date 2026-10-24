import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Packages/Core/utils/validators.dart';
import '../../../../Packages/Core/widgets/password_strength_indicator.dart';
import '../../../../Routes/route_names.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = 'male';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _autoValidate = false;

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
          ? 'assets/logos/logo_ar_dark.png'
          : 'assets/logos/logo_ar_light.png';
    } else {
      return isDark
          ? 'assets/logos/logo_en_dark.png'
          : 'assets/logos/logo_en_light.png';
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

  Future<void> _handleSignup() async {
    setState(() {
      _autoValidate = true;
    });

    if (_formKey.currentState!.validate()) {
      // Route through the AuthProvider's shared AuthService so the UI layer
      // never constructs a repository directly.
      final authService = context.read<AuthProvider>().authService;

      setState(() => _isLoading = true);
      try {
        final response = await authService.signup(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          gender: _selectedGender,
          password: _passwordController.text,
          role: 'customer', // Default role as requested
        );

        if (mounted &&
            (response['user'] != null || response['email'] != null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signup successful! Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, RouteNames.login);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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
                        AppColors.creamyBackground.withValues(alpha: 0.5),
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

                      const SizedBox(height: 32),

                      Text(
                        "sign_up".tr(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.white
                              : AppColors.almostBlack700,
                        ),
                      ),
                      Text(
                        "Join as a Customer", // Indicated default role
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.almostBlack300,
                        ),
                      ),
                      const SizedBox(height: 48),

                      Form(
                        key: _formKey,
                        autovalidateMode: _autoValidate
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration: InputDecoration(
                                      hintText: 'First Name',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    validator: (v) =>
                                        AppValidators.validateName(v),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Last Name',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    validator: (v) =>
                                        AppValidators.validateName(v),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                              validator: (v) => AppValidators.validateEmail(v),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "phone_number".tr(),
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (v) => AppValidators.validatePhone(v),
                            ),
                            const SizedBox(height: 16),

                            // Gender Chips instead of Dropdown
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Male'),
                                    selected: _selectedGender == 'male',
                                    selectedColor: Colors.blue.withValues(
                                      alpha: 0.2,
                                    ),
                                    checkmarkColor: Colors.blue,
                                    labelStyle: TextStyle(
                                      color: _selectedGender == 'male'
                                          ? Colors.blue
                                          : null,
                                      fontWeight: _selectedGender == 'male'
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                    onSelected: (val) => setState(
                                      () => _selectedGender = 'male',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChoiceChip(
                                    label: const Text('Female'),
                                    selected: _selectedGender == 'female',
                                    selectedColor: Colors.pink.withValues(
                                      alpha: 0.2,
                                    ),
                                    checkmarkColor: Colors.pink,
                                    labelStyle: TextStyle(
                                      color: _selectedGender == 'female'
                                          ? Colors.pink
                                          : null,
                                      fontWeight: _selectedGender == 'female'
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                    onSelected: (val) => setState(
                                      () => _selectedGender = 'female',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
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
                                        ? Icons.visibility_off
                                        : Icons.visibility,
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
                              validator: (v) =>
                                  AppValidators.validatePassword(v),
                            ),
                            const SizedBox(height: 8),
                            PasswordStrengthIndicator(
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: "confirm_password".tr(),
                                prefixIcon: const Icon(
                                  Icons.lock_reset_rounded,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Confirm password is required';
                                }
                                if (v != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: "sign_up".tr(),
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleSignup,
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("back_to_login".tr().split('?')[0]),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("sign_in".tr()),
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
