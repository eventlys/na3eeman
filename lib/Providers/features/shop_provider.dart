// import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/shop/shops_model.dart';
import '../../Models/shop/branch_model.dart';
import '../../Models/shop/shop_service_model.dart';
import '../../Models/inventory/inventory_item.dart';

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
    await Future.delayed(const Duration(seconds: 1));
    _shops = [
      Shop(
        id: 1,
        shopName: 'Modern Cuts Barbershop',
        shopPhonNum: '+962791234567',
        shopDescription:
            'Premium barbershop offering modern haircuts and grooming services',
        location: 'Abdali, Amman, Jordan',
        lat: 31.9539,
        lng: 35.9106,
        openingTime: '09:00',
        closingTime: '20:00',
        shopSeats: 5,
        shopStaff: 3,
        confirmedPhone: true,
        ownerId: _authProvider?.user?.id ?? 1,
        avgRating: 4.5,
      ),
    ];
  }

  Future<void> loadBranches() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _branches = [
      Branch(
        id: 1,
        name: 'Modern Cuts - Abdali',
        address: 'Abdali Mall, Level 2, Amman, Jordan',
        phone: '+962791234567',
        isOpen: true,
        todayAppointments: 15,
        todayRevenue: 450.0,
        manager: 'Sarah Wilson',
        monthlyRevenue: 13500.0,
        totalSales: 450,
        lowStockItems: 3,
        email: 'abdali@moderncuts.com',
        openingDate: DateTime(2023, 1, 15),
        totalEmployees: 5,
        shopId: 1,
        openingTime: '09:00',
        closingTime: '20:00',
        seats: 5,
        staffCount: 3,
        lat: 31.9539,
        lng: 35.9106,
      ),
    ];
  }

  Future<void> loadServices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _services = [
      ShopService(
        name: 'Classic Haircut',
        price: '25.00',
        duration: '30min',
        type: 'OPTION',
        id: 1,
        description: 'Traditional haircut with scissor and clipper work',
        shopId: 1,
      ),
    ];
  }

  Future<void> loadInventory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _inventory = [
      InventoryItem(
        id: '1',
        productId: 1,
        shopId: 1,
        quantityInStock: 15,
        lastUpdated: DateTime.now(),
        productName: 'Hair Styling Gel',
        productDescription: 'Premium hold styling gel',
        productPrice: 12.99,
      ),
    ];
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
}
