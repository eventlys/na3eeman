import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class BgIcon extends StatefulWidget {
  final String iconPath;
  final double blurLevel;
  final double size;
  final double rotationDegree;
  final Duration animationDuration;
  final Offset startPosition;
  final Offset endPosition;

  const BgIcon({
    Key? key,
    required this.iconPath,
    required this.blurLevel,
    required this.size,
    required this.rotationDegree,
    required this.animationDuration,
    required this.startPosition,
    required this.endPosition,
  }) : super(key: key);

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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.rotationDegree,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
                image: DecorationImage(
                  image: widget.iconPath.startsWith('http')
                      ? NetworkImage(widget.iconPath)
                      : AssetImage(widget.iconPath) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: widget.blurLevel > 0
                    ? ImageFilter.blur(
                  sigmaX: widget.blurLevel,
                  sigmaY: widget.blurLevel,
                )
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

