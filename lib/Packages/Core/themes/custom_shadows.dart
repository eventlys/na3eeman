import 'package:flutter/material.dart';
// import '../constants/app_color.dart';

class CustomShadows {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  // Soft shadows (replaces neumorphic)
  static List<BoxShadow> softLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> softDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  // Keep old names for backward compat
  static List<BoxShadow> get neumorphicLight => softLight;
  static List<BoxShadow> get neumorphicDark => softDark;
}

// For more customizable inner shadows
class CustomInnerShadowPainter extends CustomPainter {
  final List<ShadowConfig> shadows;
  final double borderRadius;

  CustomInnerShadowPainter({
    required this.shadows,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = Radius.circular(borderRadius);

    for (final shadow in shadows) {
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          shadow.blurRadius,
        );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius).deflate(shadow.spread),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShadowConfig {
  final Color color;
  final double blurRadius;
  final double spread;

  const ShadowConfig({
    required this.color,
    required this.blurRadius,
    this.spread = 0,
  });
}

// For outer shadows with custom shapes
class CustomOuterShadowPainter extends CustomPainter {
  final List<BoxShadow> shadows;
  final double borderRadius;

  const CustomOuterShadowPainter({
    required this.shadows,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    for (final shadow in shadows) {
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          shadow.blurRadius,
        );

      canvas.drawRRect(
        rrect.shift(shadow.offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
