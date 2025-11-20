import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../constants/app_images.dart';
import '../../utils/helpers/themes_helpers.dart';


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
    final icon = _getErrorIcon();

    return Scaffold(
      backgroundColor: colors['background'],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                width: 80,
                height: 80,
                color: colors['icon'],
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors['text'],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error?.toString() ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colors['textSecondary'],
                ),
              ),
              const SizedBox(height: 32),
              _buildRetryButton(colors),
              const SizedBox(height: 16),
              _buildReportButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton(Map<String, Color> colors) {
    return ElevatedButton(
      onPressed: _handleRetry,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors['primary'],
        foregroundColor: colors['buttonText'],
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.refresh,
            width: 20,
            height: 20,
            color: colors['buttonText'],
          ),
          const SizedBox(width: 8),
          const Text(
            'Try Again',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(Map<String, Color> colors) {
    return TextButton(
      onPressed: () {
        // TODO: Implement error reporting
        _showErrorDetails();
      },
      style: TextButton.styleFrom(
        foregroundColor: colors['secondary'],
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.report,
            width: 16,
            height: 16,
            color: colors['secondary'],
          ),
          const SizedBox(width: 6),
          const Text('Report Issue'),
        ],
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
            const Text('Error Details'),
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
                const Text(
                  'Stack Trace:',
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
            child: const Text('Close'),
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
            'background': isDark ? AppColor.darkMaleBackground : AppColor.maleBackground,
            'primary': AppColor.maleAccent,
            'secondary': isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'icon': AppColor.maleAccent,
            'buttonText': isDark ? AppColor.darkText : AppColor.light,
          };
        case UserGender.female:
          return {
            'background': isDark ? AppColor.darkFemaleBackground : AppColor.femaleBackground,
            'primary': AppColor.femaleAccent,
            'secondary': isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'icon': AppColor.femaleAccent,
            'buttonText': isDark ? AppColor.darkText : AppColor.light,
          };
        case UserGender.nonBinary:
          return {
            'background': isDark ? AppColor.darkNonBinaryBackground : AppColor.nonBinaryBackground,
            'primary': AppColor.nonBinaryAccent,
            'secondary': isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG,
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
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
      'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
      'icon': isDark ? AppColor.darkError : AppColor.lightError,
      'buttonText': isDark ? AppColor.darkText : AppColor.light,
    };
  }

  String _getErrorIcon() {
    if (widget.userGender != null) {
      switch (widget.userGender!) {
        case UserGender.male:
          return widget.isDarkMode ? AppImages.avatar_male_view : AppImages.avatar_male;
        case UserGender.female:
          return widget.isDarkMode ? AppImages.avatar_female_view : AppImages.avatar_female;
        case UserGender.nonBinary:
          return widget.isDarkMode ? AppImages.not_allowed_gray : AppImages.not_allowed;
      }
    }
    return widget.isDarkMode ? AppImages.error_view : AppImages.error;
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
            return _buildErrorWidget(error, stackTrace);
          }
        },
      ),
    );
  }

  Widget _buildErrorWidget(dynamic error, StackTrace stackTrace) {
    final colors = _getErrorColors();

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
            'Builder Error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors['text'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: colors['textSecondary'],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getErrorColors() {
    final isDark = isDarkMode;

    if (userGender != null) {
      switch (userGender!) {
        case UserGender.male:
          return {
            'background': isDark ? AppColor.darkMaleBackground.withValues(alpha: 0.1) : AppColor.maleBackground.withValues(alpha: 0.1),
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'icon': AppColor.maleAccent,
            'secondary': AppColor.maleAccent,
          };
        case UserGender.female:
          return {
            'background': isDark ? AppColor.darkFemaleBackground.withValues(alpha: 0.1) : AppColor.femaleBackground.withValues(alpha: 0.1),
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'icon': AppColor.femaleAccent,
            'secondary': AppColor.femaleAccent,
          };
        case UserGender.nonBinary:
          return {
            'background': isDark ? AppColor.darkNonBinaryBackground.withValues(alpha: 0.1) : AppColor.nonBinaryBackground.withValues(alpha: 0.1),
            'text': isDark ? AppColor.darkText : AppColor.lightText,
            'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
            'icon': AppColor.nonBinaryAccent,
            'secondary': AppColor.nonBinaryAccent,
          };
      }
    }

    return {
      'background': isDark ? AppColor.darkCard : AppColor.lightCard,
      'text': isDark ? AppColor.darkText : AppColor.lightText,
      'textSecondary': isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
      'icon': isDark ? AppColor.darkError : AppColor.lightError,
      'secondary': isDark ? AppColor.darkSecondary : AppColor.secondary,
    };
  }

  String _getErrorIcon() {
    if (userGender != null) {
      switch (userGender!) {
        case UserGender.male:
          return isDarkMode ? AppImages.avatar_male_view : AppImages.avatar_male;
        case UserGender.female:
          return isDarkMode ? AppImages.avatar_female_view : AppImages.avatar_female;
        case UserGender.nonBinary:
          return isDarkMode ? AppImages.not_allowed_gray : AppImages.not_allowed;
      }
    }
    return isDarkMode ? AppImages.error_view : AppImages.error;
  }
}
