import 'package:flutter/material.dart';
import '../constants/app_color.dart';

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
        color: AppColor.lightCard.withValues(alpha: 0.70),
        shape: BoxShape.circle,
        boxShadow: [
          // Dark shadow
          BoxShadow(
            color: AppColor.dark.withValues(alpha: 0.2),
            blurRadius: depth * 2,
            offset: Offset(depth, depth),
          ),
          // Light shadow
          BoxShadow(
            color: AppColor.light.withValues(alpha: 0.8),
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
        color: AppColor.lightCard.withValues(alpha: 0.70),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withValues(alpha: 0.4), // Approximating 0x6699806C which is #806C99 with 40% opacity
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

class NeomorphicSphere extends StatefulWidget {
  final String activeIconPath;
  final String inactiveIconPath;
  final double size;
  final Color? sphereColor;
  final Color? shadowColor;
  final VoidCallback? onTap;
  final String? navigationRoute;
  final Map<String, dynamic>? navigationArguments;
  final double iconSize;
  final bool isActive;
  final ValueChanged<bool>? onActiveChanged;
  final bool shouldAnimate;
  final NeomorphicSphereAnimationType animationType;
  final Brightness? brightness;

  const NeomorphicSphere({
    super.key,
    required this.activeIconPath,
    required this.inactiveIconPath,
    this.size = 70,
    this.sphereColor,
    this.shadowColor,
    this.onTap,
    this.navigationRoute,
    this.navigationArguments,
    this.iconSize = 30,
    required this.isActive,
    this.onActiveChanged,
    this.shouldAnimate = true,
    this.animationType = NeomorphicSphereAnimationType.scale,
    this.brightness,
  });

  @override
  NeomorphicSphereState createState() => NeomorphicSphereState();
}

enum NeomorphicSphereAnimationType {
  scale,
  slideUp,
}

class NeomorphicSphereState extends State<NeomorphicSphere>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  // Helper method to get current theme brightness
  Brightness _getBrightness(BuildContext context) {
    return widget.brightness ?? Theme.of(context).brightness;
  }

  // Get sphere color based on theme
  Color _getSphereColor(BuildContext context) {
    if (widget.sphereColor != null) return widget.sphereColor!;
    
    final brightness = _getBrightness(context);
    return brightness == Brightness.dark 
        ? AppColor.darkPrimary 
        : AppColor.lightPrimary;
  }

  // Get shadow color based on theme
  Color _getShadowColor(BuildContext context) {
    if (widget.shadowColor != null) return widget.shadowColor!;
    
    final brightness = _getBrightness(context);
    return brightness == Brightness.dark 
        ? AppColor.dark.withValues(alpha: 0.4)
        : AppColor.dark.withValues(alpha: 0.2);
  }

  // Get pressed shadow color based on theme
  Color _getPressedShadowColor(BuildContext context) {
    final brightness = _getBrightness(context);
    return brightness == Brightness.dark 
        ? AppColor.dark.withValues(alpha: 0.1)
        : AppColor.dark.withValues(alpha: 0.05);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Setup animations based on type
    _setupAnimations();

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(NeomorphicSphere oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldAnimate) {
      if (widget.isActive && !oldWidget.isActive) {
        _animationController.forward();
      } else if (!widget.isActive && oldWidget.isActive) {
        _animationController.reverse();
      }
    } else {
      // Instant state change without animation
      if (widget.isActive) {
        _animationController.value = 1.0;
      } else {
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    // Handle press feedback
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });

    // Execute custom onTap callback if provided
    widget.onTap?.call();

    // Handle navigation if route provided
    if (widget.navigationRoute != null) {
      _handleNavigation(context);
    }

    // Notify parent about active state change if callback provided
    if (!widget.isActive && widget.onActiveChanged != null) {
      widget.onActiveChanged!(true);
    }
  }

  void _handleNavigation(BuildContext context) {
    if (widget.isActive) {
      // If already active, refresh/replace current route
      Navigator.pushReplacementNamed(
        context,
        widget.navigationRoute!,
        arguments: widget.navigationArguments,
      );
    } else {
      // If not active, navigate to new route
      if (widget.navigationArguments != null) {
        Navigator.pushNamed(
          context,
          widget.navigationRoute!,
          arguments: widget.navigationArguments,
        );
      } else {
        Navigator.pushNamed(context, widget.navigationRoute!);
      }
    }
  }

  Widget _buildAnimatedSphere(BuildContext context) {
    final sphereColor = _getSphereColor(context);
    final shadowColor = _getShadowColor(context);
    final pressedShadowColor = _getPressedShadowColor(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        switch (widget.animationType) {
          case NeomorphicSphereAnimationType.slideUp:
            return Transform.translate(
              offset: _slideAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          case NeomorphicSphereAnimationType.scale:
          default:
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
        }
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: ShapeDecoration(
          color: sphereColor,
          shape: const OvalBorder(),
          shadows: _isPressed
              ? [
                  BoxShadow(
                    color: pressedShadowColor,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 15,
                    offset: const Offset(4, 4),
                    spreadRadius: 1,
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final currentIconPath = isActive ? widget.activeIconPath : widget.inactiveIconPath;
    final currentIconSize = isActive ? widget.iconSize + 10 : widget.iconSize;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _handleTap(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Neomorphic Sphere (only visible when active)
          if (isActive) _buildAnimatedSphere(context),

          // Icon (always visible)
          Image.asset(
            currentIconPath,
            width: currentIconSize,
            height: currentIconSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

