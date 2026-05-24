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
    if (i is Map)
      return i['category'] == 'CONSUMABLE' || i['category'] == 'Consumables';
    return false;
  }).toList();
  List<dynamic> get personalKitItems => _inventoryItems.where((i) {
    if (i is Map)
      return i['category'] == 'EQUIPMENT' || i['category'] == 'Personal Kit';
    return false;
  }).toList();
  List<dynamic> get generalItems => _inventoryItems.where((i) {
    if (i is Map)
      return i['category'] == 'GENERAL' || i['category'] == 'General';
    return false;
  }).toList();
  List<dynamic> get inventoryItems => _inventoryItems;

  Future<void> loadInventory(
    int salonId, {
    bool? lowStockOnly,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventoryItems = await _inventoryService.getInventoryItems(
        salonId: salonId,
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
    int? salonId,
    bool? lowStockOnly,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventoryItems = await _inventoryService.getInventoryItems(
        salonId: salonId,
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

  Future<void> addInventoryItem({
    int? productId,
    String? productName,
    double? productPrice,
    String? category,
    required int salonId,
    required int initialQuantity,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItem = await _inventoryService.addInventoryItem(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        category: category,
        salonId: salonId,
        initialQuantity: initialQuantity,
        notes: notes,
      );
      _inventoryItems.add(newItem);
    } catch (e) {
      _error = 'Failed to add inventory item: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLowStockItems({int? salonId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lowStockItems = await _inventoryService.getLowStockItems(
        salonId: salonId,
      );
    } catch (e) {
      _error = 'Failed to load low stock items: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getInventoryAlerts({int? salonId}) async {
    return await _inventoryHelpers.getInventoryAlertsSummary(salonId: salonId);
  }

  Future<void> refreshInventoryData({int? salonId}) async {
    await loadLowStockItems(salonId: salonId);
  }
}
