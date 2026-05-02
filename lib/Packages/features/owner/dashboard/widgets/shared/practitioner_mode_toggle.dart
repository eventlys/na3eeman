import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import '../../../../../../core/enums/owner_enums.dart';

/// Manager ↔ Practitioner mode toggle. Only visible to owners who are
/// also practitioners and on Studio tier or above.
class PractitionerModeToggle extends StatelessWidget {
  const PractitionerModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();

    // Not visible to pure managers or Artisan owners
    if (!owner.isPractitioner ||
        !owner.canAccess(FeatureKey.practitionerModeToggle)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isManager = owner.isManagerMode;

    return GestureDetector(
      onTap: owner.toggleMode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isManager
              ? theme.primaryColor.withOpacity(0.12)
              : theme.colorScheme.secondary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isManager
                ? theme.primaryColor.withOpacity(0.4)
                : theme.colorScheme.secondary.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isManager ? Icons.business_center_rounded : Icons.person_rounded,
              size: 18,
              color: isManager
                  ? theme.primaryColor
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              owner.mode.displayLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isManager
                    ? theme.primaryColor
                    : theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.swap_horiz_rounded,
              size: 16,
              color: isManager
                  ? theme.primaryColor.withOpacity(0.6)
                  : theme.colorScheme.secondary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
