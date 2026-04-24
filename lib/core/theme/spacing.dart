import 'package:flutter/material.dart';

/// App-wide design tokens for spacing, radii, and font sizes.
///
/// Use these constants everywhere instead of magic numbers so that
/// the entire app stays visually consistent. To tighten or loosen
/// the design system, change a single value here.
abstract class AppSpacing {
  AppSpacing._();

  // ─── Spacing scale ──────────────────────────────────────────────────────────
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 16;
  static const double lg   = 24;
  static const double xl   = 32;
  static const double xxl  = 48;

  // ─── Page-level padding ─────────────────────────────────────────────────────
  /// Standard horizontal padding for page bodies.
  static const double pageH = 20;
  /// Standard vertical padding for page bodies (top & bottom).
  static const double pageV = 24;
  /// Convenient EdgeInsets for Scaffold / ListView padding.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageH,
    vertical: pageV,
  );

  // ─── Card / Container radii ──────────────────────────────────────────────────
  static const double radiusXs     = 8;
  static const double radiusSm     = 12;
  static const double radiusMd     = 16;
  static const double radiusLg     = 20;
  static const double radiusXl     = 24;
  static const double radiusRound  = 100; // fully rounded / pill

  // ─── Component spacing helpers ───────────────────────────────────────────────
  /// Gap between two KPI/stat cards in a row.
  static const double cardGap = 16;
  /// Gap between list items / section items.
  static const double listGap = 12;
  /// Gap between a section header and its content.
  static const double sectionGap = 16;
  /// Gap between two adjacent sections.
  static const double sectionSpacing = 32;

  // ─── Typography scale ────────────────────────────────────────────────────────
  static const double fontXs   = 10;
  static const double fontSm   = 12;
  static const double fontMd   = 14;
  static const double fontBase = 16;
  static const double fontLg   = 18;
  static const double fontXl   = 22;
  static const double fontXxl  = 28;

  // ─── Icon sizes ──────────────────────────────────────────────────────────────
  static const double iconSm   = 16;
  static const double iconMd   = 20;
  static const double iconBase = 24;
  static const double iconLg   = 28;
  static const double iconXl   = 36;

  // ─── Button sizes ────────────────────────────────────────────────────────────
  static const double buttonHeight     = 52;
  static const double buttonHeightSm   = 42;
  static const double buttonHeightXs   = 36;

  // ─── AppBar ──────────────────────────────────────────────────────────────────
  static const double appBarHeight = 56;

  // ─── Bottom sheet ────────────────────────────────────────────────────────────
  static const double sheetTopRadius = 28;
  static const EdgeInsets sheetPadding = EdgeInsets.fromLTRB(24, 16, 24, 32);

  // ─── Convenience BorderRadius builders ──────────────────────────────────────
  static BorderRadius get brXs     => BorderRadius.circular(radiusXs);
  static BorderRadius get brSm     => BorderRadius.circular(radiusSm);
  static BorderRadius get brMd     => BorderRadius.circular(radiusMd);
  static BorderRadius get brLg     => BorderRadius.circular(radiusLg);
  static BorderRadius get brXl     => BorderRadius.circular(radiusXl);
  static BorderRadius get brRound  => BorderRadius.circular(radiusRound);
  static BorderRadius get brSheet  => const BorderRadius.vertical(
    top: Radius.circular(sheetTopRadius),
  );
}
