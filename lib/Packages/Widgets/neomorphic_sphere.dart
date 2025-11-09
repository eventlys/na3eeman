import 'package:flutter/material.dart';

class NeomorphicSphere extends StatefulWidget {
  final String activeIconPath;
  final String inactiveIconPath;
  final double size;
  final Color sphereColor;
  final Color shadowColor;
  final VoidCallback onTap;
  final double iconSize;
  final bool isActive;
  final bool shouldAnimate;

  const NeomorphicSphere({
    super.key,
    required this.activeIconPath,
    required this.inactiveIconPath,
    this.size = 70,
    this.sphereColor = const Color(0xFFDFA8A4),
    this.shadowColor = const Color(0x80242424),
    required this.onTap,
    this.iconSize = 30,
    required this.isActive,
    this.shouldAnimate = false,
  });

  @override
  _NeomorphicSphereState createState() => _NeomorphicSphereState();
}

class _NeomorphicSphereState extends State<NeomorphicSphere>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    if (widget.isActive) {
      _animationController.forward();
    }
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

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;
    final currentIconPath = isActive ? widget.activeIconPath : widget.inactiveIconPath;
    final currentIconSize = isActive ? widget.iconSize + 10 : widget.iconSize;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Neomorphic Sphere (only visible when active)
          if (isActive)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
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
                          BoxShadow(
                            color: widget.shadowColor.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                            spreadRadius: -2,
                          ),
                        ]
                      : [
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

