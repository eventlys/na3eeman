import 'package:flutter/material.dart';
import '../../constants/app_color.dart';


class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity, // This makes it 100% of parent width
      decoration: BoxDecoration(
        color: backgroundColor ??
              (isDark ? AppColor.darkCard : AppColor.lightCard),
        border: Border.all(
          color: borderColor ??
                (isDark ? AppColor.darkTextHint : AppColor.lightTextHint),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColor.darkText : AppColor.lightText,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                ),
              )
            : null,
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
