import 'package:flutter/material.dart';

class ThemeHelper {
  static final ThemeHelper _instance = ThemeHelper._internal();

  factory ThemeHelper() => _instance;

  ThemeHelper._internal();

  // Core Color Palette
  static const Color primaryOrange = Color(0xFFF5A623);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF9F9F9);
  static const Color charcoal = Color(0xFF2D2D2D);
  static const Color darkGray = Color(0xFF4A4A4A);
  static const Color mediumGray = Color(0xFF9B9B9B);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color paleGray = Color(0xFFF5F5F5);

  // Legacy aliases
  static const Color bananaCream = white;
  static const Color royalBlue = primaryOrange;
  static const Color gumPink = accentOrange;
  static const Color midnightBlack = charcoal;

  // Semantic aliases
  static const Color primaryColor = primaryOrange;
  static const Color secondaryColor = accentOrange;
  static const Color accentColor = accentOrange;
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = primaryOrange;
  static const Color errorColor = Color(0xFFE53935);
  static const Color infoColor = Color(0xFF2196F3);

  static const Color backgroundColor = white;
  static const Color surfaceColor = white;
  static const Color onBackgroundColor = charcoal;
  static const Color onSurfaceColor = charcoal;

  static const Color textPrimary = charcoal;
  static const Color textSecondary = darkGray;
  static const Color textDisabled = mediumGray;

  static const Color borderColor = lightGray;
  static const Color borderFocusColor = primaryOrange;

  static const Color shadowColor = Color(0x0D000000); // Very subtle shadow

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: accentOrange,
        surface: white,
        error: errorColor,
        onPrimary: white,
        onSecondary: white,
        onSurface: charcoal,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        iconTheme: IconThemeData(color: charcoal),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryOrange,
        unselectedItemColor: mediumGray,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          backgroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          side: const BorderSide(color: primaryOrange, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paleGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        labelStyle: const TextStyle(
          color: darkGray,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: mediumGray,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: charcoal,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: charcoal,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: charcoal,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
      ),
      iconTheme: const IconThemeData(color: charcoal, size: 24),
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 24,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBg = Color(0xFF121212);
    const darkCard = Color(0xFF1E1E1E);
    const darkText = Color(0xFFF5F5F5);
    const darkSecText = Color(0xFFBDBDBD);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primaryOrange,
        secondary: accentOrange,
        surface: darkCard,
        error: errorColor,
        onPrimary: white,
        onSecondary: white,
        onSurface: darkText,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: primaryOrange,
        unselectedItemColor: darkSecText,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha:0.1), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          backgroundColor: darkCard,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          side: const BorderSide(color: primaryOrange, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha:0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha:0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        labelStyle: const TextStyle(
          color: darkSecText,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha:0.4),
          fontWeight: FontWeight.w400,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkSecText,
        ),
      ),
      iconTheme: const IconThemeData(color: darkText, size: 24),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha:0.1),
        thickness: 1,
        space: 24,
      ),
    );
  }

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Constants
  static const double spacingM = 16.0;
  static const double borderRadiusM = 16.0;

  static Color getStatusColor(String status) => primaryOrange;
  static Color getPriorityColor(String priority) => accentOrange;

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, accentOrange],
  );

  static LinearGradient get successGradient => primaryGradient;
  static LinearGradient get warningGradient => primaryGradient;
  static LinearGradient get errorGradient => primaryGradient;

  // Clean Elevated Container — simple shadow
  static BoxDecoration elevatedContainer({
    Color? color,
    double borderRadius = borderRadiusM,
    bool isDark = false,
  }) {
    final bgColor = color ?? (isDark ? const Color(0xFF1E1E1E) : white);
    final bColor = isDark ? Colors.white.withValues(alpha:0.1) : lightGray;

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: bColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:isDark ? 0.15 : 0.05),
          offset: const Offset(0, 2),
          blurRadius: 10,
        ),
      ],
    );
  }

  static BoxDecoration gradientContainer({
    Gradient? gradient,
    double borderRadius = borderRadiusM,
    bool isDark = false,
  }) {
    return elevatedContainer(
      borderRadius: borderRadius,
      isDark: isDark,
    ).copyWith(gradient: gradient ?? primaryGradient);
  }

  static AnimatedContainer animatedContainer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    Alignment? alignment,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: decoration,
      padding: padding,
      alignment: alignment,
      child: child,
    );
  }

  static const List<BoxShadow> shadowS = [];
  static const List<BoxShadow> shadowM = [];
  static const List<BoxShadow> shadowL = [];
}
