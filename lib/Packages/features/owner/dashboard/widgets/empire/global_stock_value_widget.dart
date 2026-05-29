import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/inventory_provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';

/// Global stock value across all branches (Empire tier).
/// Uses real inventory data from InventoryProvider for the current salon
/// until a multi-branch aggregation endpoint is implemented.
class GlobalStockValueWidget extends StatelessWidget {
  const GlobalStockValueWidget({super.key});

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

    // Calculate total stock value from real inventory items
    // value = quantity_in_stock × product_price (product_price not yet in InventoryItem model)
    // For now we show total item count as stock health indicator
    final totalItems = inventory.items.fold<int>(
      0,
      (sum, item) => sum + (item.quantityInStock as int),
    );
    final lowStockCount = inventory.items
        .where((i) => i.quantityInStock < 5)
        .length;
    final consumablesCount = inventory.consumables.length;
    final equipmentCount = inventory.personalKitItems.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha:0.08),
            theme.colorScheme.secondary.withValues(alpha:0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_rounded,
                size: 18,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                "global_stock_value".tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.hintColor,
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
          const SizedBox(height: 8),
          Text(
            '$totalItems Units',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                lowStockCount == 0
                    ? Icons.trending_up_rounded
                    : Icons.warning_amber_rounded,
                size: 14,
                color: lowStockCount == 0 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                lowStockCount == 0
                    ? 'All stock levels healthy'
                    : '$lowStockCount items low on stock',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: lowStockCount == 0 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat('Consumables', '$consumablesCount items', theme),
              _MiniStat('Equipment', '$equipmentCount items', theme),
              _MiniStat(
                'Low Stock',
                '$lowStockCount',
                theme,
                valueColor: lowStockCount > 0 ? Colors.red : Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;
  const _MiniStat(this.label, this.value, this.theme, {this.valueColor});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: valueColor,
        ),
      ),
      Text(label, style: TextStyle(fontSize: 11, color: theme.hintColor)),
    ],
  );
}
