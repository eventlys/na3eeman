import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';

/// App-wide floating snackbar utility.
///
/// Usage:
/// ```dart
/// AppSnackBar.success(context, 'Profile saved!');
/// AppSnackBar.error(context, 'Network error. Please retry.');
/// AppSnackBar.warning(context, 'Low stock detected.');
/// AppSnackBar.info(context, 'Appointment reminder set.');
/// ```
///
/// All snackbars are floating, rounded, and consistent across the app.
/// Never use `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))`
/// directly — always go through this helper.
abstract class AppSnackBar {
  AppSnackBar._();

  // ─── Public API ──────────────────────────────────────────────────────────────

  static void success(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF1D8348),
      duration: duration,
    );
  }

  static void error(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void warning(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: const Color(0xFFB7770D),
      duration: duration,
    );
  }

  static void info(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFF1A5276),
      duration: duration,
    );
  }

  // ─── Internal ────────────────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration? duration,
  }) {
    // Remove any currently visible snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppSpacing.fontMd,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageH,
          vertical: AppSpacing.md,
        ),
        duration: duration ?? const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }
}
