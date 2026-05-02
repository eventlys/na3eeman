// shared_theme_helpers.dart
import 'package:flutter/material.dart';
import '../../constants/app_color.dart';

enum UserGender { male, female, nonBinary }

class SharedThemeHelpers {
  // Gender-specific theme configuration
  static GenderThemeConfig _getGenderThemeConfig(UserGender gender, bool isDark) {
    if (isDark) {
      return _getDarkGenderConfig(gender);
    } else {
      return _getLightGenderConfig(gender);
    }
  }

  static GenderThemeConfig _getLightGenderConfig(UserGender gender) {
    switch (gender) {
      case UserGender.male:
        return GenderThemeConfig(
          primaryColor: AppColor.lightMaleBG,
          accentColor: AppColor.maleAccent,
          backgroundColor: AppColor.maleBackground,
          gradientColors: GradientBackgroundColors(
            startColor: AppColor.lightMaleBackgroundStart,
            endColor: AppColor.lightMaleBackgroundEnd,
          ),
          cardColor: AppColor.lightCard,
          textColor: AppColor.dark,
        );
      case UserGender.female:
        return GenderThemeConfig(
          primaryColor: AppColor.lightFemaleBG,
          accentColor: AppColor.femaleAccent,
          backgroundColor: AppColor.femaleBackground,
          gradientColors: GradientBackgroundColors(
            startColor: AppColor.lightFemaleBackgroundStart,
            endColor: AppColor.lightFemaleBackgroundEnd,
          ),
          cardColor: AppColor.lightCard,
          textColor: AppColor.dark,
        );
      case UserGender.nonBinary:
        return GenderThemeConfig(
          primaryColor: AppColor.lightNonBinaryBG,
          accentColor: AppColor.nonBinaryAccent,
          backgroundColor: AppColor.nonBinaryBackground,
          gradientColors: GradientBackgroundColors(
            startColor: AppColor.lightNonBinaryBackgroundStart,
            endColor: AppColor.lightNonBinaryBackgroundEnd,
          ),
          cardColor: AppColor.lightCard,
          textColor: AppColor.dark,
        );
    }
  }

  static GenderThemeConfig _getDarkGenderConfig(UserGender gender) {
    switch (gender) {
      case UserGender.male:
        return GenderThemeConfig(
          primaryColor: AppColor.darkMaleBG,
          accentColor: AppColor.maleAccent,
          backgroundColor: AppColor.darkMaleBackground,
          gradientColors: GradientBackgroundColors(
            startColor: AppColor.darkMaleBackgroundStart,
            endColor: AppColor.darkMaleBackgroundEnd,
          ),
          cardColor: AppColor.darkCard,
          textColor: AppColor.light,
        );
      case UserGender.female:
        return GenderThemeConfig(
          primaryColor: AppColor.darkFemaleBG,
          accentColor: AppColor.femaleAccent,
          backgroundColor: AppColor.darkFemaleBackground,
          gradientColors: GradientBackgroundColors(
            startColor: AppColor.darkFemaleBackgroundStart,
            endColor: AppColor.darkFemaleBackgroundEnd,
          ),
          cardColor: AppColor.darkCard,
          textColor: AppColor.light,
        );
      case UserGender.nonBinary:
        return GenderThemeConfig(
          primaryColor: AppColor.darkNonBinaryBG,
          accentColor: AppColor.nonBinaryAccent,
          backgroundColor: AppColor.darkNonBinaryBackground,
          gradientColors: GradientBackgroundColors(
            startColor: AppColor.darkNonBinaryBackgroundStart,
            endColor: AppColor.darkNonBinaryBackgroundEnd,
          ),
          cardColor: AppColor.darkCard,
          textColor: AppColor.light,
        );
    }
  }

  // High contrast themes
  static ThemeData getHighContrastTheme(bool isDark) {
    if (isDark) {
      return _buildHighContrastDarkTheme();
    } else {
      return _buildHighContrastLightTheme();
    }
  }

  static ThemeData _buildHighContrastLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.black,
        surface: Colors.white,
      ),
      cardColor: Colors.white, dialogTheme: DialogThemeData(backgroundColor: Colors.white),
    );
  }

  static ThemeData _buildHighContrastDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white,
        surface: Colors.black,
      ),
      cardColor: Colors.black, dialogTheme: DialogThemeData(backgroundColor: Colors.black),
    );
  }

  // Public method to get gender theme configuration
  static GenderThemeConfig getGenderThemeConfig(UserGender gender, bool isDark) {
    return _getGenderThemeConfig(gender, isDark);
  }
}

// Configuration class to hold theme data
class GenderThemeConfig {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final GradientBackgroundColors gradientColors;
  final Color cardColor;
  final Color textColor;

  const GenderThemeConfig({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.gradientColors,
    required this.cardColor,
    required this.textColor,
  });
}

class GradientBackgroundColors extends ThemeExtension<GradientBackgroundColors> {
  final Color startColor;
  final Color endColor;

  const GradientBackgroundColors({
    required this.startColor,
    required this.endColor,
  });

  @override
  ThemeExtension<GradientBackgroundColors> copyWith({
    Color? startColor,
    Color? endColor,
  }) {
    return GradientBackgroundColors(
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
    );
  }

  @override
  ThemeExtension<GradientBackgroundColors> lerp(
    ThemeExtension<GradientBackgroundColors>? other,
    double t,
  ) {
    if (other is! GradientBackgroundColors) {
      return this;
    }
    return GradientBackgroundColors(
      startColor: Color.lerp(startColor, other.startColor, t)!,
      endColor: Color.lerp(endColor, other.endColor, t)!,
    );
  }
}

class GradientHelper {
  static GradientBackgroundColors getGradientColors(BuildContext context) {
    // Access the gradient colors from the theme without needing AppThemes class
    return Theme.of(context).extension<GradientBackgroundColors>() ??
        GradientBackgroundColors(
          startColor: AppColor.lightBackgroundStart,
          endColor: AppColor.lightBackgroundEnd,
        );
  }

  // Fallback gradients for when theme is not available
  static GradientBackgroundColors getFallbackGradient(bool isDark) {
    return isDark
        ? GradientBackgroundColors(
            startColor: AppColor.darkBackgroundStart,
            endColor: AppColor.darkBackgroundEnd,
          )
        : GradientBackgroundColors(
            startColor: AppColor.lightBackgroundStart,
            endColor: AppColor.lightBackgroundEnd,
          );
  }
}

