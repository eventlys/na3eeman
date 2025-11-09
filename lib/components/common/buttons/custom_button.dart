import 'package:flutter/material.dart';
import 'package:neumorphic_button/neumorphic_button.dart';

class CustomNeumorphicButton extends StatelessWidget {
  final Color color;

  final String text;
  final bool showText;

  final IconData leftIcon;
  final bool showLeftIcon;

  final IconData rightIcon;
  final bool showRightIcon;

  final bool isActive;
  final VoidCallback? onTap;

  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  final double width;

  const CustomNeumorphicButton({
    super.key,
    required this.color,
    /*required this.height,*/
    required this.width,
    this.text = '',
    this.showText = true,
    this.leftIcon = Icons.arrow_back,
    this.showLeftIcon = false,
    this.rightIcon = Icons.arrow_forward,
    this.showRightIcon = false,
    this.isActive = true,
    this.onTap,
    this.borderRadius = 12,
    this.borderWidth = 5,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onTap: isActive ? onTap ?? () {} : () {},
      borderRadius: borderRadius,
      bottomRightShadowBlurRadius: 10,
      bottomRightShadowSpreadRadius: 1,
      borderWidth: borderWidth,
      backgroundColor: color,
      topLeftShadowBlurRadius: 10,
      topLeftShadowSpreadRadius: 1,
      topLeftShadowColor: Colors.white,
      bottomRightShadowColor: Colors.grey.shade500,
      padding: padding as EdgeInsets,
      bottomRightOffset: const Offset(4, 4),
      topLeftOffset: const Offset(-4, -4),
      height: 65,
      width: width,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final List<Widget> children = [];

    // Add left icon if enabled
    if (showLeftIcon) {
      children.add(
        Icon(
          leftIcon,
          color: _getIconColor(),
        ),
      );
    }

    // Add text if enabled
    if (showText && text.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            text,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Add right icon if enabled
    if (showRightIcon) {
      children.add(
        Icon(
          rightIcon,
          color: _getIconColor(),
        ),
      );
    }

    // Handle empty content case
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Color _getTextColor() {
    return isActive ? Colors.grey[800]! : Colors.grey[500]!;
  }

  Color _getIconColor() {
    return isActive ? Colors.grey[700]! : Colors.grey[400]!;
  }
}

