import 'package:flutter/material.dart';

import '../../../../Helpers/inventory_helpers.dart';


class InventoryListItem extends StatelessWidget {
  final InventoryItem item;
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0x4dffffff),
        border: Border.all(color: const Color(0x80ffffff)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Text(
            item.count.toString(),
            style: TextStyle(
              color: item.isLowStock ? Colors.orange : Colors.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: item.isLowStock ? Colors.orange[800] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${InventoryHelpers.getStockStatusMessage(item.count)} ${InventoryHelpers.getStockEmoji(item.count)}',
              style: TextStyle(
                color: item.isLowStock ? Colors.orange[700] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (item.description != null)
              Text(
                item.description!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Image.asset('assets/icons/plus.png', width: 24, height: 24),
              onPressed: onIncreaseCount,
              tooltip: 'Increase count',
            ),
            if (onDelete != null)
              IconButton(
                icon: Image.asset('assets/icons/trash.png', width: 24, height: 24),
                onPressed: onDelete,
                tooltip: 'Delete item',
              ),
          ],
        ),
      ),
    );
  }
}

