import '../Models/inventory_item.dart';

class InventoryHelpers {
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

  static bool shouldShowLowStockAlert(List<InventoryItem> items) {
    return items.any((item) => item.isLowStock);
  }

  static String formatLowStockAlert(List<InventoryItem> lowStockItems) {
    if (lowStockItems.isEmpty) return '';

    final itemNames = lowStockItems.map((item) => item.name).join(', ');
    return 'Low stock alert: $itemNames';
  }
}

