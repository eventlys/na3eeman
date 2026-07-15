import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? assetIcon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final List<dynamic>? children;

  const SidebarItem({
    super.key,
    required this.title,
    this.icon,
    this.assetIcon,
    required this.onTap,
    this.backgroundColor,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final leadingContent = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildIcon(isDark, context),
    );

    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.white : AppColors.almostBlack,
      fontSize: 15,
    );

    if (children != null && children!.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: leadingContent,
            title: Text(title, style: titleStyle),
            iconColor: AppColors.almostBlack200,
            collapsedIconColor: AppColors.almostBlack200,
            childrenPadding: const EdgeInsets.only(left: 16),
            children: children!.map((childItem) {
              return SidebarItem(
                title: childItem.title,
                icon: childItem.icon,
                assetIcon: childItem.assetIcon,
                onTap: childItem.onTap,
              );
            }).toList(),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leadingContent,
        title: Text(title, style: titleStyle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.almostBlack200,
          size: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildIcon(bool isDark, BuildContext context) {
    if (assetIcon != null) {
      return Image.asset(
        assetIcon!,
        width: 20,
        height: 20,
        color: Theme.of(context).primaryColor,
        errorBuilder: (_, _, _) =>
            Icon(Icons.circle, size: 20, color: Theme.of(context).primaryColor),
      );
    }
    return Icon(
      icon ?? Icons.circle,
      size: 20,
      color: Theme.of(context).primaryColor,
    );
  }
}
