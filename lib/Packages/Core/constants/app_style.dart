import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

class AppStyle {
  // * * * * * * * * * * * * *** font type *** * * * * * * * * * * *
  static TextStyle _fontType({TextStyle? style}) {
    return GoogleFonts.bebasNeue(textStyle: style);
  }

  static TextStyle styleHeadline1Light = _fontType();
}

class AppTextStyles {
  // Light Theme Text Styles
  static TextStyle lightH1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColor.lightText,
  );

  static TextStyle lightH2 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColor.lightText,
  );

  static TextStyle lightH3 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.lightText,
  );

  static TextStyle lightH4 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColor.lightText,
  );

  static TextStyle lightH5 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColor.lightText,
  );

  static TextStyle lightH6 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColor.lightText,
  );

  // Body Text - Light Theme
  static TextStyle lightBodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColor.lightText,
  );

  static TextStyle lightBodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColor.lightText,
  );

  static TextStyle lightBodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColor.lightTextSecondary,
  );

  // Caption - Light Theme
  static TextStyle lightCaption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColor.lightTextHint,
  );

  static TextStyle lightOverline = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColor.lightTextSecondary,
  );

  // Button Text - Light Theme
  static TextStyle lightButtonLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColor.lightCard,
  );

  static TextStyle lightButtonMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.3,
    color: AppColor.lightCard,
  );

  static TextStyle lightButtonSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColor.lightCard,
  );

  // Special Text Styles - Light Theme
  static TextStyle lightAppBarTitle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColor.lightText,
  );

  static TextStyle lightCardTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.lightText,
  );

  static TextStyle lightPriceText = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColor.lightPrimary,
    height: 1.2,
  );

  static TextStyle lightRatingText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColor.lightWarning,
    height: 1.3,
  );

  // Dark Theme Text Styles
  static TextStyle darkH1 = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColor.darkText,
  );

  static TextStyle darkH2 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColor.darkText,
  );

  static TextStyle darkH3 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.darkText,
  );

  static TextStyle darkH4 = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColor.darkText,
  );

  static TextStyle darkH5 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColor.darkText,
  );

  static TextStyle darkH6 = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColor.darkText,
  );

  // Body Text - Dark Theme
  static TextStyle darkBodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColor.darkText,
  );

  static TextStyle darkBodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColor.darkText,
  );

  static TextStyle darkBodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColor.darkTextSecondary,
  );

  // Caption - Dark Theme
  static TextStyle darkCaption = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColor.darkTextHint,
  );

  static TextStyle darkOverline = const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColor.darkTextSecondary,
  );

  // Button Text - Dark Theme
  static TextStyle darkButtonLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.5,
    color: AppColor.darkCard,
  );

  static TextStyle darkButtonMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.3,
    color: AppColor.darkCard,
  );

  static TextStyle darkButtonSmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColor.darkCard,
  );

  // Special Text Styles - Dark Theme
  static TextStyle darkAppBarTitle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColor.darkText,
  );

  static TextStyle darkCardTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.darkText,
  );

  static TextStyle darkPriceText = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColor.darkPrimary,
    height: 1.2,
  );

  static TextStyle darkRatingText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColor.darkWarning,
    height: 1.3,
  );
}

// Extension for easy context access with theme awareness
extension AppTextStylesExtension on BuildContext {
  // Light theme getters
  TextStyle get lightH1 => AppTextStyles.lightH1;
  TextStyle get lightH2 => AppTextStyles.lightH2;
  TextStyle get lightH3 => AppTextStyles.lightH3;
  TextStyle get lightH4 => AppTextStyles.lightH4;
  TextStyle get lightH5 => AppTextStyles.lightH5;
  TextStyle get lightH6 => AppTextStyles.lightH6;
  TextStyle get lightBodyLarge => AppTextStyles.lightBodyLarge;
  TextStyle get lightBodyMedium => AppTextStyles.lightBodyMedium;
  TextStyle get lightBodySmall => AppTextStyles.lightBodySmall;
  TextStyle get lightButtonLarge => AppTextStyles.lightButtonLarge;
  TextStyle get lightButtonMedium => AppTextStyles.lightButtonMedium;
  TextStyle get lightButtonSmall => AppTextStyles.lightButtonSmall;

  // Dark theme getters
  TextStyle get darkH1 => AppTextStyles.darkH1;
  TextStyle get darkH2 => AppTextStyles.darkH2;
  TextStyle get darkH3 => AppTextStyles.darkH3;
  TextStyle get darkH4 => AppTextStyles.darkH4;
  TextStyle get darkH5 => AppTextStyles.darkH5;
  TextStyle get darkH6 => AppTextStyles.darkH6;
  TextStyle get darkBodyLarge => AppTextStyles.darkBodyLarge;
  TextStyle get darkBodyMedium => AppTextStyles.darkBodyMedium;
  TextStyle get darkBodySmall => AppTextStyles.darkBodySmall;
  TextStyle get darkButtonLarge => AppTextStyles.darkButtonLarge;
  TextStyle get darkButtonMedium => AppTextStyles.darkButtonMedium;
  TextStyle get darkButtonSmall => AppTextStyles.darkButtonSmall;

  // Theme-aware getters (automatically chooses based on current theme)
  TextStyle get h1 => _isDarkMode ? darkH1 : lightH1;
  TextStyle get h2 => _isDarkMode ? darkH2 : lightH2;
  TextStyle get h3 => _isDarkMode ? darkH3 : lightH3;
  TextStyle get h4 => _isDarkMode ? darkH4 : lightH4;
  TextStyle get h5 => _isDarkMode ? darkH5 : lightH5;
  TextStyle get h6 => _isDarkMode ? darkH6 : lightH6;
  TextStyle get bodyLarge => _isDarkMode ? darkBodyLarge : lightBodyLarge;
  TextStyle get bodyMedium => _isDarkMode ? darkBodyMedium : lightBodyMedium;
  TextStyle get bodySmall => _isDarkMode ? darkBodySmall : lightBodySmall;
  TextStyle get buttonLarge => _isDarkMode ? darkButtonLarge : lightButtonLarge;
  TextStyle get buttonMedium =>
      _isDarkMode ? darkButtonMedium : lightButtonMedium;
  TextStyle get buttonSmall => _isDarkMode ? darkButtonSmall : lightButtonSmall;
  TextStyle get caption =>
      _isDarkMode ? AppTextStyles.darkCaption : AppTextStyles.lightCaption;
  TextStyle get overline =>
      _isDarkMode ? AppTextStyles.darkOverline : AppTextStyles.lightOverline;
  TextStyle get appBarTitle => _isDarkMode
      ? AppTextStyles.darkAppBarTitle
      : AppTextStyles.lightAppBarTitle;
  TextStyle get cardTitle =>
      _isDarkMode ? AppTextStyles.darkCardTitle : AppTextStyles.lightCardTitle;
  TextStyle get priceText =>
      _isDarkMode ? AppTextStyles.darkPriceText : AppTextStyles.lightPriceText;
  TextStyle get ratingText => _isDarkMode
      ? AppTextStyles.darkRatingText
      : AppTextStyles.lightRatingText;

  bool get _isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}

enum TextFieldType {
  text,
  email,
  password,
  numeric,
  phone,
  date,
  currency,
  decimal,
  custom,
}
