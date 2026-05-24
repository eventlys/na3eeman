import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/buttons/styled_buttons.dart';

class ApiErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isNetworkError;

  const ApiErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.isNetworkError = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isNetworkError
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError
                    ? Icons.wifi_off_rounded
                    : Icons.error_outline_rounded,
                size: 64,
                color: isNetworkError
                    ? Theme.of(context).primaryColor
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isNetworkError ? 'Connection Issue' : 'Something went wrong',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.cream600 : AppColors.almostBlack300,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(text: 'Try Again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
