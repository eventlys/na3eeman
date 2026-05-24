import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../Helpers/inventory_helpers.dart';

class LowStockSimpleAlert extends StatelessWidget {
  final List<dynamic> items;

  const LowStockSimpleAlert({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = items.where((item) {
      final count =
          item['count'] ??
          item['current_stock'] ??
          item['quantity_in_stock'] ??
          0;
      final minStockLevel = item['min_stock_level'] ?? 3;
      return InventoryHelpers.isLowStock(count, minStockLevel);
    }).toList();

    if (lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[800]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "low_stock_alert".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  '${lowStockItems.length} item${lowStockItems.length == 1 ? '' : 's'} need${lowStockItems.length == 1 ? 's' : ''} restocking',
                  style: TextStyle(color: Colors.orange[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
