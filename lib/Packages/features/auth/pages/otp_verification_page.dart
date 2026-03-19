import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Helpers/otp_helper.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';
import 'reset_password.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final OtpHelper _otpHelper = OtpHelper();
  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _focusNodes;

  bool _isLoading = false;
  bool _isResending = false;
  String _message = '';
  bool _isSuccess = false;
  final int _otpLength = 6;
  int _resendCooldown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    final fields = _otpHelper.initializeOtpFields(_otpLength);
    _otpControllers = fields['controllers'] as List<TextEditingController>;
    _focusNodes = fields['focusNodes'] as List<FocusNode>;
    _startResendCooldown();
  }

  void _startResendCooldown() {
    _canResend = false;
    _resendCooldown = 30;

    for (int i = 0; i < _resendCooldown; i++) {
      Future.delayed(Duration(seconds: i), () {
        if (mounted) {
          setState(() {
            _resendCooldown = 30 - i;
            _canResend = _resendCooldown == 0;
          });
        }
      });
    }
  }

  String get _enteredOtp {
    return _otpHelper.extractOtpFromControllers(_otpControllers);
  }

  void _onOtpChanged(int index, String value) {
    _otpHelper.handleOtpFieldNavigation(
      index: index,
      value: value,
      otpLength: _otpLength,
      focusNodes: _focusNodes,
      onComplete: (_) => _verifyOtp(),
    );
  }

  Future<void> _verifyOtp() async {
    if (!_otpHelper.areAllOtpFieldsFilled(_otpControllers)) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.verifyPasswordResetOtp(
      email: widget.email,
      otp: _enteredOtp,
    );

    setState(() {
      _isLoading = false;
      _message = result['message']!;
      _isSuccess = result['success']!;
    });

    if (_isSuccess && result['resetToken'] != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(resetToken: result['resetToken']!),
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _message = '';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.forgotPassword(widget.email);

    setState(() {
      _isResending = false;
      _message = result['message']!;
    });

    if (result['success'] == true) {
      _startResendCooldown();
      _otpHelper.clearOtpFields(_otpControllers, _focusNodes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AuthScaffold(
      title: 'Verify OTP',
      subtitle: 'We sent a 6-digit OTP to your registered email',
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColor.darkCard.withValues(alpha: 0.3)
                  : AppColor.lightCard.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Email: ${widget.email}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColor.darkText : AppColor.lightText,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // OTP Input Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              return SizedBox(
                width: 50,
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
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
                    fillColor: isDark ? AppColor.darkCard : AppColor.lightCard,
                    filled: true,
                  ),
                  style: TextStyle(
                    color: isDark ? AppColor.darkText : AppColor.lightText,
                  ),
                  onChanged: (value) => _onOtpChanged(index, value),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Verify Button
          PrimaryButton(
            text: 'Verify OTP',
            onPressed: _verifyOtp,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          // Resend OTP Section
          Center(
            child: Column(
              children: [
                Text(
                  "Didn't receive the OTP?",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark 
                        ? AppColor.darkTextSecondary 
                        : AppColor.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _isResending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColor.loadingPrimaryDark : AppColor.loadingPrimaryLight,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: _canResend ? _resendOtp : null,
                        child: Text(
                          _canResend
                              ? 'Resend OTP'
                              : 'Resend in $_resendCooldown seconds',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _canResend 
                                ? AppColor.primary
                                : isDark 
                                    ? AppColor.darkTextHint 
                                    : AppColor.lightTextHint,
                          ),
                        ),
                      ),
              ],
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
              child: Row(
                children: [
                  Image.asset(
                    _isSuccess ? AppImages.tick : AppImages.error,
                    width: 20,
                    height: 20,
                    color: _isSuccess
                        ? isDark ? AppColor.darkSuccess : AppColor.lightSuccess
                        : isDark ? AppColor.darkError : AppColor.lightError,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isSuccess 
                            ? isDark ? AppColor.darkSuccess : AppColor.lightSuccess
                            : isDark ? AppColor.darkError : AppColor.lightError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otpHelper.disposeOtpFields(
      controllers: _otpControllers,
      focusNodes: _focusNodes,
    );
    super.dispose();
  }
}
