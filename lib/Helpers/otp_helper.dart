import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class OtpHelper {
  final Logger _logger = Logger();

  /// Validates OTP format
  bool validateOtpFormat(String otp, {int requiredLength = 6}) {
    if (otp.length != requiredLength) {
      _logger.w('OTP length invalid: ${otp.length}, expected: $requiredLength');
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(otp)) {
      _logger.w('OTP contains non-digit characters');
      return false;
    }

    return true;
  }

  /// Formats OTP for display (e.g., 123-456)
  String formatOtpForDisplay(String otp, {String separator = '-'}) {
    if (otp.length != 6) return otp;
    return '${otp.substring(0, 3)}$separator${otp.substring(3)}';
  }

  /// Clears OTP fields and resets focus to first field
  void clearOtpFields(
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    for (final controller in controllers) {
      controller.clear();
    }
    if (focusNodes.isNotEmpty) {
      focusNodes.first.requestFocus();
    }
  }

  /// Calculates resend cooldown time
  String formatCooldownTime(int seconds) {
    if (seconds <= 0) return 'Ready';

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  /// Validates if OTP fields are completely filled
  bool areAllOtpFieldsFilled(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Extracts OTP from controllers
  String extractOtpFromControllers(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text).join();
  }

  /// Handles OTP field navigation
  void handleOtpFieldNavigation({
    required int index,
    required String value,
    required int otpLength,
    required List<FocusNode> focusNodes,
    required Function(String) onComplete,
  }) {
    // Move to next field if current field has value
    if (value.isNotEmpty && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    // Move to previous field if current field is empty and backspace pressed
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all fields are filled
    final currentOtp = extractOtpFromControllers(
      List.generate(
        otpLength,
        (i) =>
            TextEditingController(text: i == index ? value : '')
              ..text = i == index ? value : '',
      ),
    );

    if (currentOtp.length == otpLength) {
      onComplete(currentOtp);
    }
  }

  /// Initialize OTP fields
  Map<String, dynamic> initializeOtpFields(int otpLength) {
    final controllers = List<TextEditingController>.generate(
      otpLength,
      (index) => TextEditingController(),
    );

    final focusNodes = List<FocusNode>.generate(
      otpLength,
      (index) => FocusNode(),
    );

    return {'controllers': controllers, 'focusNodes': focusNodes};
  }

  /// Dispose OTP resources
  void disposeOtpFields({
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
  }) {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
  }
}
