import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Blue
  static const Color blue = Color(0xFF144EA0);
  static const Color blue50 = Color(0xFFE7EDF6);
  static const Color blue100 = Color(0xFFCFDBEE);
  static const Color blue200 = Color(0xFF9FB7DD);
  static const Color blue300 = Color(0xFF6F93CC);
  static const Color blue400 = Color(0xFF3F6FB9);
  static const Color blue500 = Color(0xFF144EA0);
  static const Color blue600 = Color(0xFF124690);
  static const Color blue700 = Color(0xFF0E366F);
  static const Color blue800 = Color(0xFF09244D);
  static const Color blue900 = Color(0xFF051226);
  static const Color blueBastil = Color(
    0xFF2B66BA,
  ); // ~10% lighter version of 0xFF144EA0

  // Secondary Pink
  static const Color pink = Color(0xFFD097AE);
  static const Color pink50 = Color(0xFFF9F1F4);
  static const Color pink100 = Color(0xFFF2E4EA);
  static const Color pink200 = Color(0xFFE6CBD5);
  static const Color pink300 = Color(0xFFD9B1C1);
  static const Color pink400 = Color(0xFFCD98AD);
  static const Color pink500 = Color(0xFFD097AE);
  static const Color pink600 = Color(0xFFBB889D);
  static const Color pink700 = Color(0xFF8E6777);
  static const Color pink800 = Color(0xFF5E4550);
  static const Color pink900 = Color(0xFF2F2228);
  static const Color pinkBastil = Color(
    0xFFD9A9BD,
  ); // ~10% lighter version of 0xFFD097AE

  // Cream (Background / Light Mode Surface)
  static const Color cream = Color(0xFFfbfaf5);
  static const Color cream50 = Color(0xFFFCFBF6);
  static const Color cream100 = Color(0xFFF9F7EE);
  static const Color cream200 = Color(0xFFF3EFDD);
  static const Color cream300 = Color(0xFFEDE7CC);
  static const Color cream400 = Color(0xFFE8DFBB);
  static const Color cream500 = Color(0xFFfbfaf5);
  static const Color cream600 = Color(0xFFCDC9AD);
  static const Color cream700 = Color(0xFF9B9782);
  static const Color cream800 = Color(0xFF676556);
  static const Color cream900 = Color(0xFF34322B);

  // Almost Black (Dark Mode Surface / Primary Text)
  static const Color almostBlack = Color(0xFF1B1C1F);
  static const Color almostBlack50 = Color(0xFFE8E8E9);
  static const Color almostBlack100 = Color(0xFFD2D2D2);
  static const Color almostBlack200 = Color(0xFFA5A5A6);
  static const Color almostBlack300 = Color(0xFF77787A);
  static const Color almostBlack400 = Color(0xFF4A4B4E);
  static const Color almostBlack500 = Color(0xFF1B1C1F);
  static const Color almostBlack600 = Color(0xFF18191C);
  static const Color almostBlack700 = Color(0xFF121315);
  static const Color almostBlack800 = Color(
    0xFF0C1315,
  ); // Adjusted slightly for variety
  static const Color almostBlack900 = Color(0xFF060607);

  // Opal (Accent)
  static const Color opal = Color(0xFFA8C3BC);
  static const Color opal50 = Color(0xFFF6F9F8);
  static const Color opal100 = Color(0xFFEDF2F1);
  static const Color opal200 = Color(0xFFDCE5E3);
  static const Color opal300 = Color(0xFFCBD8D5);
  static const Color opal400 = Color(0xFFBACBC7);
  static const Color opal500 = Color(0xFFA8C3BC);
  static const Color opal600 = Color(0xFF97B0A9);
  static const Color opal700 = Color(0xFF728681);
  static const Color opal800 = Color(0xFF4C5956);
  static const Color opal900 = Color(0xFF262D2B);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color darkSuccess = Color(0xFF66BB6A);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkInfo = Color(0xFF42A5F5);

  // Neutral Grays
  static const Color offWhite = Color(0xFFF9F9F9);
  static const Color darkGray = Color(0xFF4A4A4A);
  static const Color mediumGray = Color(0xFF9B9B9B);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color paleGray = Color(0xFFF5F5F5);

  // Dark Theme Surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkBackgroundEnd = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextHint = Color(0xFF757575);

  // Overlays / Tints
  static const Color overlay = Color(0x801A1A1A);
  static const Color overlayLight = Color(0x331A1A1A);
  static const Color darkWithOpacity = Color(0x1A121212);
  static const Color avatarTint = Color(0x33144EA0);

  // Transparent
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;

  // Aliases
  static const Color primary = blue;
  static const Color secondary = pink;
  static const Color creamyBackground = cream;
}
