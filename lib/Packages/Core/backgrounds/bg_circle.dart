import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class BgCircle extends StatefulWidget {
  final Color color;
  final double blurLevel;
  final double size;
  final double rotationDegree;
  final Duration animationDuration;
  final Offset startPosition;
  final Offset endPosition;

  const BgCircle({
    super.key,
    required this.color,
    required this.blurLevel,
    required this.size,
    required this.rotationDegree,
    required this.animationDuration,
    required this.startPosition,
    required this.endPosition,
  });

  @override
  BgCircleState createState() => BgCircleState();
}

class BgCircleState extends State<BgCircle>
    with SingleTickerProviderStateMixin {
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
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
              child: BackdropFilter(
                filter: widget.blurLevel > 0
                    ? ImageFilter.blur(
                        sigmaX: widget.blurLevel,
                        sigmaY: widget.blurLevel,
                      )
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        );
      },
    );
  }
}
