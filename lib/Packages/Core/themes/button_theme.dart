import 'package:flutter/material.dart';

import '../constants/app_color.dart';

enum ButtonVariant { filled, outlined, text }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Make it nullable
  final Future<void> Function()? onPressedAsync;
  final bool showLeftIcon;
  final bool showRightIcon;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Color buttonColor;
  final Color textColor;
  final ButtonVariant variant;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed, // Remove required and make nullable
    this.onPressedAsync,
    this.showLeftIcon = false,
    this.showRightIcon = false,
    this.leftIcon,
    this.rightIcon,
    this.buttonColor = AppColor.primary,
    this.textColor = AppColor.light,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
  }) : assert(onPressed != null || onPressedAsync != null,
          'Either onPressed or onPressedAsync must be provided');

  Future<void> _handlePress() async {
    if (onPressedAsync != null) {
      await onPressedAsync!();
    } else if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : (onPressedAsync != null ? _handlePress : onPressed),
      style: _getButtonStyle(context),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.light),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLeftIcon && leftIcon != null)
                  Icon(leftIcon, size: 20, color: _getIconColor()),
                if (showLeftIcon && leftIcon != null)
                  const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showRightIcon && rightIcon != null)
                  const SizedBox(width: 8),
                if (showRightIcon && rightIcon != null)
                  Icon(rightIcon, size: 20, color: _getIconColor()),
              ],
            ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (variant) {
      case ButtonVariant.filled:
        return ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonVariant.outlined:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColor.trans,
          foregroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: buttonColor, width: 2),
          ),
        );
      case ButtonVariant.text:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColor.trans,
          foregroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        );
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.filled:
        return textColor;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return buttonColor;
    }
  }

  Color _getIconColor() {
    switch (variant) {
      case ButtonVariant.filled:
        return textColor;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return buttonColor;
    }
  }
}

class ButtonStyles {
  static PrimaryButton primary({
    required String text,
    required VoidCallback onPressed,
    bool showLeftIcon = false,
    bool showRightIcon = false,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      showLeftIcon: showLeftIcon,
      showRightIcon: showRightIcon,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      buttonColor: AppColor.primary,
      textColor: AppColor.light,
      variant: ButtonVariant.filled,
      isLoading: isLoading,
    );
  }

  static PrimaryButton secondary({
    required String text,
    required VoidCallback onPressed,
    bool showLeftIcon = false,
    bool showRightIcon = false,
    IconData? leftIcon,
    IconData? rightIcon,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      showLeftIcon: showLeftIcon,
      showRightIcon: showRightIcon,
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      buttonColor: AppColor.primary,
      textColor: AppColor.primary,
      variant: ButtonVariant.outlined,
      isLoading: isLoading,
    );
  }

  static PrimaryButton success({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      buttonColor: AppColor.lightSuccess,
      textColor: AppColor.light,
      variant: ButtonVariant.filled,
      isLoading: isLoading,
    );
  }

  static PrimaryButton error({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      buttonColor: AppColor.lightError,
      textColor: AppColor.light,
      variant: ButtonVariant.filled,
      isLoading: isLoading,
    );
  }
}
