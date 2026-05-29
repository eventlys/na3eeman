import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../themes/app_theme.dart';
import '../../utils/helpers/themes_helpers.dart';

/// Displays a user avatar tinted to match the gender accent colour.
///
/// Uses `ColorFiltered` with `BlendMode.srcATop` for partial tinting on
/// transparent-background PNGs. For fully-opaque avatars, falls back to a
/// themed circular border frame.
///
/// ```dart
/// ThemedAvatar(
///   imagePath: 'assets/mojies/male_avatar.png',
///   gender: UserGender.male,
///   radius: 36,
/// )
/// ```
class ThemedAvatar extends StatelessWidget {
  const ThemedAvatar({
    super.key,
    required this.imagePath,
    required this.gender,
    this.radius = 36,
    this.isNetwork = false,
    this.useColorFilter = true,
    this.heroTag,
  });

  final String imagePath;
  final UserGender gender;
  final double radius;
  final bool isNetwork;

  /// Set to false to skip tinting (fallback to border frame only).
  final bool useColorFilter;
  final String? heroTag;

  Color _tintColor(bool isDark) {
    switch (gender) {
      case UserGender.female:
        return isDark ? const Color(0x66E91E8C) : const Color(0x44E91E8C);
      case UserGender.male:
        return isDark ? const Color(0x661A2E6B) : const Color(0x441A2E6B);
      case UserGender.nonBinary:
        return const Color(0x44F59E0B);
    }
  }

  Color _borderColor(bool isDark) {
    switch (gender) {
      case UserGender.female:
        return isDark ? AppColor.pinkDark : AppColor.pinkPrimary;
      case UserGender.male:
        return isDark ? AppColor.navyLight : AppColor.navyPrimary;
      case UserGender.nonBinary:
        return AppColor.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = _borderColor(isDark);
    final tintColor = _tintColor(isDark);
    final diameter = radius * 2;

    Widget imageWidget = isNetwork
        ? Image.network(
            imagePath,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _placeholder(context, isDark, borderColor),
          )
        : Image.asset(
            imagePath,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _placeholder(context, isDark, borderColor),
          );

    if (useColorFilter) {
      imageWidget = ColorFiltered(
        colorFilter: ColorFilter.mode(tintColor, BlendMode.srcATop),
        child: imageWidget,
      );
    }

    widget() => Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.5),
        color: isDark ? AppColor.ninjaCard : AppColor.lightSurface,
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha:0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(child: imageWidget),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: widget());
    }
    return widget();
  }

  Widget _placeholder(BuildContext context, bool isDark, Color borderColor) {
    final initial = gender == UserGender.female
        ? '♀'
        : gender == UserGender.male
        ? '♂'
        : '⚧';
    return Container(
      color: isDark ? AppColor.ninjaCard : AppColor.bananaCream2,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(fontSize: radius * 0.7, color: borderColor),
        ),
      ),
    );
  }
}
