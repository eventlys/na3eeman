import 'package:flutter/material.dart';

import '../../../Core/utils/formatters.dart';


class InventoryAlertCard extends StatelessWidget {
  final List<InventoryItem> lowStockItems;
  final VoidCallback onViewAll;

  const InventoryAlertCard({
    super.key,
    required this.lowStockItems,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Badge(
                  backgroundColor: AppColors.errorColor,
                  label: Text(lowStockItems.length.toString()),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (lowStockItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No low stock items',
                  style: TextStyle(
                    color: AppColors.textColor.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              ...lowStockItems.take(3).map((item) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.inventory_2, color: AppColors.primaryColor),
                ),
                title: Text(item.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock: ${item.currentStock} (Min: ${item.minStockLevel ?? 3})',
                      style: TextStyle(
                        color: item.isCriticalStock 
                          ? AppColors.errorColor
                          : AppColors.warningColor,
                      ),
                    ),
                    if (item.category != null)
                      Text(
                        'Category: ${item.category}',
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                trailing: item.price != null ? Text(
                  Formatters.formatCurrency(item.price!),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ) : null,
              )),
            if (lowStockItems.length > 3)
              TextButton(
                onPressed: onViewAll,
                child: Text('View all ${lowStockItems.length} items'),
              ),
          ],
        ),
      ),
    );
  }
}

