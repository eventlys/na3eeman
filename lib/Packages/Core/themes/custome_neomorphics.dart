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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size + 12,
      height: size + 12,
      decoration: BoxDecoration(
        color: isDark ? AppColor.darkCard : AppColor.paleGray,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: size, color: iconColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isDark ? AppColor.darkCard : AppColor.white,
        border: Border.all(
          color: isDark ? AppColor.ninjaDivider : AppColor.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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

enum NeomorphicSphereAnimationType { scale, slideUp }

class NeomorphicSphereState extends State<NeomorphicSphere>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  Brightness _getBrightness(BuildContext context) {
    return widget.brightness ?? Theme.of(context).brightness;
  }

  Color _getSphereColor(BuildContext context) {
    if (widget.sphereColor != null) return widget.sphereColor!;
    return AppColor.primaryOrange;
  }

  Color _getShadowColor(BuildContext context) {
    if (widget.shadowColor != null) return widget.shadowColor!;
    final brightness = _getBrightness(context);
    return brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.3)
        : AppColor.primaryOrange.withValues(alpha: 0.25);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _setupAnimations();

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  void _setupAnimations() {
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });

    widget.onTap?.call();

    if (widget.navigationRoute != null) {
      _handleNavigation(context);
    }

    if (!widget.isActive && widget.onActiveChanged != null) {
      widget.onActiveChanged!(true);
    }
  }

  void _handleNavigation(BuildContext context) {
    if (widget.isActive) {
      Navigator.pushReplacementNamed(
        context,
        widget.navigationRoute!,
        arguments: widget.navigationArguments,
      );
    } else {
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        switch (widget.animationType) {
          case NeomorphicSphereAnimationType.slideUp:
            return Transform.translate(
              offset: _slideAnimation.value,
              child: Opacity(opacity: _opacityAnimation.value, child: child),
            );
          case NeomorphicSphereAnimationType.scale:
            return Transform.scale(scale: _scaleAnimation.value, child: child);
        }
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: sphereColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: _isPressed ? 4 : 12,
              offset: const Offset(0, 4),
              spreadRadius: _isPressed ? -2 : 0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final currentIconPath = isActive
        ? widget.activeIconPath
        : widget.inactiveIconPath;
    final currentIconSize = isActive ? widget.iconSize + 10 : widget.iconSize;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _handleTap(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isActive) _buildAnimatedSphere(context),
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
