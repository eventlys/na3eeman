import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../utils/helpers/themes_helpers.dart';


class AppDialogThemes {
  // Main dialog theme getters - using DialogThemeData
  static DialogThemeData get lightDialogTheme {
    return DialogThemeData(
      backgroundColor: AppColor.lightCard,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: AppColor.dark,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: AppColor.dark,
      ),
    );
  }

  static DialogThemeData get darkDialogTheme {
    return DialogThemeData(
      backgroundColor: AppColor.darkCard,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: AppColor.light,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: AppColor.light,
      ),
    );
  }

  // Gender-specific dialog themes - using DialogThemeData
  static DialogThemeData getGenderDialogTheme(UserGender gender, bool isDark) {
    final config = SharedThemeHelpers.getGenderThemeConfig(gender, isDark);

    return DialogThemeData(
      backgroundColor: config.cardColor,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: config.textColor,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: config.textColor,
      ),
    );
  }

  // High contrast dialog themes - using DialogThemeData
  static DialogThemeData getHighContrastDialogTheme(bool isDark) {
    return DialogThemeData(
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: 12.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isDark ? Colors.white : Colors.black,
          width: 2.0
        ),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  // ... rest of your AppDialogThemes class remains the same
  static Widget createGradientDialog({
    required BuildContext context,
    required Widget child,
    EdgeInsets? insetPadding,
  }) {
    final gradientColors = GradientHelper.getGradientColors(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: insetPadding,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColors.startColor,
              gradientColors.endColor,
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColor.dark.withValues(alpha: 0.3),
              blurRadius: 16.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  static Future<T?> showThemedAlertDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool useGenderTheme = false,
    UserGender gender = UserGender.male,
  }) {
    final theme = Theme.of(context);

    DialogThemeData dialogTheme;
    if (useGenderTheme) {
      final isDark = theme.brightness == Brightness.dark;
      dialogTheme = getGenderDialogTheme(gender, isDark);
    } else {
      dialogTheme = theme.dialogTheme;
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Theme(
          data: theme.copyWith(dialogTheme: dialogTheme),
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              if (cancelText != null)
                TextButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: Text(cancelText),
                ),
              if (confirmText != null)
                TextButton(
                  onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                  child: Text(confirmText),
                ),
            ],
          ),
        );
      },
    );
  }

  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    EdgeInsets? insetPadding,
    bool useGenderTheme = false,
    UserGender gender = UserGender.male,
  }) {
    final theme = Theme.of(context);

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        if (useGenderTheme) {
          final isDark = theme.brightness == Brightness.dark;
          final dialogTheme = getGenderDialogTheme(gender, isDark);
          return Theme(
            data: theme.copyWith(dialogTheme: dialogTheme),
            child: Dialog(
              insetPadding: insetPadding,
              child: child,
            ),
          );
        }

        return Dialog(
          insetPadding: insetPadding,
          child: child,
        );
      },
    );
  }
}
