// lib/Widgets/Inventory/inventory_alert_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Helpers/inventory_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/utils/formatters.dart';


class InventoryAlertCard extends StatelessWidget {
  final VoidCallback onViewAll;
  final int? shopId;

  const InventoryAlertCard({
    super.key,
    required this.onViewAll,
    this.shopId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final lowStockItems = inventoryProvider.lowStockItems;

        return Card(
          elevation: 4,
          color: AppColor.lightCard,
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
                        color: AppColor.lightText,
                      ),
                    ),
                    Badge(
                      backgroundColor: AppColor.lightError,
                      label: Text(lowStockItems.length.toString()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (inventoryProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColor.loadingPrimaryLight),
                      ),
                    ),
                  )
                else if (inventoryProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.error,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Error loading inventory data',
                          style: TextStyle(
                            color: AppColor.lightError,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (lowStockItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.check,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No low stock items',
                          style: TextStyle(
                            color: AppColor.lightTextHint,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...lowStockItems.take(3).map((item) => _buildInventoryItem(item)),
                if (lowStockItems.length > 3)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'View all ${lowStockItems.length} items',
                      style: TextStyle(
                        color: AppColor.lightPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryItem(Map<String, dynamic> item) {
    final name = item['name'] ?? item['product_name'] ?? 'Unknown Item';
    final currentStock = item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
    final minStockLevel = item['min_stock_level'] ?? 3;
    final category = item['category'];
    final price = item['price'];

    final isCritical = InventoryHelpers.isCriticalStock(currentStock, minStockLevel);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColor.lightPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          AppImages.inventory,
          width: 20,
          height: 20,
          color: AppColor.lightPrimary,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: AppColor.lightText,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                isCritical ? AppImages.warning : AppImages.warning_view,
                width: 16,
                height: 16,
                color: isCritical ? AppColor.lightError : AppColor.lightWarning,
              ),
              const SizedBox(width: 4),
              Text(
                'Stock: $currentStock (Min: $minStockLevel)',
                style: TextStyle(
                  color: isCritical
                    ? AppColor.lightError
                    : AppColor.lightWarning,
                ),
              ),
            ],
          ),
          if (category != null)
            Text(
              'Category: $category',
              style: TextStyle(
                fontSize: 12,
                color: AppColor.lightTextSecondary,
              ),
            ),
        ],
      ),
      trailing: price != null ? Text(
        Formatters.formatCurrency(price),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColor.lightPrimary,
        ),
      ) : null,
    );
  }
}

