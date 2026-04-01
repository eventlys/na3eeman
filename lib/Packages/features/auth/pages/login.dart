import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Helpers/login_helper.dart';
import '../../../../Services/ui/navigation_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../Providers/app_providers.dart';
import '../../../../Packages/Core/utils/helpers/themes_helpers.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Models/auth/user_model.dart';
import '../../../../Models/auth/owner_profile.dart';
import '../../../../Models/auth/barber_profile.dart';
import '../../../../core/enums/owner_enums.dart';
import '../../../../Services/enums/gender.dart' as g;
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginHelper _loginHelper = LoginHelper();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _rememberMe = false;
  int _selectedTab = 0; // 0 = Sign In, 1 = Sign Up

  // Testing: selected gender for quick access
  String _selectedGender = 'male';

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      setState(() => _errorMessage = '');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        final userRole =
            authProvider.userType?.name.toLowerCase() ?? 'customer';
            
        // ── Connect user gender to the Theme engine dynamically ──
        final genderStr = authProvider.userGender?.name.toLowerCase() ?? 'male';
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        themeProvider.setGender(genderStr == 'female' ? UserGender.female : UserGender.male);
        
        NavigationService.navigateToHomeBasedOnRole(context, userRole);
      } else if (mounted) {
        setState(() => _errorMessage =
            authProvider.error ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _loginHelper.handleLoginError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Logo / Scissors Icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.almostBlack600 : AppColors.cream200,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/images/main_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Welcome Title
                    Text('na3eeman'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('professional_grooming_services'.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.cream600 : AppColors.almostBlack400,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Tab Switcher (Sign in / Sign up) simplified
                    Row(
                      children: [
                        _buildTab('SIGN IN', 0, isDark),
                        _buildTab('SIGN UP', 1, isDark),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    Text('email_address'.tr(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    Text('password'.tr(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter password' : null,
                    ),

                    // Error message
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Forgot Password & Remember me
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                activeColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('remember_me'.tr()),
                          ],
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: Text('forgot_password'.tr()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Sign In Button
                    PrimaryButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 24),

                    // OR divider
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or'.tr()),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Login Mock
                    // SecondaryButton(
                    //   text: 'Continue with Phone',
                    //   icon: Icons.phone_android_rounded,
                    //   onPressed: () {}, // Planned feature
                    // ),

                    const SizedBox(height: 32),

                    // Sign up prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/signup'),
                          child: Text('sign_up'.tr(),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    _buildTestingSection(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/signup');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : AppColors.almostBlack300,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
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
        // Divider with label
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark ? AppColors.almostBlack600 : AppColors.cream600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('quick_access_fast_login'.tr(),
                style: TextStyle(
                  color: AppColors.almostBlack400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark ? AppColors.almostBlack600 : AppColors.cream600,
              ),
            ),
          ],
        ),
        // User Gender Toggle
        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(8),
            isSelected: [_selectedGender == 'male', _selectedGender == 'female'],
            onPressed: (index) {
              setState(() {
                _selectedGender = index == 0 ? 'male' : 'female';
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('male'.tr()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('female'.tr()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // User Type buttons
        Text('fast_login_as'.tr(),
          style: TextStyle(
            color: isDark ? AppColors.cream200 : AppColors.almostBlack600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: 'Customer',
                icon: Icons.person_outline_rounded,
                role: 'customer',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoleButton(
                label: 'employee'.tr(),
                icon: Icons.content_cut_rounded,
                role: 'employee',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: 'Provider',
                icon: Icons.storefront_rounded,
                role: 'owner',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoleButton(
                label: 'admin'.tr(),
                icon: Icons.admin_panel_settings_outlined,
                role: 'admin',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: 'Intern',
                icon: Icons.school_outlined,
                role: 'intern',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoleButton(
                label: 'Receptionist',
                icon: Icons.support_agent_outlined,
                role: 'receptionist',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: 'Owner',
                sub: 'Artisan',
                icon: Icons.store_mall_directory_outlined,
                role: 'owner',
                baseUsername: 'owner1',
                tier: OwnerSubscriptionTier.artisan,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoleButton(
                label: 'Owner',
                sub: 'Studio',
                icon: Icons.storefront_rounded,
                role: 'owner',
                baseUsername: 'owner2',
                tier: OwnerSubscriptionTier.studio,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: 'Owner',
                sub: 'Elite',
                icon: Icons.workspace_premium_outlined,
                role: 'owner',
                baseUsername: 'owner3',
                tier: OwnerSubscriptionTier.elite,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildRoleButton(
                label: 'Owner',
                sub: 'Empire',
                icon: Icons.domain_rounded,
                role: 'owner',
                baseUsername: 'owner4',
                tier: OwnerSubscriptionTier.empire,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMockButton(String label, Color color, OwnerSubscriptionTier tier, OwnerType type, {bool expired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _quickAccessOwner(label, tier, type, expired),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required IconData icon,
    required String role,
    required bool isDark,
    String? sub,
    String? baseUsername,
    OwnerSubscriptionTier? tier,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (tier != null) {
            _quickAccessOwner(
              'Owner (${sub ?? tier.name})', 
              tier, 
              OwnerType.employeeOwner, 
              false
            );
          } else {
            _quickAccessRole(role, baseUsername: baseUsername);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.almostBlack500 : AppColors.cream400,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.cream200 : AppColors.almostBlack600,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _quickAccessRole(String role, {String? baseUsername}) {
    String prefix = _selectedGender == 'female' ? 'female_' : '';
    String email = '${prefix}customer1@test.com';
    
    if (baseUsername != null) {
      email = '$prefix$baseUsername@test.com';
    } else {
      switch (role.toLowerCase()) {
        case 'admin':
          email = 'admin@na3eeman.com';
          break;
        case 'owner':
          email = '${prefix}owner1@test.com';
          break;
        case 'employee':
          email = '${prefix}barber1@test.com';
          break;
        case 'intern':
          email = '${prefix}intern1@test.com';
          break;
        case 'receptionist':
          email = '${prefix}receptionist1@test.com';
          break;
      }
    }
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'Password123!';
    });
    // Trigger standard login
    _handleLogin();
  }

  void _quickAccessOwner(String label, OwnerSubscriptionTier tier, OwnerType type, bool expired) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final gender = _selectedGender == 'female' ? g.Gender.female : g.Gender.male;
    
    final user = User(
      id: 888,
      email: 'mock_${tier.name}_${_selectedGender}@test.com',
      username: 'mock_owner',
      firstName: gender == g.Gender.male ? 'Ahmed' : 'Sarah',
      lastName: 'Wilson',
      role: UserRole.owner,
      gender: gender,
      location: 'Amman, Jordan',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final barber = BarberProfile(
      id: 888,
      barberId: 888,
      bio: 'Mock profile for testing',
      specialties: 'All',
      hasAccess: true,
      avgRating: 4.8,
    );

    final owner = OwnerProfile(
      id: 888,
      barberProfileId: 888,
      ownerType: type,
      isSubscribed: !expired,
      subscriptionTier: tier,
      subscriptionStartDate: DateTime.now().subtract(const Duration(days: 30)),
      subscriptionEndDate: expired 
          ? DateTime.now().subtract(const Duration(days: 1)) 
          : DateTime.now().add(const Duration(days: 30)),
    );

    authProvider.debugSetOwnerProfile(
      user: user,
      barberProfile: barber,
      ownerProfile: owner,
    );

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setGender(gender == g.Gender.female ? UserGender.female : UserGender.male);

    NavigationService.navigateToHomeBasedOnRole(context, 'owner');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as $label')),
    );
  }
}
