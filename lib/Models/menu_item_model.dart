import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData? icon; // Make icon optional
  final String? assetIcon; // Add asset icon path
  final int delay;
  final VoidCallback onTap;

  MenuItem({
    required this.title,
    this.icon,
    this.assetIcon,
    required this.delay,
    required this.onTap,
  }) : assert(icon != null || assetIcon != null, 'Either icon or assetIcon must be provided');
}
