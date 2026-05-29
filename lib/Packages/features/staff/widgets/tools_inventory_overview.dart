import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Providers/main_providers.dart';
import '../../../../../core/theme/colors.dart';
import '../pages/tools_inventory_page.dart';

class ToolsAndInventoryOverview extends StatefulWidget {
  const ToolsAndInventoryOverview({super.key});

  @override
  State<ToolsAndInventoryOverview> createState() =>
      _ToolsAndInventoryOverviewState();
}

class _ToolsAndInventoryOverviewState extends State<ToolsAndInventoryOverview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final inventoryProvider = context.read<InventoryProvider>();
    final authProvider = context.read<AuthProvider>();
    final salonId = authProvider.user?.salonId;
    if (salonId != null) {
      await inventoryProvider.loadInventoryItems(salonId: salonId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (inventoryProvider.isLoading) {
      return _buildLoadingState(context);
    }

    if (inventoryProvider.error != null) {
      return _buildErrorState(context, inventoryProvider.error!);
    }

    final allItems = inventoryProvider.inventoryItems;

    if (allItems.isEmpty) {
      return _buildEmptyState(context);
    }

    final lowStockConsumables = allItems.where((item) {
      final category =
          item['category'] ??
          (item['product'] is Map ? item['product']['category'] : null);
      final stock = item['quantityInStock'] ?? item['quantity_in_stock'] ?? 0;
      final threshold =
          item['lowStockThreshold'] ?? item['low_stock_threshold'] ?? 10;
      return category == 'CONSUMABLE' && stock <= threshold;
    }).toList();

    final kitItems = allItems.where((item) {
      final category =
          item['category'] ??
          (item['product'] is Map ? item['product']['category'] : null);
      return category == 'EQUIPMENT';
    }).toList();

    final consumablesAlert = lowStockConsumables.isNotEmpty
        ? 'Low Stock: ${lowStockConsumables.first['product_name'] ?? (lowStockConsumables.first['product'] is Map ? lowStockConsumables.first['product']['product_name'] : 'Item')}'
        : 'All items stocked';

    final kitReady = kitItems
        .where(
          (item) =>
              (item['quantityInStock'] ?? item['quantity_in_stock'] ?? 0) > 0,
        )
        .length;
    final kitTotal = kitItems.length;
    final kitSubtitle = kitTotal > 0
        ? '$kitReady/$kitTotal Items Ready'
        : 'No items added';

    return Column(
      children: [
        _buildToolCard(
          context,
          'Personal Kit',
          kitSubtitle,
          Icons.handyman_rounded,
          onTap: () => _navigateInventory(context, 'EQUIPMENT'),
        ),
        const SizedBox(height: 12),
        _buildToolCard(
          context,
          'Consumables',
          consumablesAlert,
          Icons.inventory_2_rounded,
          isAlert: lowStockConsumables.isNotEmpty,
          onTap: () => _navigateInventory(context, 'CONSUMABLE'),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Column(
      children: [
        _buildSkeletonCard(context),
        const SizedBox(height: 12),
        _buildSkeletonCard(context),
      ],
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 80,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha:0.05)
              : AppColors.almostBlack50,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha:0.05),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha:
                    0.05,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 8,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha:
                    0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return _buildToolCard(
      context,
      'Inventory',
      'No items found. Tap to add.',
      Icons.inventory_2_outlined,
      onTap: () => _navigateInventory(context, null),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return _buildToolCard(
      context,
      'Load Error',
      'Retry loading inventory',
      Icons.error_outline_rounded,
      isAlert: true,
      onTap: () => _fetchData(),
    );
  }

  void _navigateInventory(BuildContext context, String? category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ToolsAndInventoryPage(initialCategory: category),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    bool isAlert = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAlert
                ? AppColors.error.withValues(alpha:0.3)
                : (isDark
                      ? AppColors.white.withValues(alpha:0.1)
                      : AppColors.almostBlack50),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isAlert ? AppColors.error : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isAlert
                          ? AppColors.error
                          : AppColors.almostBlack300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.almostBlack200,
            ),
          ],
        ),
      ),
    );
  }
}
