import 'package:flutter/material.dart';
import 'colors.dart';

class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shadowColor: primary.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return ElevatedButton.styleFrom(
      backgroundColor: secondary,
      foregroundColor: AppColors.white,
      elevation: 4,
      shadowColor: secondary.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  static ButtonStyle outlineButtonStyle(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: BorderSide(color: primary, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  static ButtonStyle dangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Gradient helper for specialized buttons
  static Decoration primaryGradientDecoration(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isPink = primary.value == AppColors.pink.value;

    final color1 = isPink ? AppColors.pink500 : AppColors.blue600;
    final color2 = isPink ? AppColors.pink600 : AppColors.blue700;

    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color1, color2],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Decoration secondaryGradientDecoration(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final isPink = secondary.value == AppColors.pink.value;

    final color1 = isPink ? AppColors.pink500 : AppColors.blue400;
    final color2 = isPink ? AppColors.pink600 : AppColors.blue600;

    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color1, color2],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: secondary.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
