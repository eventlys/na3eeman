import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Legacy palette kept as a pure alias layer over [AppColors].
/// New code should use [AppColors] from `lib/core/theme/colors.dart`.
class AppColor {
  AppColor._();

  // Core Brand Colors
  static const Color primaryBlue = AppColors.blue;
  static const Color dustyPink = AppColors.pink;
  static const Color softBeige = AppColors.cream;
  static const Color white = AppColors.white;
  static const Color offWhite = AppColors.offWhite;
  static const Color charcoal = AppColors.almostBlack;
  static const Color darkGray = AppColors.darkGray;
  static const Color mediumGray = AppColors.mediumGray;
  static const Color lightGray = AppColors.lightGray;
  static const Color paleGray = AppColors.paleGray;
  static const Color black = charcoal;

  // Legacy 4 Core Colors
  static const Color bananaCream = white;
  static const Color royalBlue = primaryBlue;
  static const Color gumPink = dustyPink;
  static const Color midnightBlack = charcoal;

  // Light Theme
  static const Color lightBackground = white;
  static const Color lightSurface = white;
  static const Color lightCard = white;
  static const Color lightDivider = lightGray;
  static const Color lightText = charcoal;
  static const Color lightTextSecondary = darkGray;
  static const Color lightTextHint = mediumGray;

  static const Color lightBackgroundStart = white;
  static const Color lightBackgroundEnd = offWhite;

  // Dark Theme
  static const Color darkBackground = AppColors.darkBackground;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkCard = AppColors.darkCard;
  static const Color darkText = AppColors.darkText;
  static const Color darkTextSecondary = AppColors.darkTextSecondary;
  static const Color darkTextHint = AppColors.darkTextHint;

  static const Color darkBackgroundStart = darkBackground;
  static const Color darkBackgroundEnd = AppColors.darkBackgroundEnd;

  // Legacy aliases for dark
  static const Color ninjaBlack = darkBackground;
  static const Color ninjaCard = darkCard;
  static const Color ninjaSurface = darkSurface;
  static const Color ninjaDivider = AppColors.darkDivider;

  // Core aliases
  static const Color primary = primaryBlue;
  static const Color secondary = dustyPink;
  static const Color lightPrimary = primaryBlue;
  static const Color darkPrimary = primaryBlue;
  static const Color lightSecondary = dustyPink;
  static const Color darkSecondary = dustyPink;
  static const Color lightAccent = dustyPink;
  static const Color darkAccent = dustyPink;

  // Pink / Navy Palette Aliases
  static const Color pinkPrimary = dustyPink;
  static const Color pinkLight = softBeige;
  static const Color pinkDark = dustyPink;
  static const Color pinkBgTint = softBeige;
  static const Color pinkDarkBgTint = darkCard;

  static const Color navyPrimary = primaryBlue;
  static const Color navyLight = primaryBlue;
  static const Color navyDark = dustyPink;
  static const Color navyBgTint = softBeige;
  static const Color navyDarkBgTint = darkCard;

  // Semantic Colors
  static const Color success = AppColors.success;
  static const Color successLight = AppColors.successLight;
  static const Color warning = primaryBlue;
  static const Color warningLight = softBeige;
  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color info = AppColors.info;
  static const Color infoLight = AppColors.infoLight;

  static const Color darkSuccess = AppColors.darkSuccess;
  static const Color darkWarning = primaryBlue;
  static const Color darkError = AppColors.darkError;
  static const Color darkInfo = AppColors.darkInfo;

  static const Color lightSuccess = success;
  static const Color lightWarning = warning;
  static const Color lightError = error;
  static const Color lightInfo = info;

  // Role Colors
  static const Color roleOwner = primaryBlue;
  static const Color roleManager = dustyPink;
  static const Color roleExpert = primaryBlue;
  static const Color roleReceptionist = dustyPink;
  static const Color roleHelper = primaryBlue;
  static const Color roleSuperAdmin = charcoal;

  // Subscription Tiers
  static const Color tierBasic = mediumGray;
  static const Color tierGold = primaryBlue;
  static const Color tierElite = dustyPink;
  static const Color tierPremium = dustyPink;
  static const Color tierBusiness = primaryBlue;

  // Avatar / Skeleton
  static const Color avatarTintFemale = AppColors.avatarTint;
  static const Color avatarTintMale = AppColors.avatarTint;
  static const Color skeletonBaseLight = paleGray;
  static const Color skeletonHighlightLight = lightGray;
  static const Color skeletonBaseDark = darkCard;
  static const Color skeletonHighlightDark = AppColors.darkDivider;

  // Transparency helpers
  static const Color transparent = AppColors.transparent;
  static const Color trans = AppColors.transparent;
  static const Color light = white;
  static const Color dark = charcoal;
  static const Color overlay = AppColors.overlay;
  static const Color overlayLight = AppColors.overlayLight;
  static const Color darkWithOpacity = AppColors.darkWithOpacity;

  // Gender-aware Colors
  static const Color maleAccent = primaryBlue;
  static const Color femaleAccent = dustyPink;
  static const Color nonBinaryAccent = primaryBlue;

  static const Color maleBackground = white;
  static const Color femaleBackground = white;
  static const Color nonBinaryBackground = white;

  static const Color darkMaleBackground = darkBackground;
  static const Color darkFemaleBackground = darkBackground;
  static const Color darkNonBinaryBackground = darkBackground;

  static const Color lightMaleBG = white;
  static const Color lightFemaleBG = white;
  static const Color lightNonBinaryBG = white;
  static const Color darkMaleBG = darkBackground;
  static const Color darkFemaleBG = darkBackground;
  static const Color darkNonBinaryBG = darkBackground;

  // Background gradient aliases
  static const Color lightMaleBackgroundStart = white;
  static const Color lightMaleBackgroundEnd = offWhite;
  static const Color lightFemaleBackgroundStart = white;
  static const Color lightFemaleBackgroundEnd = offWhite;
  static const Color lightNonBinaryBackgroundStart = white;
  static const Color lightNonBinaryBackgroundEnd = offWhite;

  static const Color darkMaleBackgroundStart = darkBackground;
  static const Color darkMaleBackgroundEnd = darkBackground;
  static const Color darkFemaleBackgroundStart = darkBackground;
  static const Color darkFemaleBackgroundEnd = darkBackground;
  static const Color darkNonBinaryBackgroundStart = darkBackground;
  static const Color darkNonBinaryBackgroundEnd = darkBackground;

  // Misc Legacy Aliases
  static const Color bananaCream2 = offWhite;
  static const Color lightExpert = primaryBlue;
  static const Color lightManager = dustyPink;
  static const Color lightAssistant = dustyPink;
  static const Color lightReceptionist = primaryBlue;
  static const Color darkExpert = primaryBlue;
  static const Color darkManager = dustyPink;
  static const Color darkAssistant = dustyPink;
  static const Color darkReceptionist = primaryBlue;

  static const Color popularBadgeLight = primaryBlue;
  static const Color popularBadgeDark = primaryBlue;
  static const Color borderLight = lightGray;
  static const Color borderDark = AppColors.darkDivider;
  static const Color buttonBackgroundLight = white;
  static const Color buttonBackgroundDark = darkCard;
  static const Color featureCheckLight = primaryBlue;
  static const Color featureCheckDark = primaryBlue;
  static const Color priceTextLight = primaryBlue;
  static const Color priceTextDark = primaryBlue;

  static const Color gradientStartLight = primaryBlue;
  static const Color gradientEndLight = dustyPink;
  static const Color gradientSecondaryLight = primaryBlue;
  static const Color gradientStartDark = darkBackground;
  static const Color gradientEndDark = primaryBlue;
  static const Color gradientSecondaryDark = dustyPink;

  static const Color loadingPrimaryLight = primaryBlue;
  static const Color loadingPrimaryDark = primaryBlue;
  static const Color loadingSecondaryLight = dustyPink;
  static const Color loadingSecondaryDark = dustyPink;

  static const Color primaryOrange = primaryBlue;
  static const Color accentOrange = dustyPink;
  static const Color softOrange = softBeige;

  // Helper Methods
  static Color genderPrimary({required bool isFemale, bool isDark = false}) {
    return isFemale ? dustyPink : primaryBlue;
  }

  static Color genderBgTint({required bool isFemale, bool isDark = false}) {
    return isDark ? darkCard : softBeige;
  }

  static Color subscriptionTierColor(String tier) {
    return tier.toLowerCase() == 'gold' || tier.toLowerCase() == 'business'
        ? primaryBlue
        : dustyPink;
  }
}
