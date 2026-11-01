import 'package:flutter/material.dart';
import 'dart:math';

class BgIcon extends StatefulWidget {
  final IconData icon;
  final double blurLevel;
  final double size;
  final double rotationDegree;
  final Duration animationDuration;
  final Offset startPosition;
  final Offset endPosition;

  const BgIcon({
    super.key,
    required this.icon,
    required this.blurLevel,
    required this.size,
    required this.rotationDegree,
    required this.animationDuration,
    required this.startPosition,
    required this.endPosition,
  });

  @override
  BgIconState createState() => BgIconState();
}

class BgIconState extends State<BgIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.rotationDegree,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _positionAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * (pi / 180),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Icon(
                widget.icon,
                size: widget.size * 0.6,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
        );
      },
    );
  }
}
