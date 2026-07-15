import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import '../../../../../../Providers/features/inventory_provider.dart';

/// Compliance / medical forms tracker (Elite tier).
/// Repurposed to track inventory compliance: items below minimum stock threshold
/// are flagged as non-compliant. This uses real inventory data from InventoryProvider
/// until a dedicated compliance backend endpoint is implemented.
class ComplianceTrackerWidget extends StatelessWidget {
  const ComplianceTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inventory = context.watch<InventoryProvider>();
    final owner = context.watch<OwnerProvider>();

    if (!inventory.isLoading &&
        inventory.items.isEmpty &&
        owner.activeSalonId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inventory.loadInventory(owner.activeSalonId!);
      });
    }

    // Group all inventory into compliance categories
    final all = inventory.items;
    final belowThreshold = all.where((i) => i.quantityInStock < 5).toList();
    final adequate = all.where((i) => i.quantityInStock >= 5).toList();

    // Build summary compliance items
    final complianceItems = [
      _ComplianceItem(
        name: 'Stock Levels',
        completed: adequate.length,
        total: all.isEmpty ? 1 : all.length,
      ),
      _ComplianceItem(
        name: 'Low Stock Items',
        completed: all.length - belowThreshold.length,
        total: all.isEmpty ? 1 : all.length,
      ),
      _ComplianceItem(
        name: 'Critical Stock',
        completed: all.where((i) => i.quantityInStock == 0).isEmpty ? 1 : 0,
        total: 1,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.verified_user_rounded,
              size: 18,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              "compliance_tracker".tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (inventory.isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        if (all.isEmpty && !inventory.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No inventory data to track compliance.',
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
          ),
        const SizedBox(height: 14),
        ...complianceItems.map((f) {
          final pct = f.total == 0 ? 0.0 : f.completed / f.total;
          final done = f.completed == f.total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      f.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${f.completed}/${f.total}',
                      style: TextStyle(
                        color: done ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    done ? Colors.green : Colors.orange,
                  ),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ComplianceItem {
  final String name;
  final int completed;
  final int total;
  const _ComplianceItem({
    required this.name,
    required this.completed,
    required this.total,
  });
}
