import 'package:flutter/material.dart';

class CustomNeumorphicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color iconColor;
  final double depth;

  const CustomNeumorphicIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.iconColor,
    this.depth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        shape: BoxShape.circle,
        boxShadow: [
          // Dark shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: depth * 2,
            offset: Offset(depth, depth),
          ),
          // Light shadow
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: depth * 2,
            offset: Offset(-depth, -depth),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}

class CustomNeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final double depth;

  const CustomNeumorphicContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = BorderRadius.zero,
    this.depth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white.withValues(alpha: 0.70),
        boxShadow: [
          BoxShadow(
            color: const Color(0x6699806C),
            blurRadius: depth * 2,
            offset: Offset(depth, depth),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}




