// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class ColorHelpers {
  const ColorHelpers._();

  static Color blendColors(Color color1, Color color2, double ratio) {
    final invRatio = 1.0 - ratio;
    return Color.fromARGB(
      255,
      (color1.red * invRatio + color2.red * ratio).round(),
      (color1.green * invRatio + color2.green * ratio).round(),
      (color1.blue * invRatio + color2.blue * ratio).round(),
    );
  }

  static List<Color> generateAnalogousColors(Color baseColor, {int count = 5}) {
    final hsl = HSLColor.fromColor(baseColor);
    final step = 30.0 / (count - 1);
    final colors = <Color>[];
    for (var i = 0; i < count; i++) {
      final hue = (hsl.hue + (i * step - (count - 1) * step / 2)) % 360;
      colors.add(hsl.withHue(hue).toColor());
    }
    return colors;
  }

  static List<Color> generateMonochromaticColors(
    Color baseColor, {
    int count = 5,
  }) {
    final hsl = HSLColor.fromColor(baseColor);
    final step = 1.0 / (count + 1);
    final colors = <Color>[];
    for (var i = 1; i <= count; i++) {
      final lightness = step * i;
      colors.add(hsl.withLightness(lightness).toColor());
    }
    return colors;
  }
}
