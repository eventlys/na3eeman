import 'package:flutter/material.dart';
import '../../Theme/sphere_neomorphic.dart';

// Alternative version with more customization
class CustomNeomorphicNavBar extends StatelessWidget {
  final Color color;
  final List<NeomorphicSphere> sphereItems;
  final double height;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final bool floating;

  const CustomNeomorphicNavBar({
    super.key,
    required this.color,
    required this.sphereItems,
    this.height = 80,
    this.borderRadius = 30,
    this.horizontalPadding = 20,
    this.verticalPadding = 10,
    this.floating = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      height: height,
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Bottom right shadow
          BoxShadow(
            color: Colors.black.withValues(alpha:0.15),
            blurRadius: 15,
            offset: const Offset(5, 5),
            spreadRadius: 1,
          ),
          // Top left light
          BoxShadow(
            color: Colors.white.withValues(alpha:0.6),
            blurRadius: 15,
            offset: const Offset(-5, -5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: sphereItems.map((sphere) {
          return Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: sphere,
            ),
          );
        }).toList(),
      ),
    );

    if (floating) {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: container,
      );
    } else {
      return container;
    }
  }
}

