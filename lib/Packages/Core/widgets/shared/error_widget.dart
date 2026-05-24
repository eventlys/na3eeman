import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_color.dart';
import 'package:easy_localization/easy_localization.dart';

/// Different types of errors that can be displayed
enum ErrorType {
  network,
  server,
  notFound,
  unauthorized,
  unknown,
  empty,
  loading,
}

/// A reusable error widget with different states and retry functionality
class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final VoidCallback? onSecondaryAction;
  final String retryButtonText;
  final String? secondaryButtonText;
  final bool showIcon;
  final bool showRetryButton;
  final bool compact;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.errorType = ErrorType.unknown,
    this.onRetry,
    this.onSecondaryAction,
    this.retryButtonText = 'Try Again',
    this.secondaryButtonText,
    this.showIcon = true,
    this.showRetryButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactError(context);
    }

    return _buildFullError(context);
  }

  Widget _buildFullError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              _buildErrorIcon(context),
              const SizedBox(height: 24),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getErrorColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColor.darkTextSecondary
                    : AppColor.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (showRetryButton && onRetry != null) ...[
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = _getErrorColor(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            _buildSmallErrorIcon(context),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColor.darkTextSecondary
                        : AppColor.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.refresh, color: errorColor, size: 20),
              onPressed: onRetry,
              tooltip: retryButtonText,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    final iconData = _getErrorIconData();
    final color = _getErrorColor(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Icon(iconData, size: 48, color: color),
    );
  }

  Widget _buildSmallErrorIcon(BuildContext context) {
    return Icon(_getErrorIconData(), size: 20, color: _getErrorColor(context));
  }

  IconData _getErrorIconData() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.unauthorized:
        return Icons.lock_outline;
      case ErrorType.empty:
        return Icons.inbox_outlined;
      case ErrorType.loading:
        return Icons.hourglass_empty;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (errorType) {
      case ErrorType.network:
        return isDark ? AppColor.darkWarning : AppColor.lightWarning;
      case ErrorType.server:
        return isDark ? AppColor.darkError : AppColor.lightError;
      case ErrorType.notFound:
        return isDark ? AppColor.darkInfo : AppColor.lightInfo;
      case ErrorType.unauthorized:
        return isDark ? AppColor.darkWarning : AppColor.lightWarning;
      case ErrorType.empty:
        return isDark ? AppColor.darkTextHint : AppColor.lightTextHint;
      case ErrorType.loading:
        return isDark ? AppColor.darkPrimary : AppColor.lightPrimary;
      case ErrorType.unknown:
        return isDark ? AppColor.darkError : AppColor.lightError;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(retryButtonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColor.darkPrimary
                  : AppColor.lightPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        if (onSecondaryAction != null && secondaryButtonText != null) ...[
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onSecondaryAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppColor.darkPrimary
                  : AppColor.lightPrimary,
              side: BorderSide(
                color: isDark ? AppColor.darkPrimary : AppColor.lightPrimary,
              ),
            ),
            child: Text(secondaryButtonText!),
          ),
        ],
      ],
    );
  }
}

/// A specialized error widget for network errors
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const NetworkErrorWidget({
    super.key,
    required this.onRetry,
    this.message =
        'No internet connection. Please check your network settings and try again.',
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: tr('connection_error'),
      message: message,
      errorType: ErrorType.network,
      onRetry: onRetry,
      retryButtonText: 'Retry Connection',
    );
  }
}

/// A specialized error widget for empty states
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? assetPath;
  final IconData? icon;
  final VoidCallback? onAction;
  final String actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.assetPath,
    this.icon,
    this.onAction,
    this.actionText = 'Refresh',
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: title,
      message: message,
      errorType: ErrorType.empty,
      onRetry: onAction,
      retryButtonText: actionText,
      showIcon: true,
    );
  }
}

/// Toast message utility to replace snackbars
class ToastMessage {
  static void showError({
    required BuildContext context,
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onRetry();
                },
                child: Text(
                  tr('retry'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: isDark ? AppColor.darkError : AppColor.lightError,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColor.darkSuccess : AppColor.lightSuccess,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColor.darkWarning : AppColor.lightWarning,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColor.darkInfo : AppColor.lightInfo,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Extension methods for easy error handling with toast messages
extension ErrorWidgetExtension on BuildContext {
  /// Show an error toast message
  void showErrorToast(String message, {VoidCallback? onRetry}) {
    ToastMessage.showError(context: this, message: message, onRetry: onRetry);
  }

  /// Show a success toast message
  void showSuccessToast(String message) {
    ToastMessage.showSuccess(context: this, message: message);
  }

  /// Show a warning toast message
  void showWarningToast(String message) {
    ToastMessage.showWarning(context: this, message: message);
  }

  /// Show an info toast message
  void showInfoToast(String message) {
    ToastMessage.showInfo(context: this, message: message);
  }
}
