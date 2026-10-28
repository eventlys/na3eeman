import 'package:flutter/material.dart';

/// A lightweight one-shot entrance animation: fades in while sliding up slightly.
///
/// Use for list items and cards. [index] drives a staggered delay
/// (`index * interval`), capped so deep lists don't lag. The animation runs once
/// on mount and does not rebuild afterwards, so it's cheap on scroll.
class FadeSlideIn extends StatefulWidget {
  final Widget child;

  /// Position in the list — used to stagger the entrance.
  final int index;

  /// Delay between consecutive items.
  final Duration interval;

  /// Total duration of a single item's entrance.
  final Duration duration;

  /// Vertical slide offset (fraction of the child's height) to animate from.
  final double slideOffset;

  /// Max items that get staggered; beyond this all animate immediately.
  final int maxStaggeredItems;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.interval = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 350),
    this.slideOffset = 0.15,
    this.maxStaggeredItems = 12,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final staggerIndex = widget.index.clamp(0, widget.maxStaggeredItems);
    final delay = widget.interval * staggerIndex;

    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Convenience wrapper that maps a list of children into staggered
/// [FadeSlideIn] entrances. Drop-in for a Column/ListView children list.
class StaggeredFadeSlideList extends StatelessWidget {
  final List<Widget> children;
  final Duration interval;
  final Duration duration;

  const StaggeredFadeSlideList({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          FadeSlideIn(
            index: i,
            interval: interval,
            duration: duration,
            child: children[i],
          ),
      ],
    );
  }
}
