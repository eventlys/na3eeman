import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_color.dart';
import '../utils/helpers/themes_helpers.dart';
import '../widgets/common/add_item_dialog.dart';

export '../utils/helpers/themes_helpers.dart' show UserGender;

/// Design system corner radii
class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;
}

/// Shared elevation values
class AppElevation {
  AppElevation._();
  static const double none = 0;
  static const double xs = 1;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
}

class AppThemes {
  AppThemes._();

  // ─────────────────────────────────────────────────────────────────────────
  // Shared text theme (using Inter from google_fonts)
  // ─────────────────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.25,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Input decoration theme helper
  // ─────────────────────────────────────────────────────────────────────────
  static InputDecorationTheme _buildInputTheme({
    required Color primary,
    required Color fill,
    required Color hint,
    required Color border,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: GoogleFonts.inter(color: hint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColor.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColor.error, width: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Button themes helper
  // ─────────────────────────────────────────────────────────────────────────
  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color primary) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: AppColor.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Color primary) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Color primary) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT THEME — Clean White
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const primary = AppColor.primaryOrange;
    const scaffold = AppColor.white;
    const surface = AppColor.white;
    const textPrimary = AppColor.charcoal;
    const textSecondary = AppColor.darkGray;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: AppColor.accentOrange,
        surface: surface,
        background: scaffold,
        error: AppColor.error,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: AppColor.white,
        outline: AppColor.lightGray,
      ),
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: textPrimary,
        elevation: AppElevation.none,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.sm,
        color: surface,
        shadowColor: Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _buildInputTheme(
        primary: primary,
        fill: AppColor.paleGray,
        hint: AppColor.mediumGray,
        border: AppColor.lightGray,
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(primary),
      outlinedButtonTheme: _buildOutlinedButtonTheme(primary),
      textButtonTheme: _buildTextButtonTheme(primary),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColor.white,
        elevation: AppElevation.md,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: AppColor.mediumGray,
        elevation: AppElevation.sm,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.12),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: AppColor.mediumGray, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.mediumGray,
          );
        }),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: AppColor.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppRadius.xxl),
            bottomRight: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.paleGray,
        selectedColor: primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColor.lightGray,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: AppDialogThemes.lightDialogTheme,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.charcoal,
        contentTextStyle: GoogleFonts.inter(
          color: AppColor.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: AppColor.paleGray,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary
              : AppColor.mediumGray,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary.withOpacity(0.3)
              : AppColor.lightGray,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        GradientBackgroundColors(
          startColor: AppColor.lightBackgroundStart,
          endColor: AppColor.lightBackgroundEnd,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DARK THEME — Clean Dark
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const primary = AppColor.primaryOrange;
    const scaffold = AppColor.darkBackground;
    const surface = AppColor.darkCard;
    const textPrimary = AppColor.darkText;
    const textSecondary = AppColor.darkTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffold,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: AppColor.accentOrange,
        surface: surface,
        background: scaffold,
        error: AppColor.darkError,
        onPrimary: AppColor.white,
        onSecondary: AppColor.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: AppColor.white,
        outline: AppColor.ninjaDivider,
      ),
      textTheme: _buildTextTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: textPrimary,
        elevation: AppElevation.none,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: surface,
        shadowColor: AppColor.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: _buildInputTheme(
        primary: primary,
        fill: AppColor.darkSurface,
        hint: AppColor.darkTextHint,
        border: AppColor.ninjaDivider,
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(primary),
      outlinedButtonTheme: _buildOutlinedButtonTheme(primary),
      textButtonTheme: _buildTextButtonTheme(primary),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColor.white,
        elevation: AppElevation.md,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: AppColor.darkTextHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.15),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: AppColor.darkTextHint, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColor.darkTextHint,
          );
        }),
        elevation: 0,
        surfaceTintColor: AppColor.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppRadius.xxl),
            bottomRight: Radius.circular(AppRadius.xxl),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColor.darkSurface,
        selectedColor: primary,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: AppDialogThemes.darkDialogTheme,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.darkSurface,
        contentTextStyle: GoogleFonts.inter(
          color: AppColor.darkText,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: AppColor.darkSurface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary
              : AppColor.darkTextHint,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? primary.withOpacity(0.3)
              : AppColor.ninjaDivider,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        GradientBackgroundColors(
          startColor: AppColor.darkBackgroundStart,
          endColor: AppColor.darkBackgroundEnd,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENDER THEME — now simplified (same accent for all)
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData getGenderTheme(UserGender gender, bool isDark) {
    final base = isDark ? darkTheme : lightTheme;
    // With the new design, gender doesn't change the primary color
    // but we keep the method for backward compatibility
    return base;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HIGH CONTRAST
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData getHighContrastTheme(bool isDark) {
    final highContrastTheme = SharedThemeHelpers.getHighContrastTheme(isDark);
    return highContrastTheme.copyWith(
      dialogTheme: AppDialogThemes.getHighContrastDialogTheme(isDark),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  static GradientBackgroundColors getGradientColors(BuildContext context) {
    return Theme.of(context).extension<GradientBackgroundColors>() ??
        GradientBackgroundColors(
          startColor: AppColor.lightBackgroundStart,
          endColor: AppColor.lightBackgroundEnd,
        );
  }

  /// Quick getter for the active primary colour in current context.
  static Color primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
}

/// Enum kept here for imported convenience (actual definition in themes_helpers.dart)
// ignore: unused_element
enum BoxSize { small, medium, large, full }
