import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_color.dart';
import '../utils/helpers/themes_helpers.dart';
import 'app_theme.dart';

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
  final UserGender? userGender;
  final bool isDarkMode;

  const GlassSliverAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.backgroundColor = AppColor.trans,
    this.textColor = AppColor.charcoal,
    this.gradientColors,
    this.onBackPressed,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 120,
    this.collapsedHeight = kToolbarHeight,
    this.leading,
    this.userGender,
    this.isDarkMode = false,
  });

  @override
  State<GlassSliverAppBar> createState() => _GlassSliverAppBarState();
}

class _GlassSliverAppBarState extends State<GlassSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: false,
      backgroundColor: widget.isDarkMode
          ? AppColor.darkBackground.withValues(alpha:0.9)
          : AppColor.white.withValues(alpha:0.9),
      elevation: 0,
      leading:
          widget.leading ?? (widget.showBackButton ? _buildBackButton() : null),
      actions: widget.actions,
      pinned: widget.pinned,
      floating: widget.floating,
      snap: widget.snap,
      expandedHeight: widget.expandedHeight,
      collapsedHeight: widget.collapsedHeight,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: widget.isDarkMode ? AppColor.darkText : AppColor.charcoal,
        size: 20,
      ),
      onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
