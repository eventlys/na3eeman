import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../themes/app_theme.dart';

enum AppButtonType { primary, secondary, outline, ghost, destructive }

enum AppButtonSize { sm, md, lg }

/// Reusable app-wide button that adapts to the current theme accent colour.
///
/// ```dart
/// AppButton(label: 'Book Now', onPressed: _book)
/// AppButton(label: 'Cancel', type: AppButtonType.outline, onPressed: _cancel)
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  // ── Geometry ──────────────────────────────────────────────────────────────
  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.sm:
        return 13;
      case AppButtonSize.lg:
        return 16;
      case AppButtonSize.md:
        return 15;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget btn;
    switch (type) {
      case AppButtonType.primary:
        btn = _PrimaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          padding: _padding,
          fontSize: _fontSize,
          color: primary,
          isLoading: isLoading,
        );
        break;
      case AppButtonType.secondary:
        final secondary = Theme.of(context).colorScheme.secondary;
        btn = _PrimaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          padding: _padding,
          fontSize: _fontSize,
          color: secondary,
          isLoading: isLoading,
        );
        break;
      case AppButtonType.outline:
        btn = _OutlineButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          padding: _padding,
          fontSize: _fontSize,
          color: primary,
          isLoading: isLoading,
        );
        break;
      case AppButtonType.ghost:
        btn = _GhostButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          padding: _padding,
          fontSize: _fontSize,
          color: primary,
        );
        break;
      case AppButtonType.destructive:
        btn = _PrimaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          padding: _padding,
          fontSize: _fontSize,
          color: isDark ? AppColor.darkError : AppColor.error,
          isLoading: isLoading,
        );
        break;
    }

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ── Private button variants ──────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.color,
    required this.isLoading,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double fontSize;
  final Color color;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: padding,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      child: _ButtonContent(
        label: label,
        fontSize: fontSize,
        icon: icon,
        isLoading: isLoading,
        contentColor: Colors.white,
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.color,
    required this.isLoading,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double fontSize;
  final Color color;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      child: _ButtonContent(
        label: label,
        fontSize: fontSize,
        icon: icon,
        isLoading: isLoading,
        contentColor: color,
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.padding,
    required this.fontSize,
    required this.color,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double fontSize;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: _ButtonContent(
        label: label,
        fontSize: fontSize,
        icon: icon,
        isLoading: false,
        contentColor: color,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.fontSize,
    required this.isLoading,
    required this.contentColor,
    this.icon,
  });
  final String label;
  final double fontSize;
  final bool isLoading;
  final Color contentColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: contentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
    );
  }
}
