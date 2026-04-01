import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/enums/owner_enums.dart'; // Added
import '../../../../../../Providers/features/owner_provider.dart';
import '../shared/practitioner_mode_toggle.dart';
import 'package:easy_localization/easy_localization.dart';

/// Switch-view toggle card that also shows the PractitionerModeToggle.
/// Unique to Studio tier and above.
class SwitchViewToggleWidget extends StatelessWidget {
  const SwitchViewToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<OwnerProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('view_mode'.tr(),
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 10),
          const PractitionerModeToggle(),
          const SizedBox(height: 8),
          Text(
            owner.mode.description,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
