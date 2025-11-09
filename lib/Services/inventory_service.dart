// import 'dart:convert';
// import 'package:flutter/services.dart';
import '../Models/inventory_item.dart';

class InventoryService {
  // Use a list instead of final to allow modification
  static final List<InventoryItem> _mockInventory = [
    InventoryItem(
      id: '1',
      name: 'Shampoo',
      count: 5,
      category: 'Hair Care',
      minStockLevel: 3,
      price: 15.99,
      imageUrl: '',
    ),
    InventoryItem(
      id: '2',
      name: 'Conditioner',
      count: 2,
      category: 'Hair Care',
      minStockLevel: 3,
      price: 12.99,
      imageUrl: '',
    ),
    InventoryItem(
      id: '3',
      name: 'Hair Gel',
      count: 8,
      category: 'Styling',
      minStockLevel: 5,
      price: 8.99,
      imageUrl: '',
    ),
    InventoryItem(
      id: '4',
      name: 'Scissors',
      count: 1,
      category: 'Tools',
      minStockLevel: 2,
      price: 25.99,
      imageUrl: '',
    ),
    InventoryItem(
      id: '5',
      name: 'Razors',
      count: 4,
      category: 'Tools',
      minStockLevel: 5,
      price: 12.99,
      imageUrl: '',
    ),
  ];

  Future<List<InventoryItem>> getInventoryItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List<InventoryItem>.from(_mockInventory);
  }

  Future<InventoryItem> updateItemCount(String itemId, int newCount) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final item = _mockInventory.firstWhere((item) => item.id == itemId);
    final updatedItem = item.copyWith(count: newCount, lastUpdated: DateTime.now());

    final index = _mockInventory.indexWhere((item) => item.id == itemId);
    _mockInventory[index] = updatedItem;

    return updatedItem;
  }

  Future<InventoryItem> addItem(
    String name, {
    int initialCount = 0,
    String? description,
    String? category,
    int? minStockLevel,
    double? price,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newItem = InventoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      count: initialCount,
      description: description,
      lastUpdated: DateTime.now(),
      category: category,
      minStockLevel: minStockLevel,
      price: price,
      imageUrl: imageUrl,
    );

    _mockInventory.add(newItem);
    return newItem;
  }

  Future<void> deleteItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockInventory.removeWhere((item) => item.id == itemId);
  }

  List<InventoryItem> getLowStockItems(List<InventoryItem> items) {
    return items.where((item) => item.isLowStock).toList();
  }
}

