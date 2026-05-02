import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // ─────────────────────────────────────────────────────────────────────────
  // Core Brand Colors — Clean, Modern Expert App
  // ─────────────────────────────────────────────────────────────────────────
  static const Color primaryBlue   = Color(0xFF144EA0);    // Royal Blue
  static const Color dustyPink     = Color(0xFFD097AE);    // Mauve/Pink
  static const Color softBeige     = Color(0xFFfbfaf5);    // Light Beige/Cream
  static const Color white         = Color(0xFFFFFFFF);    // Pure white
  static const Color offWhite      = Color(0xFFF9F9F9);    // Slightly warm white
  static const Color charcoal      = Color(0xFF1B1C1F);    // Dark Charcoal/Black (from palette)
  static const Color darkGray      = Color(0xFF4A4A4A);    // Secondary text
  static const Color mediumGray    = Color(0xFF9B9B9B);    // Hint/placeholder
  static const Color lightGray     = Color(0xFFE8E8E8);    // Borders / dividers
  static const Color paleGray      = Color(0xFFF5F5F5);    // Card backgrounds
  static const Color black         = Color(0xFF1B1C1F);    // True dark (mapped to charcoal)

  // Legacy 4 Core Colors — kept for backward compatibility
  static const Color bananaCream   = white;
  static const Color royalBlue     = primaryBlue;
  static const Color gumPink       = dustyPink;
  static const Color midnightBlack = charcoal;

  // ─────────────────────────────────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────────────────────────────────
  static const Color lightBackground       = white;
  static const Color lightSurface          = white;
  static const Color lightCard             = white;
  static const Color lightDivider          = lightGray;
  static const Color lightText             = charcoal;
  static const Color lightTextSecondary    = darkGray;
  static const Color lightTextHint         = mediumGray;

  static const Color lightBackgroundStart  = white;
  static const Color lightBackgroundEnd    = offWhite;

  // ─────────────────────────────────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────────────────────────────────
  static const Color darkBackground        = Color(0xFF121212);
  static const Color darkSurface           = Color(0xFF1E1E1E);
  static const Color darkCard              = Color(0xFF252525);
  static const Color darkText              = Color(0xFFF5F5F5);
  static const Color darkTextSecondary     = Color(0xFFBDBDBD);
  static const Color darkTextHint          = Color(0xFF757575);

  static const Color darkBackgroundStart   = Color(0xFF121212);
  static const Color darkBackgroundEnd     = Color(0xFF1A1A1A);

  // Legacy aliases for dark
  static const Color ninjaBlack   = darkBackground;
  static const Color ninjaCard    = darkCard;
  static const Color ninjaSurface = darkSurface;
  static const Color ninjaDivider = Color(0xFF333333);

  // ─────────────────────────────────────────────────────────────────────────
  // Core aliases
  // ─────────────────────────────────────────────────────────────────────────
  static const Color primary          = primaryBlue;
  static const Color secondary        = dustyPink;
  static const Color lightPrimary     = primaryBlue;
  static const Color darkPrimary      = primaryBlue;
  static const Color lightSecondary   = dustyPink;
  static const Color darkSecondary    = dustyPink;
  static const Color lightAccent      = dustyPink;
  static const Color darkAccent       = dustyPink;

  // ─────────────────────────────────────────────────────────────────────────
  // Pink / Navy Palette Aliases (backward compat — mapped to new palette)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color pinkPrimary      = dustyPink;
  static const Color pinkLight        = softBeige;
  static const Color pinkDark         = dustyPink;
  static const Color pinkBgTint       = softBeige;
  static const Color pinkDarkBgTint   = darkCard;

  static const Color navyPrimary      = primaryBlue;
  static const Color navyLight        = primaryBlue;
  static const Color navyDark         = dustyPink;
  static const Color navyBgTint       = softBeige;
  static const Color navyDarkBgTint   = darkCard;

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic Colors
  // ─────────────────────────────────────────────────────────────────────────
  static const Color success       = Color(0xFF4CAF50);
  static const Color successLight  = Color(0xFFE8F5E9);
  static const Color warning       = primaryBlue;
  static const Color warningLight  = softBeige;
  static const Color error         = Color(0xFFE53935);
  static const Color errorLight    = Color(0xFFFFEBEE);
  static const Color info          = Color(0xFF2196F3);
  static const Color infoLight     = Color(0xFFE3F2FD);

  static const Color darkSuccess   = Color(0xFF66BB6A);
  static const Color darkWarning   = primaryBlue;
  static const Color darkError     = Color(0xFFEF5350);
  static const Color darkInfo      = Color(0xFF42A5F5);

  static const Color lightSuccess  = success;
  static const Color lightWarning  = warning;
  static const Color lightError    = error;
  static const Color lightInfo     = info;

  // ─────────────────────────────────────────────────────────────────────────
  // Role Colors
  // ─────────────────────────────────────────────────────────────────────────
  static const Color roleOwner        = primaryBlue;
  static const Color roleManager      = dustyPink;
  static const Color roleExpert     = primaryBlue;
  static const Color roleReceptionist = dustyPink;
  static const Color roleHelper       = primaryBlue;
  static const Color roleSuperAdmin   = charcoal;

  // ─────────────────────────────────────────────────────────────────────────
  // Subscription Tiers
  // ─────────────────────────────────────────────────────────────────────────
  static const Color tierBasic    = mediumGray;
  static const Color tierGold     = primaryBlue;
  static const Color tierElite    = dustyPink;
  static const Color tierPremium  = dustyPink;
  static const Color tierBusiness = primaryBlue;

  // ─────────────────────────────────────────────────────────────────────────
  // Avatar / Skeleton
  // ─────────────────────────────────────────────────────────────────────────
  static const Color avatarTintFemale        = Color(0x33144EA0);
  static const Color avatarTintMale          = Color(0x33144EA0);
  static const Color skeletonBaseLight       = paleGray;
  static const Color skeletonHighlightLight  = lightGray;
  static const Color skeletonBaseDark        = darkCard;
  static const Color skeletonHighlightDark   = Color(0xFF333333);

  // ─────────────────────────────────────────────────────────────────────────
  // Transparency helpers
  // ─────────────────────────────────────────────────────────────────────────
  static const Color transparent    = Colors.transparent;
  static const Color trans          = Colors.transparent;
  static const Color light          = white;
  static const Color dark           = charcoal;
  static const Color overlay        = Color(0x801A1A1A);
  static const Color overlayLight   = Color(0x331A1A1A);
  static const Color darkWithOpacity = Color(0x1A121212);

  // ─────────────────────────────────────────────────────────────────────────
  // Gender-aware Colors — unified
  // ─────────────────────────────────────────────────────────────────────────
  static const Color maleAccent         = primaryBlue;
  static const Color femaleAccent       = dustyPink;
  static const Color nonBinaryAccent    = primaryBlue;

  static const Color maleBackground     = white;
  static const Color femaleBackground   = white;
  static const Color nonBinaryBackground = white;

  static const Color darkMaleBackground     = darkBackground;
  static const Color darkFemaleBackground   = darkBackground;
  static const Color darkNonBinaryBackground = darkBackground;

  static const Color lightMaleBG        = white;
  static const Color lightFemaleBG      = white;
  static const Color lightNonBinaryBG   = white;
  static const Color darkMaleBG         = darkBackground;
  static const Color darkFemaleBG       = darkBackground;
  static const Color darkNonBinaryBG    = darkBackground;

  // Background gradient aliases
  static const Color lightMaleBackgroundStart      = white;
  static const Color lightMaleBackgroundEnd        = offWhite;
  static const Color lightFemaleBackgroundStart    = white;
  static const Color lightFemaleBackgroundEnd      = offWhite;
  static const Color lightNonBinaryBackgroundStart = white;
  static const Color lightNonBinaryBackgroundEnd   = offWhite;

  static const Color darkMaleBackgroundStart       = darkBackground;
  static const Color darkMaleBackgroundEnd         = darkBackground;
  static const Color darkFemaleBackgroundStart     = darkBackground;
  static const Color darkFemaleBackgroundEnd       = darkBackground;
  static const Color darkNonBinaryBackgroundStart  = darkBackground;
  static const Color darkNonBinaryBackgroundEnd    = darkBackground;

  // ─────────────────────────────────────────────────────────────────────────
  // Misc Legacy Aliases
  // ─────────────────────────────────────────────────────────────────────────
  static const Color bananaCream2          = offWhite;
  static const Color lightExpert           = primaryBlue;
  static const Color lightManager          = dustyPink;
  static const Color lightAssistant        = dustyPink;
  static const Color lightReceptionist     = primaryBlue;
  static const Color darkExpert            = primaryBlue;
  static const Color darkManager           = dustyPink;
  static const Color darkAssistant         = dustyPink;
  static const Color darkReceptionist      = primaryBlue;

  static const Color popularBadgeLight     = primaryBlue;
  static const Color popularBadgeDark      = primaryBlue;
  static const Color borderLight           = lightGray;
  static const Color borderDark            = Color(0xFF333333);
  static const Color buttonBackgroundLight = white;
  static const Color buttonBackgroundDark  = darkCard;
  static const Color featureCheckLight     = primaryBlue;
  static const Color featureCheckDark      = primaryBlue;
  static const Color priceTextLight        = primaryBlue;
  static const Color priceTextDark         = primaryBlue;

  static const Color gradientStartLight      = primaryBlue;
  static const Color gradientEndLight        = dustyPink;
  static const Color gradientSecondaryLight  = primaryBlue;
  static const Color gradientStartDark       = darkBackground;
  static const Color gradientEndDark         = primaryBlue;
  static const Color gradientSecondaryDark   = dustyPink;

  static const Color loadingPrimaryLight     = primaryBlue;
  static const Color loadingPrimaryDark      = primaryBlue;
  static const Color loadingSecondaryLight   = dustyPink;
  static const Color loadingSecondaryDark    = dustyPink;

  // For compatibility if they are still referenced
  static const Color primaryOrange         = primaryBlue;
  static const Color accentOrange          = dustyPink;
  static const Color softOrange            = softBeige;

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────
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
