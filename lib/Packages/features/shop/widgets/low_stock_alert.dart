import 'package:flutter/material.dart';

import '../../../../Helpers/inventory_helpers.dart';

class LowStockAlert extends StatelessWidget {
  final List<InventoryItem> items;

  const LowStockAlert({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = items.where((item) => item.isLowStock).toList();

    if (lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Low Stock Alert',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            InventoryHelpers.formatLowStockAlert(lowStockItems),
            style: TextStyle(color: Colors.orange[800]),
          ),
          const SizedBox(height: 4),
          Text(
            '${lowStockItems.length} item${lowStockItems.length > 1 ? 's' : ''} need${lowStockItems.length > 1 ? '' : 's'} restocking',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }
}

