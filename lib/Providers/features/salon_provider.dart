// import 'dart:io';
import 'dart:io';
// import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/salon/salons_model.dart';
import '../../Models/salon/branch_model.dart';
import '../../Models/salon/salon_service_model.dart';
import '../../Models/inventory/inventory_item.dart';
import '../../Services/api/api_service.dart';
import '../../Services/api/endpoints.dart';

class SalonProvider extends BaseProvider {
  List<Salon> _salons = [];
  List<Branch> _branches = [];
  List<SalonService> _services = [];
  List<InventoryItem> _inventory = [];
  Salon? _selectedSalon;
  Branch? _selectedBranch;
  AuthProvider? _authProvider;

  // Getters
  List<Salon> get salons => _salons;
  List<Branch> get branches => _branches;
  List<SalonService> get services => _services;
  List<InventoryItem> get inventory => _inventory;
  Salon? get selectedSalon => _selectedSalon;
  Branch? get selectedBranch => _selectedBranch;

  List<Salon> get manageableSalons {
    if (_authProvider?.isOwner != true) return [];
    return _salons
        .where((salon) => salon.ownerId == _authProvider?.user?.id)
        .toList();
  }

  List<SalonService> get availableServices {
    if (_selectedSalon != null) {
      return _services
          .where((service) => service.salonId == _selectedSalon?.id)
          .toList();
    }
    return _services;
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      loadSalonData();
    }
  }

  Future<void> loadSalonData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([
        loadSalons(),
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

  Future<void> loadSalons() async {
    try {
      final response = await ApiService().get(Endpoints.salons);
      print('Frontend: loadSalons Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? [];
      _salons = results
          .map<Salon>((json) => Salon.fromJson(json as Map<String, dynamic>))
          .toList();
      if (_salons.isNotEmpty && _selectedSalon == null) {
        _selectedSalon = _salons.first; // Default select
      }
    } catch (e) {
      print('Frontend: loadSalons Error: $e');
    }
  }

  Future<void> loadBranches() async {
    try {
      if (_selectedSalon == null) return;
      // Note: Branch endpoint might need to be added to Endpoints.dart if it doesn't exist
      // For now using the existing pattern
      final response = await ApiService().get(
        '/salons/salons/${_selectedSalon!.id}/branches/',
      );
      print('Frontend: loadBranches Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? [];
      _branches = results
          .map<Branch>((json) => Branch.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Frontend: loadBranches Error: $e');
    }
  }

  Future<void> loadServices() async {
    try {
      if (_selectedSalon == null) return;
      final response = await ApiService().get(
        '/salons/${_selectedSalon!.id}/services/',
      );
      print('Frontend: loadServices Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? response['options'] ?? [];
      _services = results
          .map<SalonService>(
            (json) => SalonService.fromMap(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Frontend: loadServices Error: $e');
    }
  }

  Future<void> loadInventory() async {
    try {
      if (_selectedSalon == null) return;
      final response = await ApiService().get(
        Endpoints.salonInventory(_selectedSalon!.id),
      );
      print('Frontend: loadInventory Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? [];
      _inventory = results
          .map<InventoryItem>(
            (json) => InventoryItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Frontend: loadInventory Error: $e');
    }
  }

  Future<void> selectSalon(Salon salon) async {
    _selectedSalon = salon;
    _selectedBranch = null;
    await loadSalonSpecificData();
    notifyListeners();
  }

  Future<void> selectBranch(Branch branch) async {
    _selectedBranch = branch;
    notifyListeners();
  }

  Future<void> loadSalonSpecificData() async {
    if (_selectedSalon != null) {
      await Future.wait([loadServices(), loadInventory()]);
    }
  }

  Future<void> createProductOnBackend({
    required String name,
    required double price,
    required String description,
    required int stock,
  }) async {
    if (_selectedSalon != null) {
      try {
        final data = {
          'product_name': name,
          'product_price': price,
          'product_description': description,
          'category': 'Consumables', // Default for demo
          'stock': stock,
        };
        print('Frontend: Creating Product with data: $data');
        // Actual endpoint logic here or simulation with endpoint setups
        final response = await ApiService().post(
          '/salons/${_selectedSalon!.id}/inventory/',
          data: data,
        );
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
      final response = await ApiService().post(
        '/salons/inventory/$inventoryId/adjust_stock/',
        data: {'increment': increment},
      );
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
          salonId: _inventory[index].salonId,
          quantityInStock: _inventory[index].quantityInStock + increment,
          lowStockThreshold: _inventory[index].lowStockThreshold,
          lastUpdated: DateTime.now(),
          productName: _inventory[index].productName,
          productDescription: _inventory[index].productDescription,
          productPrice: _inventory[index].productPrice,
        );
        notifyListeners();
      }
    }
  }

  Future<void> updateSalonOnBackend({
    required String name,
    required String phone,
    required String location,
    required String description,
    String? slogan,
    String? openingTime,
    String? closingTime,
    List<File>? images,
  }) async {
    if (_selectedSalon != null) {
      try {
        final fields = {
          'salonName': name,
          'salonPhoneNum': phone,
          'location': location,
          'salonDescription': description,
          if (slogan != null) 'slogan': slogan,
          if (openingTime != null) 'openingTime': openingTime,
          if (closingTime != null) 'closingTime': closingTime,
        };
        print('Frontend: Updating Salon on Backend with fields: $fields');
        final response = await ApiService().updateSalonWithImages(
          salonId: _selectedSalon!.id,
          fields: fields,
          images: images,
        );
        print('Frontend: updateSalonOnBackend Response: $response');
        _selectedSalon = Salon.fromJson(response);
        notifyListeners();
      } catch (e) {
        print('Frontend: updateSalonOnBackend Error: $e');
        rethrow;
      }
    }
  }

  void updateSalonInMemory({
    required String name,
    required String phone,
    required String location,
    required String description,
    String? slogan,
    String? openingTime,
    String? closingTime,
  }) {
    if (_selectedSalon != null) {
      _selectedSalon = Salon(
        id: _selectedSalon!.id,
        salonName: name,
        salonPhonNum: phone,
        salonDescription: description,
        slogan: slogan ?? _selectedSalon!.slogan,
        location: location,
        lat: _selectedSalon!.lat,
        lng: _selectedSalon!.lng,
        openingTime: openingTime ?? _selectedSalon!.openingTime,
        closingTime: closingTime ?? _selectedSalon!.closingTime,
        salonSeats: _selectedSalon!.salonSeats,
        salonStaff: _selectedSalon!.salonStaff,
        confirmedPhone: _selectedSalon!.confirmedPhone,
        ownerId: _selectedSalon!.ownerId,
        avgRating: _selectedSalon!.avgRating,
      );

      final index = _salons.indexWhere((s) => s.id == _selectedSalon!.id);
      if (index != -1) {
        _salons[index] = _selectedSalon!;
      }
      notifyListeners();
    }
  }
}
