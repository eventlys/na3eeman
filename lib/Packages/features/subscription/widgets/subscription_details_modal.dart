import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';

class SubscriptionDetailsModal extends StatelessWidget {
  const SubscriptionDetailsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();
    final tierConfig = owner.tierConfig;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "subscription_details".tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.almostBlack,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Plan Card
          _buildPlanCard(context, owner, tierConfig),
          const SizedBox(height: 24),

          // Features List
          Text(
            "plan_features".tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.almostBlack400,
            ),
          ),
          const SizedBox(height: 12),
          ...tierConfig.enabledFeatures
              .take(5)
              .map((f) => _buildFeatureItem(context, _featureLabel(f))),
          if (tierConfig.enabledFeatures.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 28),
              child: Text(
                '+ ${tierConfig.enabledFeatures.length - 5} more features',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("close".tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: "upgrade_plan".tr(),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscription/upgrade');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    OwnerProvider owner,
    dynamic tierConfig,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final color = _getTierColor(owner.tier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_rounded, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tierConfig.displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      tierConfig.tagline,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : AppColors.almostBlack300,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: owner.isSubscriptionActive
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  owner.isSubscriptionActive ? 'ACTIVE' : 'EXPIRED',
                  style: TextStyle(
                    color: owner.isSubscriptionActive
                        ? AppColors.success
                        : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Staff Limit', tierConfig.staffLimitLabel),
              _buildInfoColumn('Branches', tierConfig.branchLimitLabel),
              _buildInfoColumn(
                'Expiry Date',
                owner.daysRemaining != null
                    ? '${owner.daysRemaining} days'
                    : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.almostBlack300, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Color _getTierColor(OwnerSubscriptionTier tier) {
    switch (tier) {
      case OwnerSubscriptionTier.artisan:
        return Colors.teal;
      case OwnerSubscriptionTier.studio:
        return Colors.blue;
      case OwnerSubscriptionTier.elite:
        return Colors.purple;
      case OwnerSubscriptionTier.empire:
        return Colors.amber.shade800;
    }
  }

  String _featureLabel(FeatureKey key) {
    final name = key.name;
    // Simple CamelCase to Space conversion
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubscriptionDetailsModal(),
    );
  }
}
