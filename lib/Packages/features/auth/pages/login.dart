import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../helpers/login_helper.dart';
import '../../../../Services/ui/navigation_service.dart';
import '../../../Core/backgrounds/floating_bg.dart';
import '../../../Core/backgrounds/bg_icon.dart';
import '../../../Core/themes/button_theme.dart';
import '../../../Core/widgets/common/text_links.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginHelper _loginHelper = LoginHelper();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        final userRole = authProvider.userType?.name.toLowerCase() ?? 'customer';
        NavigationService.navigateToHomeBasedOnRole(context, userRole);
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.error ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _loginHelper.handleLoginError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSocialLogin(String provider, BuildContext context) async {
    _loginHelper.getSocialLoginConfig(provider);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final socialData = {
        'email': 'social_$provider@example.com',
        'name': '$provider User',
        'social_id': '${provider}_123456',
      };

      final success = await authProvider.login(
        socialProvider: provider,
        socialData: socialData,
      );

      if (success && mounted) {
        final userRole = authProvider.userType?.name.toLowerCase() ?? 'customer';
        NavigationService.navigateToHomeBasedOnRole(context, userRole);
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Social login failed. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _loginHelper.handleLoginError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleTestLogin(BuildContext context, String role) {
    _loginHelper.getRoleConfig(role);
    NavigationService.navigateToHomeBasedOnRole(context, role);
  }

  Widget _buildRoleSelector() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.borderLight.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'customer',
          isExpanded: true,
          items: _loginHelper.getAvailableRoles().map((String role) {
            final config = _loginHelper.getRoleConfig(role);
            return DropdownMenuItem<String>(
              value: role,
              child: Row(
                children: [
                  Icon(config['icon'], color: AppColor.lightTextHint),
                  const SizedBox(width: 8),
                  Text(
                    config['name'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.lightText,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // Role selection for testing
          },
        ),
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Quick Test:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _loginHelper.getAvailableRoles().map((role) {
            final config = _loginHelper.getRoleConfig(role);
            final roleColor = _getRoleColor(role, isDark);
            return OutlinedButton(
              onPressed: () => _handleTestLogin(context, role),
              style: OutlinedButton.styleFrom(
                foregroundColor: roleColor,
                side: BorderSide(color: roleColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(config['icon'], size: 16),
                  const SizedBox(width: 4),
                  Text(role.toUpperCase()),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getRoleColor(String role, bool isDark) {
    switch (role) {
      case 'barber':
        return isDark ? AppColor.darkBarber : AppColor.lightBarber;
      case 'manager':
        return isDark ? AppColor.darkManager : AppColor.lightManager;
      case 'assistant':
        return isDark ? AppColor.darkAssistant : AppColor.lightAssistant;
      case 'receptionist':
        return isDark ? AppColor.darkReceptionist : AppColor.lightReceptionist;
      default:
        return isDark ? AppColor.darkPrimary : AppColor.primary;
    }
  }

  Widget _buildSocialButton(String provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getSocialConfig(provider, isDark);
    return _SocialButton(
      onTap: () => _handleSocialLogin(provider, context),
      icon: config['icon'],
      color: config['color'],
      iconColor: config['iconColor'],
      borderColor: config['borderColor'],
    );
  }

  Map<String, dynamic> _getSocialConfig(String provider, bool isDark) {
    switch (provider) {
      case 'Google':
        return {
          'icon': Icons.g_mobiledata,
          'color': isDark ? AppColor.darkCard : AppColor.light,
          'iconColor': isDark ? AppColor.darkText : AppColor.lightError,
          'borderColor': isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
        };
      case 'Facebook':
        return {
          'icon': Icons.facebook,
          'color': isDark ? AppColor.darkInfo : AppColor.lightInfo,
          'iconColor': AppColor.light,
          'borderColor': Colors.transparent,
        };
      case 'Apple':
        return {
          'icon': Icons.apple,
          'color': isDark ? AppColor.darkText : AppColor.lightText,
          'iconColor': isDark ? AppColor.darkBackground : AppColor.lightBackground,
          'borderColor': isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
        };
      default:
        return {
          'icon': Icons.login,
          'color': isDark ? AppColor.darkCard : AppColor.lightCard,
          'iconColor': isDark ? AppColor.darkText : AppColor.lightText,
          'borderColor': isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
        };
    }
  }

  Widget _buildFloatingIcons() {
    return Stack(
      children: [
        // Top left icon - Scissors
        BgIcon(
          iconPath: AppImages.scissors1,
          blurLevel: 2.0,
          size: 80,
          rotationDegree: 15,
          animationDuration: const Duration(seconds: 8),
          startPosition: const Offset(-20, -20),
          endPosition: const Offset(-10, -10),
        ),
        // Top right icon - Comb
        BgIcon(
          iconPath: AppImages.comb,
          blurLevel: 1.5,
          size: 60,
          rotationDegree: -10,
          animationDuration: const Duration(seconds: 6),
          startPosition: const Offset(20, -30),
          endPosition: const Offset(15, -20),
        ),
        // Bottom left icon - Razor
        BgIcon(
          iconPath: AppImages.razor,
          blurLevel: 2.5,
          size: 70,
          rotationDegree: 8,
          animationDuration: const Duration(seconds: 10),
          startPosition: const Offset(-30, 30),
          endPosition: const Offset(-25, 25),
        ),
        // Bottom right icon - Mirror
        BgIcon(
          iconPath: AppImages.mirror,
          blurLevel: 1.8,
          size: 90,
          rotationDegree: -12,
          animationDuration: const Duration(seconds: 7),
          startPosition: const Offset(25, 25),
          endPosition: const Offset(20, 20),
        ),
        // Center icon - Chair
        BgIcon(
          iconPath: AppImages.chair,
          blurLevel: 3.0,
          size: 50,
          rotationDegree: 20,
          animationDuration: const Duration(seconds: 9),
          startPosition: const Offset(0, 0),
          endPosition: const Offset(5, 5),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background with floating objects
          FloatingBackground(
            objectCount: 8,
            objectType: 'circles',
            colors: [
              AppColor.primary.withValues(alpha: 0.2),
              AppColor.secondary.withValues(alpha: 0.15),
            ],
            minSize: 40.0,
            maxSize: 120.0,
            child: Container(),
          ),
          
          // Floating icons layer
          _buildFloatingIcons(),

          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Image.asset(
                    AppImages.logo,
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(
                        color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColor.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColor.primary),
                      ),
                      prefixIcon: Icon(Icons.email, 
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
                      filled: true,
                      fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    onChanged: (value) => _clearError(),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColor.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColor.primary),
                      ),
                      prefixIcon: Icon(Icons.lock, 
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    validator: _validatePassword,
                    onChanged: (value) => _clearError(),
                    onFieldSubmitted: (value) => _handleLogin(context),
                  ),

                  // Role selector for testing
                  if (_loginHelper.isDebugMode()) _buildRoleSelector(),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColor.darkError.withValues(alpha: 0.1) : AppColor.lightError.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColor.darkError.withValues(alpha: 0.3) : AppColor.lightError.withValues(alpha: 0.3)
                        ),
                      ),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: isDark ? AppColor.darkError : AppColor.lightError,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextLink(
                      link: '/forgot-password',
                      text: 'Forgot Password?',
                      color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: size.width * 0.8,
                    child: PrimaryButton(
                      text: 'Login',
                      onPressed: _isLoading ? null : () => _handleLogin(context),
                      showLeftIcon: true,
                      leftIcon: Icons.login,
                      isLoading: _isLoading,
                      buttonColor: AppColor.primary,
                      textColor: AppColor.light,
                    ),
                  ),

                  // Sign up section
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                      TextLink(
                        link: '/signup',
                        text: 'Signup',
                        color: AppColor.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton('Google'),
                      const SizedBox(width: 20),
                      _buildSocialButton('Facebook'),
                      const SizedBox(width: 20),
                      _buildSocialButton('Apple'),
                    ],
                  ),

                  // Quick test buttons for different roles
                  if (_loginHelper.isDebugMode()) _buildTestButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _passwordController.removeListener(_clearError);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color? borderColor;

  const _SocialButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColor.dark : AppColor.lightText).withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}
