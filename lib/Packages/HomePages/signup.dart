import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../Services/auth_service.dart';
import '../../Services/navigation_service.dart';
import '../../components/common/fields/text_field.dart';
import '../../Utils/text_field_types.dart';
import '../../Utils/box_sizes.dart';
import '../../components/common/buttons/custom_button.dart';
import '../../components/common/links/text_links.dart';
import '../../features/Backgrounds/floating_bg.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Logger _logger = Logger();
  final AuthService _authService = AuthService();

  String? _selectedGender;
  String? _selectedRole;

  Future<void> _handleSignup(BuildContext context) async {
    final currentContext = context;

    // Basic validation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }

    if (_selectedRole == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    try {
      // Now using the signup method instead of login
      final response = await _authService.signup(
        _firstNameController.text,
        _secondNameController.text,
        _emailController.text,
        _phoneController.text,
        _selectedGender!,
        _passwordController.text,
        _selectedRole!,
      );

      final userRole = response['user']['role'];

      if (currentContext.mounted) {
        NavigationService.navigateToHomeBasedOnRole(currentContext, userRole);
      }

    } catch (e) {
      _logger.e('Signup error: $e');
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handleSocialSignup(String provider) {
    _logger.d('$provider signup clicked');
    // Implement social signup logic here
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: FloatingBackground(
        objectCount: 8,
        objectType: 'circles',
        colors: [
          Colors.blue.withValues(alpha: 0.2),
          Colors.purple.withValues(alpha: 0.2),
          Colors.teal.withValues(alpha: 0.2),
          Colors.orange.withValues(alpha: 0.2),
          Colors.teal.withValues(alpha: 0.2),
          Colors.orange.withValues(alpha: 0.2),
          Colors.blue.withValues(alpha: 0.2),
          Colors.purple.withValues(alpha: 0.2),
        ],
        minSize: 40.0,
        maxSize: 120.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // First Name
                CustomTextField(
                  placeholder: 'First Name',
                  type: TextFieldType.text, // Changed from TextFieldType.name to TextFieldType.text
                  boxSize: BoxSize.full,
                  controller: _firstNameController,
                  onChanged: (value) {
                    _logger.d('First Name: $value');
                  },
                ),

                const SizedBox(height: 16),

                // Second Name
                CustomTextField(
                  placeholder: 'Second Name',
                  type: TextFieldType.text, // Changed from TextFieldType.name to TextFieldType.text
                  boxSize: BoxSize.full,
                  controller: _secondNameController,
                  onChanged: (value) {
                    _logger.d('Second Name: $value');
                  },
                ),

                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  placeholder: 'Email Address',
                  type: TextFieldType.email,
                  boxSize: BoxSize.full,
                  controller: _emailController,
                  onChanged: (value) {
                    _logger.d('Email: $value');
                  },
                ),

                const SizedBox(height: 16),

                // Phone Number
                CustomTextField(
                  placeholder: 'Phone Number',
                  type: TextFieldType.phone,
                  boxSize: BoxSize.full,
                  controller: _phoneController,
                  onChanged: (value) {
                    _logger.d('Phone: $value');
                  },
                ),

                const SizedBox(height: 16),

                // Gender Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      hint: Text(
                        'Select Gender',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                      isExpanded: true,
                      items: ['Male', 'Female', 'Other']
                          .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
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

                const SizedBox(height: 16),

                // Role Selection
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      hint: Text(
                        'Select Role',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                      isExpanded: true,
                      items: ['customer', 'barber', 'owner', 'admin']
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role[0].toUpperCase() + role.substring(1)),
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

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  placeholder: 'Password',
                  type: TextFieldType.password,
                  boxSize: BoxSize.full,
                  controller: _passwordController,
                  onChanged: (value) {
                    _logger.d('Password: $value');
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  placeholder: 'Confirm Password',
                  type: TextFieldType.password,
                  boxSize: BoxSize.full,
                  controller: _confirmPasswordController,
                  onChanged: (value) {
                    _logger.d('Confirm Password: $value');
                  },
                ),

                const SizedBox(height: 30),

                // Signup Button
                CustomNeumorphicButton(
                  color: Colors.blue.shade100,
                  width: size.width * 0.8,
                  text: 'Sign Up',
                  showText: true,
                  leftIcon: Icons.person_add,
                  showLeftIcon: true,
                  showRightIcon: false,
                  isActive: true,
                  onTap: () => _handleSignup(context),
                ),

                // Back to login section
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const TextLink(
                      link: '/login',
                      text: 'Back to Login',
                      color: Colors.blue,
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
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google button
                    _SocialButton(
                      onTap: () => _handleSocialSignup('Google'),
                      icon: Icons.g_mobiledata,
                      color: Colors.white,
                      iconColor: Colors.red,
                      borderColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 20),

                    // Facebook button
                    _SocialButton(
                      onTap: () => _handleSocialSignup('Facebook'),
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      iconColor: Colors.white,
                    ),
                    const SizedBox(width: 20),

                    // Apple button
                    _SocialButton(
                      onTap: () => _handleSocialSignup('Apple'),
                      icon: Icons.apple,
                      color: Colors.black,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final Color? borderColor;

  const _SocialButton({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              color: Colors.grey.withValues(alpha: 0.3),
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
