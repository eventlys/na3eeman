import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Clear any existing auth errors when entering forgot password page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  Future<void> _submitForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Use the AuthService through AuthProvider
      final result = await authProvider.forgotPassword(_emailController.text.trim());

      setState(() {
        _isLoading = false;
        _message = result['message'] ?? 'OTP sent successfully';
        _isSuccess = result['success'] ?? false;
      });

      // If OTP sent successfully, navigate to OTP verification page
      if (_isSuccess) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(email: _emailController.text.trim()),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Failed to send OTP. Please try again.';
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AuthScaffold(
      title: "forgot_password".tr(),
      subtitle: "enter_your_email_address_and_we_ll_send_you_a_one".tr(),
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "email".tr(),
                prefixIcon: ImageIcon(
                  AssetImage(AppImages.mail_view),
                  color: isDark ? AppColor.darkText : AppColor.lightText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? AppColor.darkPrimary : AppColor.lightPrimary),
                ),
                filled: true,
                fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                labelStyle: TextStyle(
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColor.darkText : AppColor.lightText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: "send_otp".tr(),
                onPressed: _submitForgotPassword,
                showRightIcon: true,
                rightIcon: Icons.send, // Keeping Material icon for now, or replace with custom image icon
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(height: 24),

            // Message Display
            if (_message.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? (isDark ? AppColor.darkSuccess.withValues(alpha: 0.2) : AppColor.lightSuccess.withValues(alpha: 0.2))
                      : (isDark ? AppColor.darkError.withValues(alpha: 0.2) : AppColor.lightError.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSuccess
                        ? (isDark ? AppColor.darkSuccess : AppColor.lightSuccess)
                        : (isDark ? AppColor.darkError : AppColor.lightError),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ImageIcon(
                          AssetImage(_isSuccess ? AppImages.check : AppImages.error_view),
                          size: 20,
                          color: _isSuccess
                              ? (isDark ? AppColor.darkSuccess : AppColor.lightSuccess)
                              : (isDark ? AppColor.darkError : AppColor.lightError),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isSuccess ? 'Check your email' : 'Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isSuccess
                                ? (isDark ? AppColor.darkSuccess : AppColor.lightSuccess)
                                : (isDark ? AppColor.darkError : AppColor.lightError),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: TextStyle(
                        color: _isSuccess
                            ? (isDark ? AppColor.darkSuccess : AppColor.lightSuccess)
                            : (isDark ? AppColor.darkError : AppColor.lightError),
                      ),
                    ),
                    if (_isSuccess) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ImageIcon(
                            AssetImage(AppImages.info),
                            size: 16,
                            color: isDark ? AppColor.darkWarning : AppColor.lightWarning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Check your spam or junk folder if you don\'t see the email.',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 48),
            
            // Back to Login
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
                ),
                child: Text("back_to_login".tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}