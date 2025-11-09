/*
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

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Logger _logger = Logger();
  final AuthService _authService = AuthService();

  LoginPage({super.key});

  Future<void> _handleLogin(BuildContext context) async {
    final currentContext = context;

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      final userRole = response['user']['role'];

      if (currentContext.mounted) {
        NavigationService.navigateToHomeBasedOnRole(currentContext, userRole);
      }

    } catch (e) {
      _logger.e('Login error: $e');
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handleSocialLogin(String provider) {
    _logger.d('$provider LogIn clicked');
    // Implement social LogIn logic here
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
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
              CustomTextField(
                placeholder: 'Password',
                type: TextFieldType.password,
                boxSize: BoxSize.full,
                controller: _passwordController,
                onChanged: (value) {
                  _logger.d('Password: $value');
                },
              ),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerRight,
                child: TextLink(
                  link: '/forgot-password',
                  text: 'Forgot Password?',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),
              CustomNeumorphicButton(
                color: Colors.blue.shade100,
                width: size.width * 0.8,
                text: 'Login',
                showText: true,
                leftIcon: Icons.login,
                showLeftIcon: true,
                showRightIcon: false,
                isActive: true,
                onTap: () => _handleLogin(context),
              ),

              // Sign up section
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const TextLink(
                    link: '/signup',
                    text: 'Signup',
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google button
                  _SocialButton(
                    onTap: () => _handleSocialLogin('Google'),
                    icon: Icons.g_mobiledata,
                    color: Colors.white,
                    iconColor: Colors.red,
                    borderColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 20),

                  // Facebook button
                  _SocialButton(
                    onTap: () => _handleSocialLogin('Facebook'),
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 20),

                  // Apple button
                  _SocialButton(
                    onTap: () => _handleSocialLogin('Apple'),
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
    required this.onTap,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.borderColor,
  });

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
*/

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
// import '../../Services/auth_service.dart';
import '../../Services/navigation_service.dart'; // Uncomment this
import '../../components/common/fields/text_field.dart';
import '../../Utils/text_field_types.dart';
import '../../Utils/box_sizes.dart';
import '../../components/common/buttons/custom_button.dart';
import '../../components/common/links/text_links.dart';
import '../../features/Backgrounds/floating_bg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Logger _logger = Logger();
  // final AuthService _authService = AuthService();

  // Add this for testing
  String _selectedRole = 'customer';
  final List<String> _availableRoles = ['customer', 'barber', 'owner', 'admin'];

  Future<void> _handleLogin(BuildContext context) async {
    final currentContext = context;

    try {
      // For testing: Use selected role instead of API response
      final userRole = _selectedRole; // Use dropdown selection

      // For production: Use actual API response
      // final response = await _authService.login(
      //   _emailController.text,
      //   _passwordController.text,
      // );
      // final userRole = response['user']['role'];

      if (currentContext.mounted) {
        NavigationService.navigateToHomeBasedOnRole(currentContext, userRole);
      }

    } catch (e) {
      _logger.e('Login error: $e');
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }

  // Simple login for testing specific roles
  void _handleTestLogin(BuildContext context, String role) {
    _logger.d('Test login as $role');
    NavigationService.navigateToHomeBasedOnRole(context, role);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
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
              CustomTextField(
                placeholder: 'Password',
                type: TextFieldType.password,
                boxSize: BoxSize.full,
                controller: _passwordController,
                onChanged: (value) {
                  _logger.d('Password: $value');
                },
              ),

              // Add role selection dropdown for testing
              if (const bool.fromEnvironment('DEBUG', defaultValue: true))
                _buildRoleSelector(),

              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerRight,
                child: TextLink(
                  link: '/forgot-password',
                  text: 'Forgot Password?',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),
              CustomNeumorphicButton(
                color: Colors.blue.shade100,
                width: size.width * 0.8,
                text: 'Login',
                showText: true,
                leftIcon: Icons.login,
                showLeftIcon: true,
                showRightIcon: false,
                isActive: true,
                onTap: () => _handleLogin(context),
              ),

              // Sign up section
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const TextLink(
                    link: '/signup',
                    text: 'Signup',
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                    onTap: () => _handleSocialLogin('Google'),
                    icon: Icons.g_mobiledata,
                    color: Colors.white,
                    iconColor: Colors.red,
                    borderColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 20),
                  _SocialButton(
                    onTap: () => _handleSocialLogin('Facebook'),
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 20),
                  _SocialButton(
                    onTap: () => _handleSocialLogin('Apple'),
                    icon: Icons.apple,
                    color: Colors.black,
                    iconColor: Colors.white,
                  ),
                ],
              ),

              // Quick test buttons for different roles
              if (const bool.fromEnvironment('DEBUG', defaultValue: true))
                _buildTestButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          items: _availableRoles.map((String role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(
                'Test as: ${role.toUpperCase()}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTestButtons(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Quick Test:',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableRoles.map((role) {
            return CustomNeumorphicButton(
              color: _getRoleColor(role),
              width: 100,
              text: role.toUpperCase(),
              showText: false,
              leftIcon: _getRoleIcon(role),
              showLeftIcon: true,
              showRightIcon: false,
              isActive: true,
              onTap: () => _handleTestLogin(context, role),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'customer':
        return Colors.green.shade100;
      case 'barber':
        return Colors.blue.shade100;
      case 'owner':
        return Colors.orange.shade100;
      case 'admin':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'customer':
        return Icons.person;
      case 'barber':
        return Icons.content_cut;
      case 'owner':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void _handleSocialLogin(String provider) {
    _logger.d('$provider LogIn clicked');
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

