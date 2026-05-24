import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../constants/app_images.dart';
import '../../utils/helpers/themes_helpers.dart';
import '../../../../Helpers/error_handler.dart';
// import 'package:easy_localization/easy_localization.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final bool isDarkMode;
  final UserGender? userGender;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.isDarkMode = false,
    this.userGender,
    this.onRetry,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  dynamic error;
  StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return widget.fallback ?? _buildDefaultErrorWidget();
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget() {
    final colors = _getErrorColors();
    final isNetworkError =
        error is AppError && (error as AppError).type == ErrorType.network;

    return Scaffold(
      backgroundColor: colors['background'],
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colors['primary']!.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetworkError
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  size: 80,
                  color: colors['primary'],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              isNetworkError ? 'Connectivity Lost' : 'Unexpected Error',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: colors['text'],
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError
                  ? 'We couldn\'t reach our servers. Please check your internet connection and try again.'
                  : (error?.toString() ??
                        'An unexpected error occurred. Our team has been notified.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: colors['textSecondary'],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['primary'],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNetworkError
                          ? Icons.refresh_rounded
                          : Icons.home_rounded,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isNetworkError ? 'Retry Connection' : 'Go Back Home',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.asset(
              AppImages.info,
              width: 24,
              height: 24,
              color: _getErrorColors()['primary'],
            ),
            const SizedBox(width: 8),
            Text("error_details".tr()),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error: ${error?.toString() ?? 'Unknown'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (stackTrace != null) ...[
                Text(
                  "stack_trace".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  stackTrace.toString(),
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("close".tr()),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getErrorColors() {
    final isDark = widget.isDarkMode;

    if (widget.userGender != null) {
      switch (widget.userGender!) {
        case UserGender.male:
          return {
            'background': isDark
                ? AppColor.darkMaleBackground
                : AppColor.maleBackground,
            'primary': AppColor.maleAccent,
            'secondary': isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
            'icon': AppColor.maleAccent,
            'buttonText': isDark ? AppColor.darkText : AppColor.light,
          };
        case UserGender.female:
          return {
            'background': isDark
                ? AppColor.darkFemaleBackground
                : AppColor.femaleBackground,
            'primary': AppColor.femaleAccent,
            'secondary': isDark
                ? AppColor.darkFemaleBG
                : AppColor.lightFemaleBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
            'icon': AppColor.femaleAccent,
            'buttonText': isDark ? AppColor.darkText : AppColor.light,
          };
        case UserGender.nonBinary:
          return {
            'background': isDark
                ? AppColor.darkNonBinaryBackground
                : AppColor.nonBinaryBackground,
            'primary': AppColor.nonBinaryAccent,
            'secondary': isDark
                ? AppColor.darkNonBinaryBG
                : AppColor.lightNonBinaryBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
            'icon': AppColor.nonBinaryAccent,
            'buttonText': isDark ? AppColor.darkText : AppColor.light,
          };
      }
    }

    // Default colors based on theme
    return {
      'background': isDark ? AppColor.darkBackground : AppColor.lightBackground,
      'primary': isDark ? AppColor.darkPrimary : AppColor.primary,
      'secondary': isDark ? AppColor.darkSecondary : AppColor.secondary,
      'text': isDark ? AppColor.darkText : AppColor.lightText,
      'textSecondary': isDark
          ? AppColor.darkTextSecondary
          : AppColor.lightTextSecondary,
      'icon': isDark ? AppColor.darkError : AppColor.lightError,
      'buttonText': isDark ? AppColor.darkText : AppColor.light,
    };
  }

  void _handleRetry() {
    if (widget.onRetry != null) {
      widget.onRetry!();
    } else {
      setState(() {
        hasError = false;
        error = null;
        stackTrace = null;
      });
    }
  }

  void catchError(dynamic error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
      this.error = error;
      this.stackTrace = stackTrace;
    });
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset error state when child changes
    if (oldWidget.child != widget.child && hasError) {
      setState(() {
        hasError = false;
        error = null;
        stackTrace = null;
      });
    }
  }
}

class ErrorBoundaryBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  final bool isDarkMode;
  final UserGender? userGender;
  final Widget? customErrorWidget;

  const ErrorBoundaryBuilder({
    super.key,
    required this.builder,
    this.isDarkMode = false,
    this.userGender,
    this.customErrorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      isDarkMode: isDarkMode,
      userGender: userGender,
      fallback: customErrorWidget,
      child: Builder(
        builder: (context) {
          try {
            return builder(context);
          } catch (error, stackTrace) {
            // This won't catch errors in the widget tree, but in the builder function
            return _buildErrorWidget(error, stackTrace, context);
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget(
    dynamic error,
    StackTrace stackTrace,
    BuildContext context,
  ) {
    final colors = _getErrorColors(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors['secondary']!.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            _getErrorIcon(),
            width: 48,
            height: 48,
            color: colors['icon'],
          ),
          const SizedBox(height: 12),
          Text(
            "builder_error".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors['text'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 14, color: colors['textSecondary']),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getErrorColors(BuildContext context) {
    final isDark = isDarkMode;

    if (userGender != null) {
      switch (userGender!) {
        case UserGender.male:
          return {
            'background': isDark
                ? AppColor.darkMaleBackground.withValues(alpha: 0.1)
                : AppColor.maleBackground.withValues(alpha: 0.1),
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
            'icon': AppColor.maleAccent,
            'secondary': AppColor.maleAccent,
          };
        case UserGender.female:
          return {
            'background': isDark
                ? AppColor.darkFemaleBackground.withValues(alpha: 0.1)
                : AppColor.femaleBackground.withValues(alpha: 0.1),
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
            'icon': AppColor.femaleAccent,
            'secondary': AppColor.femaleAccent,
          };
        case UserGender.nonBinary:
          return {
            'background': isDark
                ? AppColor.darkNonBinaryBackground.withValues(alpha: 0.1)
                : AppColor.nonBinaryBackground.withValues(alpha: 0.1),
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark
                ? AppColor.darkTextSecondary
                : AppColor.lightTextSecondary,
            'icon': AppColor.nonBinaryAccent,
            'secondary': AppColor.nonBinaryAccent,
          };
      }
    }

    return {
      'background': isDark ? AppColor.darkCard : AppColor.lightCard,
      'text': isDark ? AppColor.darkText : AppColor.lightText,
      'textSecondary': isDark
          ? AppColor.darkTextSecondary
          : AppColor.lightTextSecondary,
      'icon': isDark ? AppColor.darkError : AppColor.lightError,
      'secondary': isDark ? AppColor.darkSecondary : AppColor.secondary,
    };
  }

  String _getErrorIcon() {
    if (userGender != null) {
      switch (userGender!) {
        case UserGender.male:
          return isDarkMode
              ? AppImages.avatar_male_view
              : AppImages.avatar_male;
        case UserGender.female:
          return isDarkMode
              ? AppImages.avatar_female_view
              : AppImages.avatar_female;
        case UserGender.nonBinary:
          return isDarkMode
              ? AppImages.not_allowed_gray
              : AppImages.not_allowed;
      }
    }
    return isDarkMode ? AppImages.error_view : AppImages.error;
  }
}
