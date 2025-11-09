import 'package:flutter/material.dart';
import 'package:na3eeman/features/sidebar/widgets/sidebar_item.dart';
import '../../../Helpers/animations.dart';
import '../../../Models/menu_item_model.dart';

class AnimatedSidebarItem extends StatelessWidget {
  final MenuItem item;
  final Animation<double> animation;
  final int delay;
  final Color backgroundColor;
  final Color textColor;
  final double iconSize;

  const AnimatedSidebarItem({
    super.key,
    required this.item,
    required this.animation,
    required this.delay,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.black,
    this.iconSize = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            -100 + (animation.value * 100),
            0,
          ),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: DelayedWidget(
        delay: Duration(milliseconds: 200 + (delay * 50)),
        child: SidebarItem(
          title: item.title,
          icon: item.icon,
          assetIcon: item.assetIcon,
          onTap: item.onTap,
          backgroundColor: backgroundColor,
          textColor: textColor,
          iconSize: iconSize,
        ),
      ),
    );
  }
}

