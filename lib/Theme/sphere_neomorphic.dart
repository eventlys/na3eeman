import 'package:flutter/material.dart';

class NeomorphicSphere extends StatefulWidget {
  final String activeIconPath;
  final String inactiveIconPath;
  final double size;
  final Color sphereColor;
  final Color shadowColor;
  final VoidCallback? onTap;
  final String? navigationRoute;
  final Map<String, dynamic>? navigationArguments;
  final double iconSize;
  final bool isActive;
  final ValueChanged<bool>? onActiveChanged; // Callback when active state changes

  const NeomorphicSphere({
    super.key,
    required this.activeIconPath,
    required this.inactiveIconPath,
    this.size = 70,
    this.sphereColor = const Color(0xFFDFA8A4),
    this.shadowColor = const Color(0x80242424),
    this.onTap,
    this.navigationRoute,
    this.navigationArguments,
    this.iconSize = 30,
    this.isActive = false,
    this.onActiveChanged,
  });

  @override
  _NeomorphicSphereState createState() => _NeomorphicSphereState();
}

class _NeomorphicSphereState extends State<NeomorphicSphere> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Slide up from bottom
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

    // Start animation if initially active
    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(NeomorphicSphere oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when active state changes
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    if (widget.isActive) {
      // If already active, just show press feedback and refresh/redirect
      setState(() => _isPressed = true);
      Future.delayed(const Duration(milliseconds: 150), () {
        setState(() => _isPressed = false);
      });

      // Execute custom onTap callback if provided
      widget.onTap?.call();

      // Refresh current page or navigate to same route
      if (widget.navigationRoute != null) {
        Navigator.pushReplacementNamed(
          context,
          widget.navigationRoute!,
          arguments: widget.navigationArguments,
        );
      }
    } else {
      // If not active, become active and navigate
      widget.onActiveChanged?.call(true);

      // Execute custom onTap callback if provided
      widget.onTap?.call();

      // Navigate to new page if route provided
      if (widget.navigationRoute != null) {
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
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final currentIconPath = isActive ? widget.activeIconPath : widget.inactiveIconPath;
    final currentIconSize = isActive ? widget.iconSize + 20 : widget.iconSize; // +20 when active

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _handleTap(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Neomorphic Sphere (only visible when active)
          if (isActive) ...[
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _slideAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: ShapeDecoration(
                  color: widget.sphereColor,
                  shape: const OvalBorder(),
                  shadows: _isPressed
                      ? [
                    // Inset shadow effect when pressed
                    BoxShadow(
                      color: widget.shadowColor.withValues(alpha:0.2),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                      spreadRadius: -2,
                    ),
                  ]
                      : [
                    // Outer shadow for neomorphic effect
                    BoxShadow(
                      color: widget.shadowColor,
                      blurRadius: 15,
                      offset: const Offset(4, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Icon (always visible)
          Image.asset(
            currentIconPath,
            width: currentIconSize,
            height: currentIconSize,
            fit: BoxFit.contain,
            // No color filter applied - original colors
          ),
        ],
      ),
    );
  }
}

