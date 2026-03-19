import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/widgets/common/app_button.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';

/// Subscription tier comparison and upgrade page.
class SubscriptionUpgradePage extends StatelessWidget {
  const SubscriptionUpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Unlock More Features',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Upgrade to access advanced tools and grow your business.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ..._plans.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PlanCard(plan: p, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan data ─────────────────────────────────────────────────────────────────

class _Plan {
  const _Plan({
    required this.tier,
    required this.price,
    required this.period,
    required this.features,
    this.highlight = false,
    this.highlightLabel,
  });
  final SubscriptionTier tier;
  final String price;
  final String period;
  final List<(String, bool)> features; // (text, isIncluded)
  final bool highlight;
  final String? highlightLabel;
}

const _plans = [
  _Plan(
    tier: SubscriptionTier.basic,
    price: 'Free',
    period: 'forever',
    features: [
      ('1 Active Booking', true),
      ('Basic Profile', true),
      ('Advanced Analytics', false),
      ('Staff Management', false),
      ('Priority Support', false),
    ],
  ),
  _Plan(
    tier: SubscriptionTier.gold,
    price: 'SAR 49',
    period: '/month',
    features: [
      ('Unlimited Bookings', true),
      ('Custom Profile & Logo', true),
      ('Basic Analytics', true),
      ('Staff Management (2)', true),
      ('Priority Support', false),
    ],
    highlight: false,
  ),
  _Plan(
    tier: SubscriptionTier.elite,
    price: 'SAR 99',
    period: '/month',
    features: [
      ('Unlimited Bookings', true),
      ('Custom Profile & Logo', true),
      ('Advanced Analytics', true),
      ('Staff Management (10)', true),
      ('Priority Support', true),
    ],
    highlight: true,
    highlightLabel: 'Most Popular',
  ),
  _Plan(
    tier: SubscriptionTier.premium,
    price: 'SAR 199',
    period: '/month',
    features: [
      ('Everything in Elite', true),
      ('Multi-Branch Support', true),
      ('API Access', true),
      ('Dedicated Account Manager', true),
      ('24/7 Priority Support', true),
    ],
  ),
  _Plan(
    tier: SubscriptionTier.business,
    price: 'Custom',
    period: '',
    features: [
      ('Everything in Premium', true),
      ('Unlimited Branches', true),
      ('Custom Integrations', true),
      ('SLA Guarantee', true),
      ('Onboarding & Training', true),
    ],
  ),
];

// ── Plan Card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isDark});
  final _Plan plan;
  final bool isDark;

  Color get _tierColor => AppColor.subscriptionTierColor(plan.tier.name);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppCard(
          type: plan.highlight ? AppCardType.gradient : AppCardType.outlined,
          gradient: plan.highlight
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_tierColor, _tierColor.withOpacity(0.7)],
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: plan.highlight
                          ? Colors.white.withOpacity(0.2)
                          : _tierColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      plan.tier.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: plan.highlight ? Colors.white : _tierColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: plan.price,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: plan.highlight ? Colors.white : null,
                          ),
                        ),
                        TextSpan(
                          text: plan.period,
                          style: TextStyle(
                            fontSize: 12,
                            color: plan.highlight
                                ? Colors.white70
                                : (isDark
                                      ? AppColor.darkTextSecondary
                                      : AppColor.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Features
              ...plan.features.map((f) {
                final (text, included) = f;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        included
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 18,
                        color: included
                            ? (plan.highlight ? Colors.white : AppColor.success)
                            : (isDark
                                  ? AppColor.darkTextHint
                                  : AppColor.lightTextHint),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: included
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: plan.highlight
                              ? (included ? Colors.white : Colors.white60)
                              : null,
                          decoration: included
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              AppButton(
                label: plan.price == 'Free'
                    ? 'Current Plan'
                    : plan.price == 'Custom'
                    ? 'Contact Sales'
                    : 'Upgrade to ${plan.tier.displayName}',
                fullWidth: true,
                type: plan.highlight
                    ? AppButtonType.primary
                    : AppButtonType.outline,
                onPressed: plan.price == 'Free' ? null : () {},
              ),
            ],
          ),
        ),
        if (plan.highlight && plan.highlightLabel != null)
          Positioned(
            top: -2,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _tierColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                plan.highlightLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
