import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';

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
    final trailingIconColor = Theme.of(context).iconTheme.color;

    final leadingContent = Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: AppSpacing.brSm,
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
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: AppSpacing.brMd,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: leadingContent,
            title: Text(title, style: titleStyle),
            iconColor: trailingIconColor,
            collapsedIconColor: trailingIconColor,
            childrenPadding: const EdgeInsetsDirectional.only(
              start: AppSpacing.md,
            ),
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
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: AppSpacing.brMd,
      ),
      child: ListTile(
        onTap: onTap,
        leading: leadingContent,
        title: Text(title, style: titleStyle),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: trailingIconColor,
          size: AppSpacing.iconMd,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.brMd),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark, BuildContext context) {
    if (assetIcon != null) {
      return Image.asset(
        assetIcon!,
        width: AppSpacing.iconBase,
        height: AppSpacing.iconBase,
        color: Theme.of(context).primaryColor,
        errorBuilder: (_, _, _) => Icon(
          Icons.circle,
          size: AppSpacing.iconBase,
          color: Theme.of(context).primaryColor,
        ),
      );
    }
    return Icon(
      icon ?? Icons.circle,
      size: AppSpacing.iconBase,
      color: Theme.of(context).primaryColor,
    );
  }
}
