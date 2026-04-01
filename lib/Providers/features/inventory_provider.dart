import 'package:flutter/material.dart';
import '../../Services/business_service.dart';
import '../../Helpers/inventory_helpers.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService;
  final InventoryHelpers _inventoryHelpers;

  List<dynamic> _lowStockItems = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider({
    required InventoryService inventoryService,
    required InventoryHelpers inventoryHelpers,
  }) : _inventoryService = inventoryService,
       _inventoryHelpers = inventoryHelpers;

  List<dynamic> get lowStockItems => _lowStockItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get lowStockCount => _lowStockItems.length;

  List<dynamic> _inventoryItems = [];

  List<dynamic> get items => _inventoryItems;
  List<dynamic> get consumables => _inventoryItems.where((i) {
    if (i is Map) return i['category'] == 'CONSUMABLE';
    // Fallback for typed objects if applicable
    return false;
  }).toList();
  List<dynamic> get personalKitItems => _inventoryItems.where((i) {
    if (i is Map) return i['category'] == 'EQUIPMENT';
     return false;
  }).toList();
  List<dynamic> get inventoryItems => _inventoryItems;

  Future<void> loadInventory(int shopId, {
    bool? lowStockOnly,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
 
     try {
       _inventoryItems = await _inventoryService.getInventoryItems(
         shopId: shopId,
         lowStockOnly: lowStockOnly,
         category: category,
       );
     } catch (e) {
       _error = 'Failed to load inventory items: ${e.toString()}';
     } finally {
       _isLoading = false;
       notifyListeners();
     }
   }
 
   Future<void> loadInventoryItems({
     int? shopId,
     bool? lowStockOnly,
     String? category,
   }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventoryItems = await _inventoryService.getInventoryItems(
        shopId: shopId,
        lowStockOnly: lowStockOnly,
        category: category,
      );
    } catch (e) {
      _error = 'Failed to load inventory items: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItem(String itemId) async {
    _inventoryItems.removeWhere((item) {
      final id = item['id']?.toString() ?? item['_id']?.toString();
      return id == itemId;
    });
    notifyListeners();
  }

  Future<void> loadLowStockItems({int? shopId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lowStockItems = await _inventoryService.getLowStockItems(shopId: shopId);
    } catch (e) {
      _error = 'Failed to load low stock items: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getInventoryAlerts({int? shopId}) async {
    return await _inventoryHelpers.getInventoryAlertsSummary(shopId: shopId);
  }

  Future<void> refreshInventoryData({int? shopId}) async {
    await loadLowStockItems(shopId: shopId);
  }
}
