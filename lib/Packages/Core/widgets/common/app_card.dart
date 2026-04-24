// import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../constants/app_color.dart';
// import 'package:easy_localization/easy_localization.dart';

enum AppCardType { elevated, outlined, gradient }

/// Themed card widget with three visual styles.
///
/// ```dart
/// AppCard(child: Text(AppLocalizations.of(context)!.hello))
/// AppCard(type: AppCardType.gradient, child: Text(AppLocalizations.of(context)!.gold))
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.type = AppCardType.elevated,
    this.onTap,
    this.padding,
    this.color,
    this.borderRadius,
    this.gradient,
    this.margin,
  });

  final Widget child;
  final AppCardType type;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.xl;

    switch (type) {
      case AppCardType.elevated:
        return _buildElevated(context, isDark, radius);
      case AppCardType.outlined:
        return _buildOutlined(context, isDark, radius);
      case AppCardType.gradient:
        return _buildGradient(context, isDark, radius);
    }
  }

  Widget _buildElevated(BuildContext context, bool isDark, double radius) {
    final bg = color ?? (isDark ? AppColor.ninjaCard : AppColor.lightSurface);
    return _Wrapper(
      onTap: onTap,
      margin: margin,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        elevation: isDark ? 0 : 2,
        shadowColor: AppColor.dark.withOpacity(0.06),
        child: _Content(child: child, padding: padding),
      ),
    );
  }

  Widget _buildOutlined(BuildContext context, bool isDark, double radius) {
    final bg = color ?? (isDark ? AppColor.ninjaCard : AppColor.lightSurface);
    final border = isDark ? AppColor.ninjaDivider : AppColor.borderLight;
    return _Wrapper(
      onTap: onTap,
      margin: margin,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border, width: 1),
        ),
        child: _Content(child: child, padding: padding),
      ),
    );
  }

  Widget _buildGradient(BuildContext context, bool isDark, double radius) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final resolvedGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        );
    return _Wrapper(
      onTap: onTap,
      margin: margin,
      child: Container(
        decoration: BoxDecoration(
          gradient: resolvedGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _Content(child: child, padding: padding),
      ),
    );
  }
}

class _Wrapper extends StatelessWidget {
  const _Wrapper({required this.child, this.onTap, this.margin});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: child,
        ),
      );
    }
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: child,
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding ?? const EdgeInsets.all(16), child: child);
  }
}
