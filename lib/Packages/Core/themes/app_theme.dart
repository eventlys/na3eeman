import 'package:flutter/material.dart';
import '../constants/app_color.dart';
import '../utils/helpers/themes_helpers.dart';
import '../widgets/common/add_item_dialog.dart';

enum BoxSize {
  small,    // For compact forms
  medium,   // Standard size
  large,    // For important fields
  full      // Full width
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColor.primary,
      primaryColorDark: AppColor.darkMaleBG,
      primaryColorLight: AppColor.lightMaleBG,
      scaffoldBackgroundColor: AppColor.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.light,
        foregroundColor: AppColor.dark,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColor.lightCard,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.lightTextHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.primary),
        ),
        filled: true,
        fillColor: AppColor.lightCard,
      ),
      // Fixed: Using DialogThemeData instead of DialogTheme
      dialogTheme: AppDialogThemes.lightDialogTheme,
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
      ),
      extensions: <ThemeExtension<dynamic>>[
        GradientBackgroundColors(
          startColor: AppColor.lightBackgroundStart,
          endColor: AppColor.lightBackgroundEnd,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColor.lightMaleBG,
      primaryColorDark: AppColor.primary,
      primaryColorLight: AppColor.lightMaleBG,
      scaffoldBackgroundColor: AppColor.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.darkCard,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColor.darkCard,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.darkTextHint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColor.lightMaleBG),
        ),
        filled: true,
        fillColor: AppColor.darkCard,
      ),
      // Fixed: Using DialogThemeData instead of DialogTheme
      dialogTheme: AppDialogThemes.darkDialogTheme,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColor.lightMaleBG,
        secondary: AppColor.lightSecondary,
      ),
      extensions: <ThemeExtension<dynamic>>[
        GradientBackgroundColors(
          startColor: AppColor.darkBackgroundStart,
          endColor: AppColor.darkBackgroundEnd,
        ),
      ],
    );
  }

  // Gender-specific themes
  static ThemeData getGenderTheme(UserGender gender, bool isDark) {
    final config = SharedThemeHelpers.getGenderThemeConfig(gender, isDark);

    return (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
      primaryColor: config.primaryColor,
      colorScheme: (isDark ? ColorScheme.dark() : ColorScheme.light()).copyWith(
        primary: config.primaryColor,
        secondary: config.accentColor,
        background: config.backgroundColor,
      ),
      scaffoldBackgroundColor: config.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: config.primaryColor,
        foregroundColor: isDark ? AppColor.light : AppColor.dark,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: config.cardColor,
        elevation: isDark ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: config.primaryColor,
        foregroundColor: isDark ? AppColor.dark : AppColor.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: config.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        fillColor: config.cardColor,
        filled: true,
      ),
      // Fixed: Using DialogThemeData instead of DialogTheme
      dialogTheme: AppDialogThemes.getGenderDialogTheme(gender, isDark),
      extensions: <ThemeExtension<dynamic>>[config.gradientColors],
    );
  }

  static ThemeData getHighContrastTheme(bool isDark) {
    final highContrastTheme = SharedThemeHelpers.getHighContrastTheme(isDark);
    return highContrastTheme.copyWith(
      // Fixed: Using DialogThemeData instead of DialogTheme
      dialogTheme: AppDialogThemes.getHighContrastDialogTheme(isDark),
    );
  }

  // Helper method to get gradient colors from theme
  static GradientBackgroundColors getGradientColors(BuildContext context) {
    return Theme.of(context).extension<GradientBackgroundColors>() ??
        GradientBackgroundColors(
          startColor: AppColor.lightBackgroundStart,
          endColor: AppColor.lightBackgroundEnd,
        );
  }
}
