import 'package:flutter/material.dart';
import '../../../Services/enums/gender.dart';
import '../../Core/constants/app_color.dart';

class SubscriptionDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onSubscribe;
  final Gender gender;
  final bool isDarkMode;

  const SubscriptionDetailsDialog({
    super.key,
    required this.subscription,
    required this.onSubscribe,
    required this.gender,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? size.width * 0.9 : 500,
          maxHeight: size.height * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _getBackgroundGradient(theme),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 12),

              // Price Section
              _buildPriceSection(context),
              const SizedBox(height: 12),

              // Features
              _buildFeaturesSection(context),
              const SizedBox(height: 32),

              // Subscribe Button
              _buildSubscribeButton(context),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getBackgroundGradient(ThemeData theme) {
    final price = subscription['price'] as double? ?? 0.0;
    final isPopular = subscription['isPopular'] as bool? ?? false;

    if (isDarkMode) {
      if (isPopular) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [
            theme.primaryColor.withValues(alpha: 0.5),
            AppColor.darkBackground.withValues(alpha: 0.3),
          ],
        );
      } else if (price > 20) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.4),
            theme.colorScheme.secondary.withValues(alpha: 0.3),
          ],
        );
      } else {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.3),
            AppColor.darkBackground.withValues(alpha: 0.1),
          ],
        );
      }
    } else {
      if (isPopular) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [
            theme.primaryColor.withValues(alpha: 0.3),
            AppColor.lightBackground.withValues(alpha: 0.1),
          ],
        );
      } else if (price > 20) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.2),
          ],
        );
      } else {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.2),
            AppColor.lightBackground.withValues(alpha: 0.1),
          ],
        );
      }
    }
  }

  Color _getGenderPrimaryColor(ThemeData theme) {
    return theme.primaryColor;
  }

  Color _getGenderAccentColor(ThemeData theme) {
    switch (gender) {
      case Gender.male:
        return AppColor.maleAccent;
      case Gender.female:
        return AppColor.femaleAccent;
      case Gender.nonBinary:
        return AppColor.nonBinaryAccent;
    }
  }

  Color _getTextColor(ThemeData theme) {
    return theme.colorScheme.onSurface;
  }

  Color _getTextSecondaryColor(ThemeData theme) {
    return theme.colorScheme.onSurface.withValues(alpha: 0.7);
  }

  Color _getCardColor(ThemeData theme) {
    return isDarkMode ? AppColor.darkCard : AppColor.lightCard;
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final name = subscription['name'] as String? ?? 'Unknown';
    final description = subscription['description'] as String? ?? '';
    final isPopular = subscription['isPopular'] as bool? ?? false;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(theme),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getTextSecondaryColor(theme),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getGenderAccentColor(theme),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'POPULAR',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColor.light,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final theme = Theme.of(context);
    final price = subscription['price'] as double? ?? 0.0;
    final duration = subscription['duration'] as String? ?? '';

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: _getGenderPrimaryColor(theme).withValues(alpha: 0.7),
        ),
        color: _getCardColor(theme).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _getGenderPrimaryColor(theme),
            ),
          ),
          Text(
            'for $duration',
            style: TextStyle(
              fontSize: 16,
              color: _getTextSecondaryColor(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final theme = Theme.of(context);
    final features = subscription['features'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s included:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getTextColor(theme),
          ),
        ),
        const SizedBox(height: 6),
        Column(
          children: features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _getTextSecondaryColor(theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onSubscribe();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: isDarkMode ? AppColor.dark : AppColor.light,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Subscribe Now',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColor.dark : AppColor.light,
          ),
        ),
      ),
    );
  }
}
