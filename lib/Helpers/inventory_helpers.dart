import '../Services/business_service.dart';

class InventoryHelpers {
  final InventoryService _inventoryService;

  InventoryHelpers(this._inventoryService);

  static String getStockStatusMessage(int currentStock, int? minStockLevel) {
    final minStock = minStockLevel ?? 3;

    if (currentStock == 0) {
      return 'Out of Stock';
    } else if (currentStock <= minStock) {
      return 'Low Stock';
    } else if (currentStock < 10) {
      return 'In Stock';
    } else {
      return 'Well Stocked';
    }
  }

  static String getStockEmoji(int currentStock, int? minStockLevel) {
    final minStock = minStockLevel ?? 3;

    if (currentStock == 0) {
      return '🔴';
    } else if (currentStock <= minStock) {
      return '🟡';
    } else {
      return '🟢';
    }
  }

  static bool isCriticalStock(int currentStock, int? minStockLevel) {
    final minStock = minStockLevel ?? 3;
    return currentStock <= minStock;
  }

  static bool isLowStock(int currentStock, int? minStockLevel) {
    final minStock = minStockLevel ?? 3;
    return currentStock > 0 && currentStock <= minStock;
  }

  Future<bool> shouldShowLowStockAlert({int? salonId}) async {
    try {
      final lowStockItems = await _inventoryService.getLowStockItems(
        salonId: salonId,
      );
      return lowStockItems.isNotEmpty;
    } catch (e) {
      print('Error checking low stock alert: $e');
      return false;
    }
  }

  Future<String> formatLowStockAlert({int? salonId}) async {
    try {
      final lowStockItems = await _inventoryService.getLowStockItems(
        salonId: salonId,
      );

      if (lowStockItems.isEmpty) return '';

      final itemNames = lowStockItems
          .map(
            (item) => item['name'] ?? item['product_name'] ?? 'Unknown Product',
          )
          .join(', ');
      return 'Low stock alert: $itemNames';
    } catch (e) {
      print('Error formatting low stock alert: $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> getInventoryAlertsSummary({int? salonId}) async {
    try {
      return await _inventoryService.getInventoryAlerts(salonId: salonId);
    } catch (e) {
      print('Error getting inventory alerts summary: $e');
      return {
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'critical_items': [],
      };
    }
  }

  Future<List<dynamic>> getCriticalStockItems({int? salonId}) async {
    try {
      final allItems = await _inventoryService.getInventoryItems(
        salonId: salonId,
      );
      return _inventoryService.getCriticalStockItemsFromList(allItems);
    } catch (e) {
      print('Error getting critical stock items: $e');
      return [];
    }
  }

  Future<int> getLowStockCount({int? salonId}) async {
    try {
      final lowStockItems = await _inventoryService.getLowStockItems(
        salonId: salonId,
      );
      return lowStockItems.length;
    } catch (e) {
      print('Error getting low stock count: $e');
      return 0;
    }
  }

  Future<int> getOutOfStockCount({int? salonId}) async {
    try {
      final allItems = await _inventoryService.getInventoryItems(
        salonId: salonId,
      );
      return allItems.where((item) {
        final stock = item['current_stock'] ?? item['quantity_in_stock'] ?? 1;
        return stock == 0;
      }).length;
    } catch (e) {
      print('Error getting out of stock count: $e');
      return 0;
    }
  }

  Future<List<dynamic>> getItemsByStockLevel({
    int? salonId,
    required StockLevel level,
  }) async {
    try {
      final allItems = await _inventoryService.getInventoryItems(
        salonId: salonId,
      );

      switch (level) {
        case StockLevel.critical:
          return allItems.where((item) {
            final stock =
                item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
            return stock <= 2;
          }).toList();
        case StockLevel.low:
          return allItems.where((item) {
            final stock =
                item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
            return stock > 2 && stock < 5;
          }).toList();
        case StockLevel.normal:
          return allItems.where((item) {
            final stock =
                item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
            return stock >= 5 && stock < 10;
          }).toList();
        case StockLevel.wellStocked:
          return allItems.where((item) {
            final stock =
                item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
            return stock >= 10;
          }).toList();
        case StockLevel.outOfStock:
          return allItems.where((item) {
            final stock =
                item['current_stock'] ?? item['quantity_in_stock'] ?? 1;
            return stock == 0;
          }).toList();
      }
    } catch (e) {
      print('Error getting items by stock level: $e');
      return [];
    }
  }
}

enum StockLevel {
  critical, // <= 2
  low, // 3-4
  normal, // 5-9
  wellStocked, // >= 10
  outOfStock, // 0
}
