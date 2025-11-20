import '../Models/inventory/inventory_item.dart';
import '../Services/business_service.dart';

class InventoryHelpers {
  static final BusinessService _inventoryService = BusinessService();

  static String getStockStatusMessage(int count) {
    if (count == 0) {
      return 'Out of Stock';
    } else if (count < 3) {
      return 'Low Stock';
    } else if (count < 10) {
      return 'In Stock';
    } else {
      return 'Well Stocked';
    }
  }

  static String getStockEmoji(int count) {
    if (count == 0) {
      return '🔴';
    } else if (count < 3) {
      return '🟡';
    } else {
      return '🟢';
    }
  }

  static Future<bool> shouldShowLowStockAlert({int? shopId}) async {
    try {
      final lowStockItems = await _inventoryService.getLowStockItems(shopId: shopId);
      return lowStockItems.isNotEmpty;
    } catch (e) {
      print('Error checking low stock alert: $e');
      return false;
    }
  }

  static Future<String> formatLowStockAlert({int? shopId}) async {
    try {
      final lowStockItems = await _inventoryService.getLowStockItems(shopId: shopId);

      if (lowStockItems.isEmpty) return '';

      final itemNames = lowStockItems.map((item) => item.productName ?? 'Unknown Product').join(', ');
      return 'Low stock alert: $itemNames';
    } catch (e) {
      print('Error formatting low stock alert: $e');
      return '';
    }
  }

  static Future<Map<String, dynamic>> getInventoryAlertsSummary({int? shopId}) async {
    try {
      return await _inventoryService.getInventoryAlerts(shopId: shopId);
    } catch (e) {
      print('Error getting inventory alerts summary: $e');
      return {
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'critical_items': [],
      };
    }
  }

  static Future<List<InventoryItem>> getCriticalStockItems({int? shopId}) async {
    try {
      final allItems = await _inventoryService.getInventoryItems(shopId: shopId);
      return _inventoryService.getCriticalStockItemsFromList(allItems);
    } catch (e) {
      print('Error getting critical stock items: $e');
      return [];
    }
  }

  static Future<int> getLowStockCount({int? shopId}) async {
    try {
      final lowStockItems = await _inventoryService.getLowStockItems(shopId: shopId);
      return lowStockItems.length;
    } catch (e) {
      print('Error getting low stock count: $e');
      return 0;
    }
  }

  static Future<int> getOutOfStockCount({int? shopId}) async {
    try {
      final allItems = await _inventoryService.getInventoryItems(shopId: shopId);
      return allItems.where((item) => item.quantityInStock == 0).length;
    } catch (e) {
      print('Error getting out of stock count: $e');
      return 0;
    }
  }

  static Future<List<InventoryItem>> getItemsByStockLevel({
    int? shopId,
    required StockLevel level,
  }) async {
    try {
      final allItems = await _inventoryService.getInventoryItems(shopId: shopId);

      switch (level) {
        case StockLevel.critical:
          return allItems.where((item) => item.quantityInStock <= 2).toList();
        case StockLevel.low:
          return allItems.where((item) => item.quantityInStock > 2 && item.quantityInStock < 5).toList();
        case StockLevel.normal:
          return allItems.where((item) => item.quantityInStock >= 5 && item.quantityInStock < 10).toList();
        case StockLevel.wellStocked:
          return allItems.where((item) => item.quantityInStock >= 10).toList();
        case StockLevel.outOfStock:
          return allItems.where((item) => item.quantityInStock == 0).toList();
      }
    } catch (e) {
      print('Error getting items by stock level: $e');
      return [];
    }
  }

  static Future<void> updateItemStock({
    required String itemId,
    required int newQuantity,
    String? reason,
  }) async {
    try {
      await _inventoryService.updateItemQuantity(
        itemId: itemId,
        newQuantity: newQuantity,
        reason: reason,
      );
    } catch (e) {
      print('Error updating item stock: $e');
      rethrow;
    }
  }

  static Future<InventoryItem> addNewInventoryItem({
    required int productId,
    required int shopId,
    required int initialQuantity,
    String? notes,
  }) async {
    try {
      return await _inventoryService.addInventoryItem(
        productId: productId,
        shopId: shopId,
        initialQuantity: initialQuantity,
        notes: notes,
      );
    } catch (e) {
      print('Error adding new inventory item: $e');
      rethrow;
    }
  }
}

enum StockLevel {
  critical,    // <= 2
  low,         // 3-4
  normal,      // 5-9
  wellStocked, // >= 10
  outOfStock,  // 0
}
