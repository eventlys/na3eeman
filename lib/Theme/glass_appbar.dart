import 'package:flutter/material.dart';
import 'dart:ui';

class GlassSliverAppBar extends StatefulWidget {
  final String title;
  final bool showBackButton;
  final Color backgroundColor;
  final Color textColor;
  final List<Color>? gradientColors;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;
  final double collapsedHeight;
  final Widget? leading;

  const GlassSliverAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.white,
    this.gradientColors,
    this.onBackPressed,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 200,
    this.collapsedHeight = kToolbarHeight,
    this.leading,
  });

  @override
  State<GlassSliverAppBar> createState() => _GlassSliverAppBarState();
}

class _GlassSliverAppBarState extends State<GlassSliverAppBar> {

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ?? [
      const Color(0x3fffffff),
      const Color(0xE6DFA8A4),
    ];

    return SliverAppBar(
      // title: _buildCollapsedTitle(),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: widget.leading ?? (widget.showBackButton ? _buildBackButton() : null),
      actions: widget.actions,
      pinned: widget.pinned,
      floating: widget.floating,
      snap: widget.snap,
      expandedHeight: widget.expandedHeight,
      collapsedHeight: widget.collapsedHeight,
      flexibleSpace: _buildFlexibleSpace(gradientColors),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
    );
  }

  Widget _buildFlexibleSpace(List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0],
            gradientColors.length > 1 ? gradientColors[1] : gradientColors[0],
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Color _getColorWithSafeOpacity(Color color, double opacity) {
  //   final safeOpacity = opacity.clamp(0.0, 1.0);
  //   return color.withValues(alpha: safeOpacity);
  // }
}
