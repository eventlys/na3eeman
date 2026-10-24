import 'package:flutter/material.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:na3eeman/Packages/Core/constants/app_style.dart';

import '../constants/app_color.dart';
import '../../../core/theme/spacing.dart';
import '../constants/app_strings.dart';

// Reusable Faded Background Widget
class FadedBackground extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final Widget? child;

  const FadedBackground({
    super.key,
    required this.startColor,
    required this.endColor,
    this.begin = const Alignment(0.50, -0.40),
    this.end = const Alignment(0.50, 0.50),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [startColor, endColor],
        ),
      ),
      child: child,
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadedBackground(
        startColor: AppColor.lightBackground,
        endColor: AppColor.lightPrimary.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.thirdPage,
                style: context.h3.copyWith(color: AppColor.lightText),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  AppSnackBar.info(context, 'feature_coming_soon'.tr());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.lightPrimary,
                  foregroundColor: AppColor.lightCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: context.buttonMedium,
                ),
                child: Text(AppStrings.continueText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
