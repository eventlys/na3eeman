import 'package:flutter/material.dart';

class AnimationHelpers {
  const AnimationHelpers._();

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  static Duration staggeredDelay(int index, {Duration baseDelay = const Duration(milliseconds: 100)}) {
    return baseDelay * index;
  }

  static double calculateParallaxOffset(ScrollMetrics position, double extent, double cardHeight) {
    return -((position.pixels - extent) / cardHeight);
  }
}
