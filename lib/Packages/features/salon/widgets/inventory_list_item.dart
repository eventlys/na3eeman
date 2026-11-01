// lib/Widgets/Inventory/inventory_list_item.dart
import 'package:flutter/material.dart';
import '../../../../Helpers/inventory_helpers.dart';
import '../../../Core/constants/app_color.dart';

class InventoryListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onIncreaseCount;
  final VoidCallback? onDelete;

  const InventoryListItem({
    super.key,
    required this.item,
    required this.onIncreaseCount,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        item['name'] ??
        item['productName'] ??
        item['product_name'] ??
        'Unknown Item';
    final count =
        item['count'] ??
        item['current_stock'] ??
        item['quantityInStock'] ??
        item['quantity_in_stock'] ??
        0;
    final description = item['description'];
    final minStockLevel =
        item['lowStockThreshold'] ?? item['low_stock_threshold'] ?? 3;

    final isLowStock = InventoryHelpers.isLowStock(count, minStockLevel);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColor.buttonBackgroundLight,
        border: Border.all(color: AppColor.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColor.trans,
          child: Text(
            count.toString(),
            style: TextStyle(
              color: isLowStock ? AppColor.lightWarning : AppColor.lightSuccess,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLowStock ? AppColor.lightWarning : AppColor.lightText,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${InventoryHelpers.getStockStatusMessage(count, minStockLevel)} ${InventoryHelpers.getStockEmoji(count, minStockLevel)}',
              style: TextStyle(
                color: isLowStock
                    ? AppColor.lightWarning
                    : AppColor.lightTextSecondary,
                fontSize: 12,
              ),
            ),
            if (description != null)
              Text(
                description,
                style: TextStyle(fontSize: 12, color: AppColor.lightTextHint),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: onIncreaseCount,
              tooltip: 'Increase count',
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 24),
                onPressed: onDelete,
                tooltip: 'Delete item',
              ),
          ],
        ),
      ),
    );
  }
}
