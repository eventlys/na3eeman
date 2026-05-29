import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../constants/app_color.dart';
import '../../constants/app_roles.dart';
import '../../themes/app_theme.dart';
// import 'package:easy_localization/easy_localization.dart';

/// Wraps any widget with a subscription-gate overlay.
/// If the user's tier is insufficient, the child is blurred and a lock +
/// upgrade button is shown.
///
/// Usage:
/// ```dart
/// FeatureLock(
///   requiredTier: SubscriptionTier.gold,
///   child: MyPremiumWidget(),
/// )
/// ```
class FeatureLock extends StatelessWidget {
  const FeatureLock({
    super.key,
    required this.requiredTier,
    required this.child,
    this.currentTier = SubscriptionTier.basic,
    this.onUpgrade,
    this.label,
  });

  final SubscriptionTier requiredTier;
  final Widget child;
  final SubscriptionTier currentTier;
  final VoidCallback? onUpgrade;
  final String? label;

  bool get _isLocked => !currentTier.meets(requiredTier);

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) return child;

    return Stack(
      children: [
        // Blurred locked content
        ImageFiltered(
          imageFilter: _blurFilter,
          child: IgnorePointer(child: child),
        ),

        // Lock overlay
        Positioned.fill(
          child: _LockOverlay(
            requiredTier: requiredTier,
            onUpgrade: onUpgrade,
            label: label,
          ),
        ),
      ],
    );
  }

  static final _blurFilter = (null as dynamic) == null
      ? _realBlurFilter()
      : ColorFilter.mode(Colors.transparent, BlendMode.clear);

  static ColorFilter _realBlurFilter() {
    // We rely on ImageFiltered below, this is just a placeholder
    return ColorFilter.mode(Colors.transparent, BlendMode.clear);
  }
}

// Using a simpler approach without dart:ui for broader Flutter compatibility
class _LockedContent extends StatelessWidget {
  const _LockedContent({
    required this.child,
    required this.requiredTier,
    this.onUpgrade,
    this.label,
  });
  final Widget child;
  final SubscriptionTier requiredTier;
  final VoidCallback? onUpgrade;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.grey.withValues(alpha:0.6),
              BlendMode.saturation,
            ),
            child: Opacity(opacity: 0.4, child: child),
          ),
          Positioned.fill(
            child: _LockOverlay(
              requiredTier: requiredTier,
              onUpgrade: onUpgrade,
              label: label,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simplified public API — uses opacity + saturation desaturation as blur proxy.
class FeatureLockGate extends StatelessWidget {
  const FeatureLockGate({
    super.key,
    required this.requiredTier,
    required this.child,
    required this.currentTier,
    this.onUpgrade,
    this.label,
  });

  final SubscriptionTier requiredTier;
  final Widget child;
  final SubscriptionTier currentTier;
  final VoidCallback? onUpgrade;
  final String? label;

  bool get _isLocked => !currentTier.meets(requiredTier);

  @override
  Widget build(BuildContext context) {
    if (!_isLocked) return child;
    return _LockedContent(
      requiredTier: requiredTier,
      onUpgrade: onUpgrade,
      label: label,
      child: child,
    );
  }
}

class _LockOverlay extends StatelessWidget {
  const _LockOverlay({required this.requiredTier, this.onUpgrade, this.label});
  final SubscriptionTier requiredTier;
  final VoidCallback? onUpgrade;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tierColor = AppColor.subscriptionTierColor(requiredTier.name);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.overlay,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha:0.15),
              shape: BoxShape.circle,
              border: Border.all(color: tierColor, width: 1.5),
            ),
            child: Icon(Icons.lock_outline_rounded, color: tierColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label ?? '${requiredTier.displayName} Feature',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "upgrade_to_unlock".tr(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          if (onUpgrade != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onUpgrade,
              style: FilledButton.styleFrom(
                backgroundColor: tierColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: Text(
                "upgrade_now".tr(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
