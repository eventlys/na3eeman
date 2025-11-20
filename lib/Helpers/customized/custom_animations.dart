import 'package:flutter/material.dart';

class CustomAnimations {
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  static Curve get easeInOut => Curves.easeInOut;
  static Curve get elasticOut => Curves.elasticOut;
  static Curve get bounceOut => Curves.bounceOut;

  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0, 0.5, curve: easeInOut),
      ),
    );
  }

  static Animation<double> slideUp(AnimationController controller) {
    return Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.3, 1, curve: easeInOut),
      ),
    );
  }

  static Animation<double> scale(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: easeInOut,
      ),
    );
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offset;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = CustomAnimations.mediumDuration,
    this.curve = Curves.easeInOut,
    this.offset = 20,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _offset = Tween<double>(begin: widget.offset, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _controller.forward();
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
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _offset.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class StaggeredListView extends StatelessWidget {
  final List<Widget> children;
  final Duration delayBetweenItems;

  const StaggeredListView({
    super.key,
    required this.children,
    this.delayBetweenItems = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return FadeInWidget(
          duration: CustomAnimations.mediumDuration,
          offset: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: children[index],
          ),
        );
      },
    );
  }
}

class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = CustomAnimations.mediumDuration,
    this.scale = 1.1,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scale = Tween<double>(
      begin: 1,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  void bounce() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: bounce,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
