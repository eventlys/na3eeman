// import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/shop/shops_model.dart';
import '../../Models/shop/branch_model.dart';
import '../../Models/shop/shop_service_model.dart';
import '../../Models/inventory/inventory_item.dart';
import '../../Services/api/api_service.dart';

class ShopProvider extends BaseProvider {
  List<Shop> _shops = [];
  List<Branch> _branches = [];
  List<ShopService> _services = [];
  List<InventoryItem> _inventory = [];
  Shop? _selectedShop;
  Branch? _selectedBranch;
  AuthProvider? _authProvider;

  // Getters
  List<Shop> get shops => _shops;
  List<Branch> get branches => _branches;
  List<ShopService> get services => _services;
  List<InventoryItem> get inventory => _inventory;
  Shop? get selectedShop => _selectedShop;
  Branch? get selectedBranch => _selectedBranch;

  List<Shop> get manageableShops {
    if (_authProvider?.isOwner != true) return [];
    return _shops
        .where((shop) => shop.ownerId == _authProvider?.user?.id)
        .toList();
  }

  List<ShopService> get availableServices {
    if (_selectedShop != null) {
      return _services
          .where((service) => service.shopId == _selectedShop?.id)
          .toList();
    }
    return _services;
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      loadShopData();
    }
  }

  Future<void> loadShopData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([
        loadShops(),
        loadBranches(),
        loadServices(),
        loadInventory(),
      ]);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadShops() async {
    try {
      final response = await ApiService().get('/shops/shops/');
      print('Frontend: loadShops Response: $response');
      final List<dynamic> results = response['results'] ?? response['data'] ?? [];
      _shops = results.map<Shop>((json) => Shop.fromJson(json as Map<String, dynamic>)).toList();
      if (_shops.isNotEmpty && _selectedShop == null) {
         _selectedShop = _shops.first; // Default select
      }
    } catch (e) {
      print('Frontend: loadShops Error: $e');
    }
  }

  Future<void> loadBranches() async {
    try {
      if (_selectedShop == null) return;
      final response = await ApiService().get('/shops/shops/${_selectedShop!.id}/branches/');
      print('Frontend: loadBranches Response: $response');
      final List<dynamic> results = response['results'] ?? response['data'] ?? [];
      _branches = results.map<Branch>((json) => Branch.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Frontend: loadBranches Error: $e');
    }
  }

  Future<void> loadServices() async {
    try {
      if (_selectedShop == null) return;
      final response = await ApiService().get('/shops/${_selectedShop!.id}/services/');
      print('Frontend: loadServices Response: $response');
      final List<dynamic> results = response['results'] ?? response['data'] ?? response['options'] ?? [];
      _services = results.map<ShopService>((json) => ShopService.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Frontend: loadServices Error: $e');
    }
  }

  Future<void> loadInventory() async {
    try {
      if (_selectedShop == null) return;
      final response = await ApiService().get('/shops/${_selectedShop!.id}/inventory/');
      print('Frontend: loadInventory Response: $response');
      final List<dynamic> results = response['results'] ?? response['data'] ?? [];
      _inventory = results.map<InventoryItem>((json) => InventoryItem.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Frontend: loadInventory Error: $e');
    }
  }

  Future<void> selectShop(Shop shop) async {
    _selectedShop = shop;
    _selectedBranch = null;
    await loadShopSpecificData();
    notifyListeners();
  }

  Future<void> selectBranch(Branch branch) async {
    _selectedBranch = branch;
    notifyListeners();
  }

  Future<void> loadShopSpecificData() async {
    if (_selectedShop != null) {
      await Future.wait([loadServices(), loadInventory()]);
    }
  }

  Future<void> createProductOnBackend({
    required String name,
    required double price,
    required String description,
    required int stock,
  }) async {
    if (_selectedShop != null) {
      try {
        final data = {
          'product_name': name,
          'product_price': price,
          'product_description': description,
          'category': 'Consumables', // Default for demo
          'stock': stock
        };
        print('Frontend: Creating Product with data: $data');
        // Actual endpoint logic here or simulation with endpoint setups
        final response = await ApiService().post('/shops/${_selectedShop!.id}/inventory/', data: data);
        print('Frontend: createProduct Response: $response');
        await loadInventory(); // Reload to capture new list
      } catch (e) {
        print('Frontend: createProduct Error: $e');
      }
    }
  }

  Future<void> adjustStockOnBackend(String inventoryId, int increment) async {
    try {
      print('Frontend: Adjusting Stock count for $inventoryId by $increment');
      // Simulated endpoint PUT logic
      final response = await ApiService().post('/shops/inventory/$inventoryId/adjust_stock/', data: {'increment': increment});
      print('Frontend: adjustStock Response: $response');
      await loadInventory(); // Reload to capture new quantities
    } catch (e) {
      print('Frontend: adjustStock Error: $e');
      // For demo, apply locally if API isn't ready
      final index = _inventory.indexWhere((item) => item.id == inventoryId);
      if (index != -1) {
        _inventory[index] = InventoryItem(
          id: _inventory[index].id,
          productId: _inventory[index].productId,
          shopId: _inventory[index].shopId,
          quantityInStock: _inventory[index].quantityInStock + increment,
          lastUpdated: DateTime.now(),
          productName: _inventory[index].productName,
          productDescription: _inventory[index].productDescription,
          productPrice: _inventory[index].productPrice,
        );
        notifyListeners();
      }
    }
  }

  Future<void> updateShopOnBackend({required String name, required String phone, required String location, required String description}) async {
    if (_selectedShop != null) {
      try {
        final data = {
          'shop_name': name,
          'shop_phone_num': phone,
          'location': location,
          'shop_description': description,
        };
        print('Frontend: Updating Shop on Backend with data: $data');
        final response = await ApiService().put('/shops/shops/${_selectedShop!.id}/', data: data);
        print('Frontend: updateShopOnBackend Response: $response');
        _selectedShop = Shop.fromJson(response);
        notifyListeners();
      } catch (e) {
        print('Frontend: updateShopOnBackend Error: $e');
      }
    }
  }

  void updateShopInMemory({required String name, required String phone, required String location, required String description}) {
    if (_selectedShop != null) {
      _selectedShop = Shop(
        id: _selectedShop!.id,
        shopName: name,
        shopPhonNum: phone,
        shopDescription: description,
        location: location,
        lat: _selectedShop!.lat,
        lng: _selectedShop!.lng,
        openingTime: _selectedShop!.openingTime,
        closingTime: _selectedShop!.closingTime,
        shopSeats: _selectedShop!.shopSeats,
        shopStaff: _selectedShop!.shopStaff,
        confirmedPhone: _selectedShop!.confirmedPhone,
        ownerId: _selectedShop!.ownerId,
        avgRating: _selectedShop!.avgRating,
      );
      
      // Also update in list if any list iterates it
      final index = _shops.indexWhere((s) => s.id == _selectedShop!.id);
      if (index != -1) {
        _shops[index] = _selectedShop!;
      }
      notifyListeners();
    }
  }
}
