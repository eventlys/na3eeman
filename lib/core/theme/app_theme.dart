import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
// import 'button_styles.dart';
import '../../Packages/Core/utils/helpers/themes_helpers.dart';
// import '../enums/app_enums.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getGenderTheme(UserGender gender, bool isDark) {
    // Determine the main background color
    final Color mainColor = isDark ? AppColors.almostBlack : AppColors.cream;
    
    // Determine the complementary text/icon color
    final Color onMainColor = isDark ? AppColors.cream50 : AppColors.almostBlack;

    // Determine the primary (second) and secondary (hints) colors based on gender
    final Color secondColor = gender == UserGender.female ? AppColors.pink : AppColors.blue;
    final Color hintColor = gender == UserGender.female ? AppColors.blue : AppColors.pink;

    // Surface color for cards, dialogs, etc.
    final Color surfaceColor = isDark ? AppColors.almostBlack600 : AppColors.white;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: secondColor,
      onPrimary: AppColors.white,
      secondary: hintColor,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: surfaceColor,
      onSurface: onMainColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: secondColor,
      scaffoldBackgroundColor: mainColor,
      colorScheme: colorScheme,
      textTheme: AppTypography.buildTextTheme(onMainColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondColor,
          side: BorderSide(color: secondColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.almostBlack400 : AppColors.almostBlack100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.almostBlack400 : AppColors.almostBlack100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark ? BorderSide(color: AppColors.white.withValues(alpha: 0.1)) : BorderSide.none,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        GradientBackgroundColors(
          startColor: isDark ? AppColors.almostBlack : mainColor,
          endColor: isDark ? AppColors.almostBlack700 : AppColors.cream,
        ),
      ],
    );
  }
}
