import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import '../../../../../../Providers/features/inventory_provider.dart';

/// Consumable waste meter for Elite tier.
/// Reads real inventory data from InventoryProvider (Consumables category).
/// Shows usage vs a safe-stock threshold derived from quantity_in_stock.
class ConsumableWasteMeterWidget extends StatelessWidget {
  const ConsumableWasteMeterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inventory = context.watch<InventoryProvider>();
    final owner = context.watch<OwnerProvider>();

    // Load consumables if not already loaded
    if (!inventory.isLoading &&
        inventory.consumables.isEmpty &&
        owner.activeSalonId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inventory.loadInventory(owner.activeSalonId!);
      });
    }

    final consumables = inventory.consumables;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.recycling_rounded, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              "consumable_waste".tr(),
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
        const SizedBox(height: 14),
        if (consumables.isEmpty && !inventory.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No consumable inventory data.',
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
          ),
        ...consumables.take(6).map((item) {
          final name = item.productName;
          final qty = item.quantityInStock;
          // Define a simple threshold: 10 units is the low-stock marker
          // Items below threshold are flagged as overused/depleted
          const threshold = 10;
          final depleted = qty < threshold;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$qty units in stock',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      depleted
                          ? Icons.arrow_downward_rounded
                          : Icons.check_circle_outline_rounded,
                      color: depleted ? Colors.red : Colors.green,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
