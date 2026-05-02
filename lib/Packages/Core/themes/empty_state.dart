import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants/app_color.dart';
import 'app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final Widget? actionButton;
  final EdgeInsetsGeometry padding;
  final bool compact;
  final UserGender? gender;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.imagePath,
    this.icon,
    this.iconColor,
    this.iconSize = 64.0,
    this.actionButton,
    this.padding = const EdgeInsets.all(32.0),
    this.compact = false,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradientColors = AppThemes.getGradientColors(context);

    // Get appropriate disabled color based on theme and gender
    Color getDisabledColor() {
      if (gender != null) {
        switch (gender!) {
          case UserGender.male:
            return isDark ? AppColor.darkTextHint : AppColor.lightTextHint;
          case UserGender.female:
            return isDark ? AppColor.darkTextHint : AppColor.lightTextHint;
          case UserGender.nonBinary:
            return isDark ? AppColor.darkTextHint : AppColor.lightTextHint;
        }
      }
      return isDark ? AppColor.darkTextHint : AppColor.lightTextHint;
    }

    // Get appropriate text color based on theme and gender
    Color getTextColor() {
      if (gender != null) {
        switch (gender!) {
          case UserGender.male:
            return isDark ? AppColor.darkText : AppColor.lightText;
          case UserGender.female:
            return isDark ? AppColor.darkText : AppColor.lightText;
          case UserGender.nonBinary:
            return isDark ? AppColor.darkText : AppColor.lightText;
        }
      }
      return isDark ? AppColor.darkText : AppColor.lightText;
    }

    // Get appropriate secondary text color
    Color getSecondaryTextColor() {
      if (gender != null) {
        switch (gender!) {
          case UserGender.male:
            return isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary;
          case UserGender.female:
            return isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary;
          case UserGender.nonBinary:
            return isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary;
        }
      }
      return isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    }

    final disabledColor = getDisabledColor();
    final textColor = getTextColor();
    final secondaryTextColor = getSecondaryTextColor();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradientColors.startColor, gradientColors.endColor],
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                width: compact ? 80.0 : 120.0,
                height: compact ? 80.0 : 120.0,
                fit: BoxFit.contain,
                color: gender != null
                    ? _getGenderAccentColor(gender!, isDark)
                    : null,
              ),
              const SizedBox(height: 24),
            ] else if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getGenderBackgroundColor(
                    gender,
                    isDark,
                  ).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: compact ? 48.0 : iconSize,
                  color:
                      iconColor ??
                      _getGenderAccentColor(gender, isDark) ??
                      disabledColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: compact
                  ? theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    )
                  : theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }

  Color? _getGenderAccentColor(UserGender? gender, bool isDark) {
    if (gender == null) return null;

    switch (gender) {
      case UserGender.male:
        return isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG;
      case UserGender.female:
        return isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG;
      case UserGender.nonBinary:
        return isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG;
    }
  }

  Color _getGenderBackgroundColor(UserGender? gender, bool isDark) {
    if (gender == null) {
      return isDark ? AppColor.darkBackground : AppColor.lightBackground;
    }

    switch (gender) {
      case UserGender.male:
        return isDark ? AppColor.darkMaleBackground : AppColor.maleBackground;
      case UserGender.female:
        return isDark
            ? AppColor.darkFemaleBackground
            : AppColor.femaleBackground;
      case UserGender.nonBinary:
        return isDark
            ? AppColor.darkNonBinaryBackground
            : AppColor.nonBinaryBackground;
    }
  }

  // Predefined empty states for common scenarios
  static EmptyState noItems({
    required BuildContext context,
    String? title,
    String? description,
    Widget? actionButton,
    bool compact = false,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "no_items_found".tr(),
      description:
          description ?? "there_are_no_items_to_display_at_the_moment".tr(),
      icon: Icons.inventory_2_outlined,
      actionButton: actionButton,
      compact: compact,
      gender: gender,
    );
  }

  static EmptyState noFavorites({
    required BuildContext context,
    String? title,
    String? description,
    Widget? actionButton,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "no_favorites_yet".tr(),
      description: description ?? "your_favorite_items_will_appear_here".tr(),
      icon: Icons.favorite_border,
      actionButton: actionButton,
      gender: gender,
    );
  }

  static EmptyState noSearchResults({
    required BuildContext context,
    String? title,
    String? description,
    Widget? actionButton,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "no_results_found".tr(),
      description: description ?? "try_adjusting_your_search_terms".tr(),
      icon: Icons.search_off,
      actionButton: actionButton,
      gender: gender,
    );
  }

  static EmptyState error({
    required BuildContext context,
    String? title,
    String? description,
    VoidCallback? onRetry,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "something_went_wrong".tr(),
      description: description ?? "please_try_again_later".tr(),
      icon: Icons.error_outline,
      iconColor: AppColor.lightError,
      actionButton: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text("try_again".tr()),
            )
          : null,
      gender: gender,
    );
  }

  static EmptyState noInternet({
    required BuildContext context,
    String? title,
    String? description,
    VoidCallback? onRetry,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "no_internet_connection".tr(),
      description: description ?? "please_check_your_connection_and_try_again".tr(),
      icon: Icons.wifi_off,
      actionButton: onRetry != null
          ? ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text("retry".tr()),
            )
          : null,
      gender: gender,
    );
  }

  // Loading state
  static EmptyState loading({
    required BuildContext context,
    String? title,
    String? description,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "loading".tr(),
      description: description ?? "please_wait_while_we_load_your_content".tr(),
      icon: Icons.hourglass_empty,
      gender: gender,
    );
  }

  // Success state
  static EmptyState success({
    required BuildContext context,
    String? title,
    String? description,
    Widget? actionButton,
    UserGender? gender,
  }) {
    return EmptyState(
      title: title ?? "success".tr(),
      description: description,
      icon: Icons.check_circle_outline,
      iconColor: AppColor.lightSuccess,
      actionButton: actionButton,
      gender: gender,
    );
  }

  // Empty state for lists
  static Widget listEmptyState({
    required String title,
    String? description,
    IconData? icon,
    Widget? actionButton,
    UserGender? gender,
  }) {
    return SliverFillRemaining(
      child: EmptyState(
        title: title,
        description: description,
        icon: icon,
        actionButton: actionButton,
        gender: gender,
      ),
    );
  }

  // Gender-specific empty states
  factory EmptyState.male({
    required String title,
    String? description,
    IconData? icon,
    Widget? actionButton,
    bool compact = false,
  }) {
    return EmptyState(
      title: title,
      description: description,
      icon: icon,
      actionButton: actionButton,
      compact: compact,
      gender: UserGender.male,
    );
  }

  factory EmptyState.female({
    required String title,
    String? description,
    IconData? icon,
    Widget? actionButton,
    bool compact = false,
  }) {
    return EmptyState(
      title: title,
      description: description,
      icon: icon,
      actionButton: actionButton,
      compact: compact,
      gender: UserGender.female,
    );
  }

  factory EmptyState.nonBinary({
    required String title,
    String? description,
    IconData? icon,
    Widget? actionButton,
    bool compact = false,
  }) {
    return EmptyState(
      title: title,
      description: description,
      icon: icon,
      actionButton: actionButton,
      compact: compact,
      gender: UserGender.nonBinary,
    );
  }
}
