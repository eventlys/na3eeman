import 'package:flutter/material.dart';

import '../../constants/app_color.dart';

class AccessibilityUtils {
  static const double _largeTextScale = 1.3;
  static const double _extraLargeTextScale = 2.0;

  static bool isLargeText(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > _largeTextScale;
  }

  static bool isExtraLargeText(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > _extraLargeTextScale;
  }

  static bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  static double getAdjustedFontSize(BuildContext context, double baseSize) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return baseSize * textScale;
  }

  static EdgeInsets getAdjustedPadding(
    BuildContext context,
    EdgeInsets basePadding,
  ) {
    if (isLargeText(context)) {
      return basePadding * 1.2;
    }
    if (isExtraLargeText(context)) {
      return basePadding * 1.5;
    }
    return basePadding;
  }

  static double getAdjustedIconSize(BuildContext context, double baseSize) {
    if (isLargeText(context)) {
      return baseSize * 1.2;
    }
    if (isExtraLargeText(context)) {
      return baseSize * 1.5;
    }
    return baseSize;
  }
}

class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final bool excludeSemantics;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}

class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String semanticLabel;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: ElevatedButton(onPressed: onPressed, style: style, child: child),
    );
  }
}

class HighContrastTheme {
  static ThemeData get highContrastLight {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.highContrastLight(),
      scaffoldBackgroundColor: AppColor.trans,
      cardColor: AppColor.light,
    );
  }

  static ThemeData get highContrastDark {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.highContrastDark(),
      scaffoldBackgroundColor: AppColor.trans,
      cardColor: AppColor.dark,
    );
  }
}
