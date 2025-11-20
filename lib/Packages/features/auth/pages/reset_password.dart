import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../helpers/password_helper.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';

class ResetPasswordPage extends StatefulWidget {
  final String resetToken;

  const ResetPasswordPage({super.key, required this.resetToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final PasswordHelper _passwordHelper = PasswordHelper();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _message = '';
  bool _isSuccess = false;
  Map<String, dynamic> _passwordRequirements = {};

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordRequirements);
    _updatePasswordRequirements();
  }

  void _updatePasswordRequirements() {
    setState(() {
      _passwordRequirements = _passwordHelper.getPasswordRequirements(
        _passwordController.text,
      );
    });
  }

  Future<void> _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Passwords do not match';
        _isSuccess = false;
      });
      return;
    }

    // Validate password strength
    final passwordValidation = _passwordHelper.validatePassword(_passwordController.text);
    if (!passwordValidation['isValid']) {
      setState(() {
        _message = passwordValidation['message'];
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resetPassword(
      token: widget.resetToken,
      newPassword: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
      _message = result['message']!;
      _isSuccess = result['success']!;
    });

    if (_isSuccess) {
      // Navigate to login page after successful reset
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Image.asset(
          isMet ? AppImages.tick : AppImages.check,
          width: 16,
          height: 16,
          color: isMet
              ? AppColor.featureCheckLight
              : (isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet
                ? AppColor.featureCheckLight
                : (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary),
            decoration: isMet ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final strength = _passwordRequirements['strength'] ?? 'weak';
    final message = _passwordRequirements['message'] ?? '';
    final requirements = _passwordRequirements['requirements'] ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color strengthColor;
    switch (strength) {
      case 'strong':
        strengthColor = AppColor.featureCheckLight;
        break;
      case 'good':
        strengthColor = AppColor.lightInfo;
        break;
      case 'fair':
        strengthColor = AppColor.lightWarning;
        break;
      case 'weak':
      default:
        strengthColor = AppColor.lightError;
    }

    // Adjust colors for dark theme
    if (isDark) {
      switch (strength) {
        case 'strong':
          strengthColor = AppColor.featureCheckDark;
          break;
        case 'good':
          strengthColor = AppColor.darkInfo;
          break;
        case 'fair':
          strengthColor = AppColor.darkWarning;
          break;
        case 'weak':
        default:
          strengthColor = AppColor.darkError;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength indicator
        if (_passwordController.text.isNotEmpty) ...[
          LinearProgressIndicator(
            value: _getStrengthValue(strength),
            backgroundColor: isDark ? AppColor.darkCard : AppColor.lightCard,
            color: strengthColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: strengthColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Requirements list
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: requirements.map<Widget>((req) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildPasswordRequirement(
                req['text'],
                req['isMet'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  double _getStrengthValue(String strength) {
    switch (strength) {
      case 'strong':
        return 1.0;
      case 'good':
        return 0.75;
      case 'fair':
        return 0.5;
      case 'weak':
      default:
        return 0.25;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthScaffold(
      title: 'Create New Password',
      subtitle: 'Enter your new password below. Make sure it\'s strong and secure.',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: Image.asset(
                  AppImages.lock,
                  width: 20,
                  height: 20,
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColor.primary,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Image.asset(
                    _passwordVisible ? AppImages.eye_view : AppImages.eye,
                    width: 20,
                    height: 20,
                    color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
                fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                filled: true,
                labelStyle: TextStyle(
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColor.darkText : AppColor.lightText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                final validation = _passwordHelper.validatePassword(value);
                if (!validation['isValid']) {
                  return validation['message'];
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_confirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Image.asset(
                  AppImages.secure,
                  width: 20,
                  height: 20,
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColor.primary,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Image.asset(
                    _confirmPasswordVisible ? AppImages.eye_view : AppImages.eye,
                    width: 20,
                    height: 20,
                    color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
                fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                filled: true,
                labelStyle: TextStyle(
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColor.darkText : AppColor.lightText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password Requirements
            _buildPasswordStrengthIndicator(),

            const SizedBox(height: 24),

            // Submit Button
            PrimaryButton(
              text: 'Reset Password',
              onPressed: _isLoading ? null : _submitResetPassword,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),

            // Message Display
            if (_message.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? (isDark ? AppColor.darkSuccess : AppColor.lightSuccess).withValues(alpha: 0.2)
                      : (isDark ? AppColor.darkError : AppColor.lightError).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSuccess
                        ? isDark ? AppColor.darkSuccess : AppColor.lightSuccess
                        : isDark ? AppColor.darkError : AppColor.lightError,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          _isSuccess ? AppImages.tick : AppImages.error,
                          width: 20,
                          height: 20,
                          color: _isSuccess
                              ? isDark ? AppColor.darkSuccess : AppColor.lightSuccess
                              : isDark ? AppColor.darkError : AppColor.lightError,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSuccess ? 'Success!' : 'Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isSuccess
                                ? isDark ? AppColor.darkSuccess : AppColor.lightSuccess
                                : isDark ? AppColor.darkError : AppColor.lightError,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: TextStyle(
                        color: _isSuccess
                            ? isDark ? AppColor.darkSuccess : AppColor.lightSuccess
                            : isDark ? AppColor.darkError : AppColor.lightError,
                      ),
                    ),
                    if (_isSuccess) ...[
                      const SizedBox(height: 12),
                      ..._passwordHelper.getPostResetSteps(_isSuccess).map((step) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Image.asset(
                                step['completed'] ? AppImages.tick : AppImages.clock,
                                width: 16,
                                height: 16,
                                color: step['completed']
                                    ? AppColor.featureCheckLight
                                    : (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step['step'],
                                  style: TextStyle(
                                    color: step['completed']
                                        ? AppColor.featureCheckLight
                                        : (isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordRequirements);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
