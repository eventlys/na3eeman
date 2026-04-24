import 'package:na3eeman/l10n/app_localizations.dart';
// lib/Widgets/Inventory/low_stock_alert.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import 'package:easy_localization/easy_localization.dart';

class LowStockDetailedAlert extends StatelessWidget {
  final int? salonId;

  const LowStockDetailedAlert({super.key, this.salonId});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final lowStockItems = inventoryProvider.lowStockItems;

        if (lowStockItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.lightWarning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.lightWarning),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    AppImages.warning,
                    width: 20,
                    height: 20,
                    color: AppColor.lightWarning,
                  ),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.lowStockAlert,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColor.lightWarning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatLowStockAlert(lowStockItems),
                style: TextStyle(
                  color: AppColor.lightWarning.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${lowStockItems.length} item${lowStockItems.length > 1 ? 's' : ''} need${lowStockItems.length > 1 ? '' : 's'} restocking',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.lightWarning.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatLowStockAlert(List<dynamic> lowStockItems) {
    if (lowStockItems.isEmpty) return '';

    final itemNames = lowStockItems.take(3).map((item) {
      return item['name'] ?? item['product_name'] ?? 'Unknown Product';
    }).join(', ');

    if (lowStockItems.length > 3) {
      return '$itemNames and ${lowStockItems.length - 3} more items are low in stock';
    } else {
      return '$itemNames ${lowStockItems.length == 1 ? 'is' : 'are'} low in stock';
    }
  }
}
