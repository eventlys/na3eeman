import 'package:flutter/material.dart';
import '../constants/app_color.dart';

enum ButtonVariant { filled, outlined, text }

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync;
  final bool showLeftIcon;
  final bool showRightIcon;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Color buttonColor;
  final Color textColor;
  final ButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onPressedAsync,
    this.showLeftIcon = false,
    this.showRightIcon = false,
    this.leftIcon,
    this.rightIcon,
    this.buttonColor = AppColor.primaryOrange,
    this.textColor = AppColor.white,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.width,
    this.height = 52,
  }) : assert(
         onPressed != null || onPressedAsync != null,
         'Either onPressed or onPressedAsync must be provided',
       );

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.isLoading) return;

    if (widget.onPressedAsync != null) {
      await widget.onPressedAsync!();
    } else if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors based on variant
    Color bgColor;
    Color contentColor;
    Color borderColor;

    switch (widget.variant) {
      case ButtonVariant.filled:
        bgColor = widget.buttonColor;
        contentColor = widget.textColor;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.outlined:
        bgColor = Colors.transparent;
        contentColor = widget.buttonColor;
        borderColor = widget.buttonColor;
        break;
      case ButtonVariant.text:
        bgColor = Colors.transparent;
        contentColor = widget.buttonColor;
        borderColor = Colors.transparent;
        break;
    }

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) {
          setState(() => _isPressed = true);
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          setState(() => _isPressed = false);
          _controller.reverse();
          _handlePress();
        }
      },
      onTapCancel: () {
        if (!widget.isLoading) {
          setState(() => _isPressed = false);
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(26),
            border: borderColor != Colors.transparent
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow: widget.variant == ButtonVariant.filled && !_isPressed
                ? [
                    BoxShadow(
                      color: widget.buttonColor.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                  ),
                )
              else ...[
                if (widget.showLeftIcon && widget.leftIcon != null) ...[
                  Icon(widget.leftIcon, size: 20, color: contentColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: contentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
                if (widget.showRightIcon && widget.rightIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.rightIcon, size: 20, color: contentColor),
                ],
              ],
            ],
          ),
        ),
      ),
    );
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
      buttonColor: AppColor.primaryOrange,
      textColor: AppColor.white,
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
      buttonColor: AppColor.primaryOrange,
      textColor: AppColor.primaryOrange,
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
      buttonColor: AppColor.success,
      textColor: AppColor.white,
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
      buttonColor: AppColor.error,
      textColor: AppColor.white,
      variant: ButtonVariant.filled,
      isLoading: isLoading,
    );
  }
}
