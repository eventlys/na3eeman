import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../../Helpers/registration_helper.dart';
import '../../../../Helpers/error_handler.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Providers/app_providers.dart';
// import '../../../../core/enums/app_enums.dart';
import 'package:provider/provider.dart';
import '../../../../Packages/Core/utils/helpers/themes_helpers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/api/auth_service.dart';
import '../../../../Services/repositories/auth_repository.dart';
import '../../../../Services/ui/navigation_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';
import '../../../Core/widgets/common/text_links.dart';
import 'package:easy_localization/easy_localization.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Logger _logger = Logger();

  // Updated service initialization
  late final AuthService _authService;
  late final AuthProvider _authProvider;
  final SocialRegistrationHelper _socialHelper = SocialRegistrationHelper();

  String? _selectedGender;
  String? _selectedRole;

  // Focus nodes for text fields
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize services with dependency injection
    final apiService = ApiService();
    final authRepository = AuthRepository(apiService);
    _authService = AuthService(authRepository);
    _authProvider = AuthProvider(authRepository: authRepository);
  }

  Future<void> _handleSignup(BuildContext context) async {
    final currentContext = context;

    // Basic validation
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Please enter your first and last name'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }

    // Password strength validation (Matches Backend rules)
    final password = _passwordController.text;
    if (password.length < 8) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 8 characters long'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one number'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one uppercase letter'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one lowercase letter'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Password must contain at least one special character'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }

    // Phone validation (Matches Backend \d{9,15})
    final phone = _phoneController.text;
    if (phone.isNotEmpty && (phone.length < 9 || phone.length > 15)) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Phone number must be between 9 and 15 digits'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Please select a gender'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('Please select a role'),
          backgroundColor: AppColor.lightError,
        ),
      );
      return;
    }

    try {
      // Use the updated signup method from AuthService
      final response = await _authService.signup(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        gender: _selectedGender!,
        password: _passwordController.text,
        role: _selectedRole!,
      );

      final bool isSuccess = response['user'] != null || response['email'] != null;

      if (isSuccess) {
        final userRole = response['role'] ?? response['user']?['role'] ?? _selectedRole ?? 'customer';
        final hasTokens = response['access'] != null;
        final genderStr = response['gender'] ?? response['user']?['gender'] ?? _selectedGender ?? 'MALE';

        if (currentContext.mounted) {
          final themeProvider = Provider.of<ThemeProvider>(currentContext, listen: false);
          themeProvider.setGender(genderStr.toString().toLowerCase() == 'female' ? UserGender.female : UserGender.male);

          if (!hasTokens) {
            try {
              final loginResponse = await _authService.login(
                _emailController.text,
                _passwordController.text,
              );
              if (loginResponse['access'] != null) {
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  SnackBar(
                    content: Text('Signup successful! Logging you in...'),
                    backgroundColor: AppColor.lightSuccess,
                  ),
                );
                NavigationService.navigateToHomeBasedOnRole(currentContext, userRole.toString());
                return;
              }
            } catch (e) {
              _logger.e('Auto-login failed: $e');
            }
          }
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text(hasTokens ? 'Signup successful!' : 'Signup successful! Please log in.'),
              backgroundColor: AppColor.lightSuccess,
            ),
          );
          
          if (hasTokens) {
            NavigationService.navigateToHomeBasedOnRole(currentContext, userRole);
          } else {
            Navigator.pushReplacementNamed(currentContext, '/login');
          }
        }
      } else {
        final errorMessage = response['message'] ?? 'Signup failed';
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColor.lightError,
            ),
          );
        }
      }

    } catch (e) {
      _logger.e('Signup error: $e');
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(e is AppError ? e.message : 'Signup failed: ${e.toString()}'),
            backgroundColor: AppColor.lightError,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialSignup(String provider) async {
    try {
      _logger.d('$provider signup clicked');

      // Get mock social data
      final mockSocialData = await _getMockSocialData(provider);

      // Use the unified social authentication
      final response = await _authService.handleSocialAuthentication(
        provider: provider,
        socialData: mockSocialData,
        selectedRole: _selectedRole,
        selectedGender: _selectedGender,
      );

      if (response['user'] != null && context.mounted) {
        final userRole = response['user']['role'] ?? 'customer';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider signup successful!'),
            backgroundColor: AppColor.lightSuccess,
          ),
        );
        NavigationService.navigateToHomeBasedOnRole(context, userRole);
      } else if (context.mounted) {
        final errorMessage = response['message'] ?? '$provider signup failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColor.lightError,
          ),
        );
      }
    } catch (e) {
      _logger.e('Social signup error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider signup failed: ${e.toString()}'),
            backgroundColor: AppColor.lightError,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _getMockSocialData(String provider) async {
    switch (provider.toLowerCase()) {
      case 'google':
        return {
          'id': 'google_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'user@gmail.com',
          'displayName': 'Google User',
          'givenName': 'Google',
          'familyName': 'User',
          'photoUrl': 'https://example.com/avatar.jpg',
        };
      case 'facebook':
        return {
          'id': 'facebook_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'user@facebook.com',
          'name': 'Facebook User',
          'first_name': 'Facebook',
          'last_name': 'User',
          'picture': {
            'data': {'url': 'https://example.com/avatar.jpg'}
          },
        };
      case 'apple':
        return {
          'id': 'apple_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'user@apple.com',
          'fullName': {
            'givenName': 'Apple',
            'familyName': 'User',
          },
          'givenName': 'Apple',
          'familyName': 'User',
        };
      default:
        return {'id': 'unknown', 'email': 'user@example.com', 'name': 'Social User'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthScaffold(
      title: 'Create Account',
      subtitle: 'Join us today and get started',
      showBackButton: true,
      child: Column(
        children: [
          const SizedBox(height: 16),

          // First Name
          TextFormField(
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            decoration: const InputDecoration(
              hintText: 'First Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v!.isEmpty ? 'Enter first name' : null,
          ),

          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            decoration: const InputDecoration(
              hintText: 'Last Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v!.isEmpty ? 'Enter last name' : null,
          ),

          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'email_address'.tr(),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) => v!.isEmpty ? 'Enter email' : null,
          ),

          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'phone_number'.tr(),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Gender Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColor.borderDark : AppColor.borderLight),
                    color: isDark ? AppColor.darkCard : AppColor.lightCard,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: Text('gender'.tr(),
                        style: TextStyle(
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                          fontSize: 16,
                        ),
                      ),
                      isExpanded: true,
                      dropdownColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                      icon: ImageIcon(
                        AssetImage(AppImages.arrow_red),
                        color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Row(
                          children: [
                            ImageIcon(
                              AssetImage(gender == 'Male'
                                ? AppImages.avatar_male
                                : gender == 'Female'
                                  ? AppImages.avatar_female
                                  : AppImages.admin),
                              color: isDark ? AppColor.darkText : AppColor.lightText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              gender,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? AppColor.darkText : AppColor.lightText,
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                        _logger.d('Gender: $value');
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Role Dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColor.borderDark : AppColor.borderLight),
                    color: isDark ? AppColor.darkCard : AppColor.lightCard,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      hint: Text('role'.tr().tr(),
                        style: TextStyle(
                          color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                          fontSize: 16,
                        ),
                      ),
                      isExpanded: true,
                      dropdownColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                      icon: ImageIcon(
                        AssetImage(AppImages.arrow_red),
                        color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                      ),
                      items: ['customer', 'barber', 'owner', 'receptionist', 'intern']
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            ImageIcon(
                              AssetImage(role == 'barber'
                                ? AppImages.scissors
                                : role == 'owner'
                                  ? AppImages.admin
                                  : AppImages.staff),
                              color: isDark ? AppColor.darkText : AppColor.lightText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColor.darkText : AppColor.lightText,
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                        _logger.d('Role: $value');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'password'.tr(),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (v) => v!.isEmpty ? 'Enter password' : null,
          ),

          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'confirm_password'.tr(),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (v) => v!.isEmpty ? 'Confirm your password' : null,
          ),

          const SizedBox(height: 30),

          // Signup Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'Sign Up',
              onPressed: () => _handleSignup(context),
              showLeftIcon: true,
              leftIcon: Icons.person_add, // Keeping Material icon for button
              variant: ButtonVariant.filled,
            ),
          ),

          // Back to login section
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
              TextLink(
                link: '/login',
                text: 'back_to_login'.tr(),
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ],
          ),

          // Social signup section
          const SizedBox(height: 30),
          Text(
            'Or sign up with',
            style: TextStyle(
              color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google button
              _SocialButton(
                onTap: () => _handleSocialSignup('google'),
                imagePath: AppImages.google,
              ),
              const SizedBox(width: 20),

              // Facebook button
              _SocialButton(
                onTap: () => _handleSocialSignup('facebook'),
                imagePath: AppImages.facebook,
              ),
              const SizedBox(width: 20),

              // Apple button
              _SocialButton(
                onTap: () => _handleSocialSignup('apple'),
                imagePath: AppImages.apple,
              ),
            ],
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

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String imagePath;

  const _SocialButton({
    super.key,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColor.darkWithOpacity : Colors.grey.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
