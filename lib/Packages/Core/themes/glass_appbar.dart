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
    this.textColor = AppColor.light,
    this.gradientColors,
    this.onBackPressed,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 200,
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
    final gradientColors = widget.gradientColors ?? _getGenderGradientColors();

    return SliverAppBar(
      centerTitle: true,
      backgroundColor: AppColor.trans,
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
      icon: Icon(Icons.arrow_back, color: _getIconColor()),
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
            color: AppColor.trans,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGenderGradientColors() {
    if (widget.userGender != null) {
      switch (widget.userGender) {
        case UserGender.male:
          return widget.isDarkMode
              ? [AppColor.darkMaleBG.withValues(alpha: 0.3), AppColor.darkMaleBackground.withValues(alpha: 0.6)]
              : [AppColor.lightMaleBG.withValues(alpha: 0.3), AppColor.maleBackground.withValues(alpha: 0.6)];
        case UserGender.female:
          return widget.isDarkMode
              ? [AppColor.darkFemaleBG.withValues(alpha: 0.3), AppColor.darkFemaleBackground.withValues(alpha: 0.6)]
              : [AppColor.lightFemaleBG.withValues(alpha: 0.3), AppColor.femaleBackground.withValues(alpha: 0.6)];
        case UserGender.nonBinary:
          return widget.isDarkMode
              ? [AppColor.darkNonBinaryBG.withValues(alpha: 0.3), AppColor.darkNonBinaryBackground.withValues(alpha: 0.6)]
              : [AppColor.lightNonBinaryBG.withValues(alpha: 0.3), AppColor.nonBinaryBackground.withValues(alpha: 0.6)];
        default:
          return _getDefaultGradientColors();
      }
    }
    return _getDefaultGradientColors();
  }

  List<Color> _getDefaultGradientColors() {
    return widget.isDarkMode
        ? [AppColor.darkPrimary.withValues(alpha: 0.3), AppColor.darkSecondary.withValues(alpha: 0.6)]
        : [AppColor.lightPrimary.withValues(alpha: 0.3), AppColor.lightSecondary.withValues(alpha: 0.6)];
  }

  Color _getIconColor() {
    if (widget.userGender != null) {
      switch (widget.userGender) {
        case UserGender.male:
          return widget.isDarkMode ? AppColor.maleAccent : AppColor.maleAccent;
        case UserGender.female:
          return widget.isDarkMode ? AppColor.femaleAccent : AppColor.femaleAccent;
        case UserGender.nonBinary:
          return widget.isDarkMode ? AppColor.nonBinaryAccent : AppColor.nonBinaryAccent;
        default:
          return widget.isDarkMode ? AppColor.darkText : AppColor.lightText;
      }
    }
    return widget.isDarkMode ? AppColor.darkText : AppColor.lightText;
  }

  Color _getTextColor() {
    if (widget.userGender != null) {
      switch (widget.userGender) {
        case UserGender.male:
          return widget.isDarkMode ? AppColor.maleAccent : AppColor.maleAccent;
        case UserGender.female:
          return widget.isDarkMode ? AppColor.femaleAccent : AppColor.femaleAccent;
        case UserGender.nonBinary:
          return widget.isDarkMode ? AppColor.nonBinaryAccent : AppColor.nonBinaryAccent;
        default:
          return widget.isDarkMode ? AppColor.darkText : AppColor.lightText;
      }
    }
    return widget.textColor;
  }
}
