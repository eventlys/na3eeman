import 'package:flutter/material.dart';
import 'bg_icon.dart';
import 'bg_circle.dart';
import 'dart:math';

class FloatingBackground extends StatefulWidget {
  final int objectCount;
  final List<BgObjectConfig>? objectConfigs;
  final Widget child;
  final String objectType; // 'icons', 'circles', or 'mixed'
  final List<String>? iconPaths; // List of icon paths for auto-generation
  final List<Color>? colors; // List of colors for auto-generation
  final double minSize; // Minimum size for random generation
  final double maxSize; // Maximum size for random generation

  const FloatingBackground({
    Key? key,
    required this.objectCount,
    this.objectConfigs,
    required this.child,
    required this.objectType,
    this.iconPaths,
    this.colors,
    this.minSize = 30.0,
    this.maxSize = 150.0,
  }) : super(key: key);

  @override
  FloatingBackgroundState createState() => FloatingBackgroundState();
}

class FloatingBackgroundState extends State<FloatingBackground> {
  late List<BgObjectConfig> _objectConfigs;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _objectConfigs = widget.objectConfigs ?? _generateDefaultObjects(widget.objectCount);
  }

  List<BgObjectConfig> _generateDefaultObjects(int count) {
    final List<BgObjectConfig> configs = [];

    for (int i = 0; i < count; i++) {
      if (widget.objectType == 'icons') {
        final iconPath = _getRandomIconPath(widget.iconPaths);
        final size = _getRandomSize();
        final (startPosition, endPosition) = _getRandomPositions();

        configs.add(BgObjectConfig(
          objectType: 'icons',
          iconPath: iconPath,
          color: Colors.transparent,
          blurLevel: _random.nextDouble() * 5.0,
          size: size,
          rotationDegree: _random.nextDouble() * 360,
          animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
          startPosition: startPosition,
          endPosition: endPosition,
        ));
      } else if (widget.objectType == 'circles') {
        final color = _getRandomColor(widget.colors);
        final size = _getRandomSize();
        final (startPosition, endPosition) = _getRandomPositions();

        configs.add(BgObjectConfig(
          objectType: 'circles',
          iconPath: '',
          color: color,
          blurLevel: _random.nextDouble() * 5.0,
          size: size,
          rotationDegree: _random.nextDouble() * 360,
          animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
          startPosition: startPosition,
          endPosition: endPosition,
        ));
      } else if (widget.objectType == 'mixed') {
        final isIcon = _random.nextBool();
        final size = _getRandomSize();
        final (startPosition, endPosition) = _getRandomPositions();

        if (isIcon) {
          final iconPath = _getRandomIconPath(widget.iconPaths);
          configs.add(BgObjectConfig(
            objectType: 'icons',
            iconPath: iconPath,
            color: Colors.transparent,
            blurLevel: _random.nextDouble() * 5.0,
            size: size,
            rotationDegree: _random.nextDouble() * 360,
            animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
            startPosition: startPosition,
            endPosition: endPosition,
          ));
        } else {
          final color = _getRandomColor(widget.colors);
          configs.add(BgObjectConfig(
            objectType: 'circles',
            iconPath: '',
            color: color,
            blurLevel: _random.nextDouble() * 5.0,
            size: size,
            rotationDegree: _random.nextDouble() * 360,
            animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
            startPosition: startPosition,
            endPosition: endPosition,
          ));
        }
      }
    }
    return configs;
  }

  double _getRandomSize() {
    return widget.minSize + _random.nextDouble() * (widget.maxSize - widget.minSize);
  }

  (Offset, Offset) _getRandomPositions() {
    // Generate random positions within the screen bounds
    // Using values between -0.5 and 0.5 to allow objects to go partially off-screen
    final startX = (_random.nextDouble() - 0.5) * 2.0; // -1.0 to 1.0
    final startY = (_random.nextDouble() - 0.5) * 2.0;
    final endX = (_random.nextDouble() - 0.5) * 2.0;
    final endY = (_random.nextDouble() - 0.5) * 2.0;

    return (
    Offset(startX, startY),
    Offset(endX, endY)
    );
  }

  String _getRandomIconPath(List<String>? customIconPaths) {
    if (customIconPaths != null && customIconPaths.isNotEmpty) {
      return customIconPaths[_random.nextInt(customIconPaths.length)];
    }

    final defaultIcons = [
      "https://placehold.co/100x100/FF6B6B/FFFFFF?text=1",
      "https://placehold.co/100x100/4ECDC4/FFFFFF?text=2",
      "https://placehold.co/100x100/45B7D1/FFFFFF?text=3",
      "https://placehold.co/100x100/96CEB4/FFFFFF?text=4",
      "https://placehold.co/100x100/FFEAA7/FFFFFF?text=5",
    ];
    return defaultIcons[_random.nextInt(defaultIcons.length)];
  }

  Color _getRandomColor(List<Color>? customColors) {
    if (customColors != null && customColors.isNotEmpty) {
      return customColors[_random.nextInt(customColors.length)];
    }

    final defaultColors = [
      Colors.red.withValues(alpha: 0.3),
      Colors.blue.withValues(alpha: 0.3),
      Colors.green.withValues(alpha: 0.3),
      Colors.purple.withValues(alpha: 0.3),
      Colors.orange.withValues(alpha: 0.3),
      Colors.teal.withValues(alpha: 0.3),
      Colors.pink.withValues(alpha: 0.3),
    ];
    return defaultColors[_random.nextInt(defaultColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background layer with floating objects
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: _objectConfigs.map((config) {
              // Convert fractional positions to absolute positions
              final startX = screenWidth / 2 + config.startPosition.dx * screenWidth;
              final startY = screenHeight / 2 + config.startPosition.dy * screenHeight;

              return Positioned(
                left: startX - config.size / 2,
                top: startY - config.size / 2,
                child: _buildObject(config),
              );
            }).toList(),
          ),
        ),

        // Your content on top
        widget.child,
      ],
    );
  }

  Widget _buildObject(BgObjectConfig config) {
    if (config.objectType == 'icons') {
      return BgIcon(
        iconPath: config.iconPath,
        blurLevel: config.blurLevel,
        size: config.size,
        rotationDegree: config.rotationDegree,
        animationDuration: config.animationDuration,
        startPosition: config.startPosition,
        endPosition: config.endPosition,
      );
    } else if (config.objectType == 'circles') {
      return BgCircle(
        color: config.color,
        blurLevel: config.blurLevel,
        size: config.size,
        rotationDegree: config.rotationDegree,
        animationDuration: config.animationDuration,
        startPosition: config.startPosition,
        endPosition: config.endPosition,
      );
    } else {
      return BgIcon(
        iconPath: config.iconPath,
        blurLevel: config.blurLevel,
        size: config.size,
        rotationDegree: config.rotationDegree,
        animationDuration: config.animationDuration,
        startPosition: config.startPosition,
        endPosition: config.endPosition,
      );
    }
  }
}

class BgObjectConfig {
  final String objectType; // 'icons' or 'circles'
  final String iconPath; // Used for icons
  final Color color; // Used for circles
  final double blurLevel;
  final double size;
  final double rotationDegree;
  final Duration animationDuration;
  final Offset startPosition;
  final Offset endPosition;

  BgObjectConfig({
    required this.objectType,
    required this.iconPath,
    required this.color,
    required this.blurLevel,
    required this.size,
    required this.rotationDegree,
    required this.animationDuration,
    required this.startPosition,
    required this.endPosition,
  });
}
