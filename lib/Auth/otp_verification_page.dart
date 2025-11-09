import 'package:flutter/material.dart';
import 'package:na3eeman/Auth/reset_password.dart';
import '../Services/auth_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = [];
  final List<FocusNode> _focusNodes = [];
  final AuthService _authService = AuthService();

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
    _initializeOtpFields();
    _startResendCooldown();
  }

  void _initializeOtpFields() {
    for (int i = 0; i < _otpLength; i++) {
      _otpControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
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
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all fields are filled
    if (_enteredOtp.length == _otpLength) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp.length != _otpLength) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    final result = await _authService.verifyPasswordResetOtp(
      email: widget.email,
      otp: _enteredOtp,
    );

    setState(() {
      _isLoading = false;
      _message = result['message']!;
      _isSuccess = result['success']!;
    });

    if (_isSuccess && result['resetToken'] != null) {
      // Navigate to reset password page
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

    final result = await _authService.sendPasswordResetOtp(widget.email);

    setState(() {
      _isResending = false;
      _message = result['message']!;
    });

    if (result['success'] == true) {
      _startResendCooldown();
      // Clear OTP fields
      for (final controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter OTP',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'We sent a 6-digit OTP to your registered phone number',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${widget.email}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _onOtpChanged(index, value),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _enteredOtp.length != _otpLength)
                    ? null
                    : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Resend OTP Section
            Center(
              child: Column(
                children: [
                  Text(
                    "Didn't receive the OTP?",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  _isResending
                      ? const CircularProgressIndicator()
                      : TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? 'Resend OTP'
                          : 'Resend in $_resendCooldown seconds',
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
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSuccess
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
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
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
