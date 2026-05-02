import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/core/services/feature_access_service.dart';

/// Wraps a dashboard widget with tier-based feature gating.
///
/// If the current owner cannot access [featureKey], shows an [UpgradePromptCard]
/// instead of the locked widget.
///
/// Usage:
/// ```dart
/// TierGatedWidget(
///   featureKey: FeatureKey.reportsAdvanced,
///   child: AdvancedReportsWidget(),
/// )
/// ```
class TierGatedWidget extends StatelessWidget {
  final FeatureKey featureKey;
  final Widget child;
  final Widget? fallback; // optional custom locked state

  const TierGatedWidget({
    super.key,
    required this.featureKey,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();

    if (owner.canAccess(featureKey)) return child;

    if (fallback != null) return fallback!;

    final denial = owner.denialReason(featureKey);
    return UpgradePromptCard(denial: denial);
  }
}

/// Shown where a locked feature widget would appear.
class UpgradePromptCard extends StatelessWidget {
  final FeatureDenialReason? denial;

  const UpgradePromptCard({super.key, this.denial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requiredTier = denial?.requiredTier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline_rounded,
              size: 36, color: theme.primaryColor.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            requiredTier != null
                ? '${requiredTier.displayName} Feature'
                : 'Premium Feature',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            denial?.message ?? 'Upgrade your plan to unlock this feature.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () =>
                Navigator.pushNamed(context, '/subscription/upgrade'),
            child: Text("upgrade_plan".tr()),
          ),
        ],
      ),
    );
  }
}
