import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? assetIcon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final double iconSize;

  const SidebarItem({
    super.key,
    required this.title,
    this.icon,
    this.assetIcon,
    required this.onTap,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.black,
    this.iconSize = 24.0,
  }) : assert(icon != null || assetIcon != null, 'Either icon or assetIcon must be provided');

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shadowColor: Colors.transparent,
      color: backgroundColor,
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
            fontSize: 16, // You can adjust text size
          ),
        ),
        // trailing: Icon(Icons.chevron_right, color: trailingColor, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Control padding
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (assetIcon != null) {
      return Image.asset(
        assetIcon!,
        width: iconSize,
        height: iconSize,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image fails to load
          return Icon(
            icon ?? Icons.error_outline,
            size: iconSize,
          );
        },
      );
    } else {
      return Icon(
        icon,
        size: iconSize,
      );
    }
  }
}

