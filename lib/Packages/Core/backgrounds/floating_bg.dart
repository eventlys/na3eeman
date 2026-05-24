import 'package:flutter/material.dart';
import 'dart:math';

import '../constants/app_color.dart';
import '../constants/app_images.dart'; // Updated import
import 'bg_circle.dart';
import 'bg_icon.dart';

class FloatingBackground extends StatefulWidget {
  final int? objectCount; // Made optional since we're generating random count
  final List<BgObjectConfig>? objectConfigs;
  final Widget child;
  final String objectType; // 'icons', 'circles', or 'mixed'
  final List<String>? iconPaths; // List of icon paths for auto-generation
  final List<Color>?
  colors; // Optional custom colors (uses AppColor by default)
  final double minSize; // Minimum size for random generation
  final double maxSize; // Maximum size for random generation
  final bool useAppColors; // Whether to use app color system
  final double maxOverlapRatio; // Maximum allowed overlap ratio (0.0 to 1.0)

  const FloatingBackground({
    super.key,
    this.objectCount,
    this.objectConfigs,
    required this.child,
    required this.objectType,
    this.iconPaths,
    this.colors, // Optional custom colors
    this.minSize = 30.0,
    this.maxSize = 150.0,
    this.useAppColors = true,
    this.maxOverlapRatio = 0.3, // 30% maximum overlap
  });

  @override
  FloatingBackgroundState createState() => FloatingBackgroundState();
}

class FloatingBackgroundState extends State<FloatingBackground> {
  late List<BgObjectConfig> _objectConfigs;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _objectConfigs = widget.objectConfigs ?? _generateObjectsWithConstraints();
  }

  List<BgObjectConfig> _generateObjectsWithConstraints() {
    final List<BgObjectConfig> configs = [];

    // Generate random number of objects between 8 and 12
    final int count = widget.objectCount ?? (8 + _random.nextInt(5)); // 8 to 12

    final screenWidth = 1.0; // Normalized width
    final screenHeight = 1.0; // Normalized height

    for (int i = 0; i < count; i++) {
      bool positionValid = false;
      int attempts = 0;
      final int maxAttempts = 50; // Prevent infinite loop

      late BgObjectConfig newConfig;
      late Rect newRect;

      while (!positionValid && attempts < maxAttempts) {
        attempts++;

        // Generate random configuration
        if (widget.objectType == 'icons') {
          final iconPath = _getRandomIconPath(widget.iconPaths);
          final size = _getRandomSize();
          final (startPosition, endPosition) = _getRandomPositions();

          newConfig = BgObjectConfig(
            objectType: 'icons',
            iconPath: iconPath,
            color: Colors.transparent,
            blurLevel: _random.nextDouble() * 5.0,
            size: size,
            rotationDegree: _random.nextDouble() * 360,
            animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
            startPosition: startPosition,
            endPosition: endPosition,
          );
        } else if (widget.objectType == 'circles') {
          final color = _getRandomColor();
          final size = _getRandomSize();
          final (startPosition, endPosition) = _getRandomPositions();

          newConfig = BgObjectConfig(
            objectType: 'circles',
            iconPath: '',
            color: color,
            blurLevel: _random.nextDouble() * 5.0,
            size: size,
            rotationDegree: _random.nextDouble() * 360,
            animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
            startPosition: startPosition,
            endPosition: endPosition,
          );
        } else {
          // mixed
          final isIcon = _random.nextBool();
          final size = _getRandomSize();
          final (startPosition, endPosition) = _getRandomPositions();

          if (isIcon) {
            final iconPath = _getRandomIconPath(widget.iconPaths);
            newConfig = BgObjectConfig(
              objectType: 'icons',
              iconPath: iconPath,
              color: Colors.transparent,
              blurLevel: _random.nextDouble() * 5.0,
              size: size,
              rotationDegree: _random.nextDouble() * 360,
              animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
              startPosition: startPosition,
              endPosition: endPosition,
            );
          } else {
            final color = _getRandomColor();
            newConfig = BgObjectConfig(
              objectType: 'circles',
              iconPath: '',
              color: color,
              blurLevel: _random.nextDouble() * 5.0,
              size: size,
              rotationDegree: _random.nextDouble() * 360,
              animationDuration: Duration(seconds: 10 + _random.nextInt(20)),
              startPosition: startPosition,
              endPosition: endPosition,
            );
          }
        }

        // Calculate the rectangle for the new object (using start position)
        final startX = 0.5 + newConfig.startPosition.dx * 0.5;
        final startY = 0.5 + newConfig.startPosition.dy * 0.5;
        final normalizedSize = newConfig.size / 1000; // Normalize size

        newRect = Rect.fromCenter(
          center: Offset(startX, startY),
          width: normalizedSize,
          height: normalizedSize,
        );

        // Check if within screen bounds
        if (newRect.left < 0 ||
            newRect.right > screenWidth ||
            newRect.top < 0 ||
            newRect.bottom > screenHeight) {
          continue; // Try again if outside bounds
        }

        // Check overlap with existing objects
        bool hasExcessiveOverlap = false;
        for (final existingConfig in configs) {
          final existingStartX = 0.5 + existingConfig.startPosition.dx * 0.5;
          final existingStartY = 0.5 + existingConfig.startPosition.dy * 0.5;
          final existingNormalizedSize = existingConfig.size / 1000;

          final existingRect = Rect.fromCenter(
            center: Offset(existingStartX, existingStartY),
            width: existingNormalizedSize,
            height: existingNormalizedSize,
          );

          final intersection = newRect.intersect(existingRect);
          if (intersection != Rect.zero) {
            final newArea = newRect.width * newRect.height;
            final existingArea = existingRect.width * existingRect.height;
            final intersectionArea = intersection.width * intersection.height;

            // Calculate overlap ratio for both objects
            final overlapWithNew = intersectionArea / newArea;
            final overlapWithExisting = intersectionArea / existingArea;

            // If overlap exceeds maximum allowed ratio for either object, reject
            if (overlapWithNew > widget.maxOverlapRatio ||
                overlapWithExisting > widget.maxOverlapRatio) {
              hasExcessiveOverlap = true;
              break;
            }
          }
        }

        if (!hasExcessiveOverlap) {
          positionValid = true;
        }
      }

      if (positionValid) {
        configs.add(newConfig);
      }
      // If position not valid after max attempts, skip this object
    }

    return configs;
  }

  double _getRandomSize() {
    return widget.minSize +
        _random.nextDouble() * (widget.maxSize - widget.minSize);
  }

  (Offset, Offset) _getRandomPositions() {
    // Reduced range to keep objects more centered and within bounds
    final startX =
        (_random.nextDouble() - 0.5) * 1.5; // Reduced from 2.0 to 1.5
    final startY = (_random.nextDouble() - 0.5) * 1.5;
    final endX = (_random.nextDouble() - 0.5) * 1.5;
    final endY = (_random.nextDouble() - 0.5) * 1.5;

    return (Offset(startX, startY), Offset(endX, endY));
  }

  String _getRandomIconPath(List<String>? customIconPaths) {
    if (customIconPaths != null && customIconPaths.isNotEmpty) {
      return customIconPaths[_random.nextInt(customIconPaths.length)];
    }

    // Use app icons from AppImages
    final appIcons = [
      AppImages.scissor,
      AppImages.scissors,
      AppImages.scissors1,
      AppImages.scissors2,
      AppImages.chair,
      AppImages.comb,
      AppImages.razor,
      AppImages.mirror,
      AppImages.admin,
      AppImages.staff,
      AppImages.heart,
      AppImages.star,
      AppImages.money,
      AppImages.calender,
      AppImages.clock,
      AppImages.phone,
      AppImages.mail,
      AppImages.location,
      AppImages.camera,
      AppImages.settings,
    ].where((path) => path.isNotEmpty).toList();

    if (appIcons.isNotEmpty) {
      return appIcons[_random.nextInt(appIcons.length)];
    }

    // Fallback to placeholder
    return AppImages.placeholderImage;
  }

  Color _getRandomColor() {
    // Use custom colors if provided
    if (widget.colors != null && widget.colors!.isNotEmpty) {
      return widget.colors![_random.nextInt(widget.colors!.length)];
    }

    // Use AppColor system by default
    final appColors = [
      AppColor.primary.withValues(alpha: 0.3),
      AppColor.secondary.withValues(alpha: 0.3),
      AppColor.lightPrimary.withValues(alpha: 0.3),
      AppColor.lightSecondary.withValues(alpha: 0.3),
      AppColor.lightAccent.withValues(alpha: 0.3),
      AppColor.lightExpert.withValues(alpha: 0.3),
      AppColor.lightManager.withValues(alpha: 0.3),
      AppColor.lightAssistant.withValues(alpha: 0.3),
      AppColor.lightReceptionist.withValues(alpha: 0.3),
      AppColor.maleAccent.withValues(alpha: 0.3),
      AppColor.femaleAccent.withValues(alpha: 0.3),
      AppColor.nonBinaryAccent.withValues(alpha: 0.3),
      AppColor.lightInfo.withValues(alpha: 0.3),
      AppColor.lightSuccess.withValues(alpha: 0.3),
      AppColor.lightWarning.withValues(alpha: 0.3),
      AppColor.darkPrimary.withValues(alpha: 0.3),
      AppColor.darkSecondary.withValues(alpha: 0.3),
      AppColor.darkAccent.withValues(alpha: 0.3),
      AppColor.loadingPrimaryLight.withValues(alpha: 0.3),
      AppColor.loadingSecondaryLight.withValues(alpha: 0.3),
    ];

    return appColors[_random.nextInt(appColors.length)];
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
              final startX =
                  screenWidth / 2 + config.startPosition.dx * screenWidth / 2;
              final startY =
                  screenHeight / 2 + config.startPosition.dy * screenHeight / 2;

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
