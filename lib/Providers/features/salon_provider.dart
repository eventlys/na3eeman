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
import '../../Helpers/cache_helper.dart';
import 'package:na3eeman/Helpers/logger.dart';

class SalonProvider extends BaseProvider {
  SalonProvider({ApiService? apiService, CacheHelper? cacheHelper})
    : _apiService = apiService ?? ApiService(),
      _cache = cacheHelper ?? CacheHelper();

  final ApiService _apiService;
  final CacheHelper _cache;

  // Unsubscribe functions for CacheHelper listeners, removed on dispose.
  final List<void Function()> _cacheSubscriptions = [];
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

  // ---------------------------------------------------------------------------
  // DATA-ACCESS DELEGATES
  // Pure pass-throughs so catalog-facing widgets never touch ApiService
  // directly. No business logic lives here.
  // ---------------------------------------------------------------------------

  /// Generic authenticated GET (raw JSON response).
  Future<dynamic> apiGet(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) => _apiService.get(endpoint, queryParams: queryParams);

  Future<List<dynamic>> getCategories() => _apiService.getCategories();

  /// Stale-while-revalidate categories: emits the cached list immediately
  /// via [onCategories] (if any), refreshes from the network in the
  /// background, and emits the fresh list when it lands. Returns the first
  /// available list (cached, or the network result on a cold cache), so
  /// cold-cache callers behave exactly like the plain [getCategories] path.
  Future<List<dynamic>> getCategoriesCached({
    void Function(List<dynamic>)? onCategories,
  }) async {
    final cached = _cache.retrieveCategoriesList();
    if (cached != null) onCategories?.call(cached);

    void listener(dynamic data) {
      if (data is List) onCategories?.call(data);
    }

    final unsubscribe = _cache.addListener(CacheKeys.categoriesList, listener);
    _cacheSubscriptions.add(unsubscribe);

    try {
      final fresh = await _apiService.getCategories();
      await _cache.storeCategoriesList(fresh); // publishes to listener
      return fresh;
    } catch (e) {
      AppLogger.warning('getCategoriesCached network refresh failed: $e');
      if (cached != null) return cached;
      rethrow;
    } finally {
      unsubscribe();
      _cacheSubscriptions.remove(unsubscribe);
    }
  }

  /// Stale-while-revalidate salon details: same contract as
  /// [getCategoriesCached], keyed per salon id with a short TTL.
  Future<Map<String, dynamic>> getSalonDetailsCached(
    int salonId, {
    void Function(Map<String, dynamic>)? onDetails,
  }) async {
    final cacheKey = '${CacheKeys.salonDetailsPrefix}$salonId';
    final cached = _cache.retrieveSalonDetails(salonId);
    if (cached != null) onDetails?.call(cached);

    void listener(dynamic data) {
      if (data is Map<String, dynamic>) onDetails?.call(data);
    }

    final unsubscribe = _cache.addListener(cacheKey, listener);
    _cacheSubscriptions.add(unsubscribe);

    try {
      final fresh = await _apiService.getSalonDetails(salonId);
      await _cache.storeSalonDetails(
        salonId,
        fresh,
        duration: CacheDurations.short,
      ); // publishes to listener
      return fresh;
    } catch (e) {
      AppLogger.warning(
        'getSalonDetailsCached network refresh failed for $salonId: $e',
      );
      if (cached != null) return cached;
      rethrow;
    } finally {
      unsubscribe();
      _cacheSubscriptions.remove(unsubscribe);
    }
  }

  Future<List<dynamic>> getAdsByCategory(int categoryId) =>
      _apiService.getAdsByCategory(categoryId);

  Future<List<dynamic>> getOffersByCategory(int categoryId) =>
      _apiService.getOffersByCategory(categoryId);

  Future<Map<String, dynamic>> getNearbySalonsByCategory({
    required double latitude,
    required double longitude,
    required int categoryId,
    bool forGift = false,
    String? giftGender,
  }) => _apiService.getNearbySalonsByCategory(
    latitude: latitude,
    longitude: longitude,
    categoryId: categoryId,
    forGift: forGift,
    giftGender: giftGender,
  );

  Future<dynamic> getSalonsRaw({int page = 1, int limit = 20}) =>
      _apiService.getSalons(page: page, limit: limit);

  Future<Map<String, dynamic>> getSalonDetailsRaw(int salonId) =>
      _apiService.getSalonDetails(salonId);

  Future<List<dynamic>> getSalonServicesRaw(int salonId) =>
      _apiService.getSalonServices(salonId);

  Future<List<dynamic>> getSalonPackagesRaw(int salonId) =>
      _apiService.getSalonPackages(salonId);

  Future<List<dynamic>> getSalonOffersRaw(int salonId) =>
      _apiService.getSalonOffers(salonId);

  Future<List<dynamic>> getSalonProductsRaw(int salonId) =>
      _apiService.getSalonProducts(salonId);

  Future<List<dynamic>> getSalonExpertsRaw(int salonId) =>
      _apiService.getSalonExperts(salonId);

  Future<Map<String, dynamic>> getAppointmentsRaw({
    int? customerId,
    String? status,
    int? pageSize,
  }) => _apiService.getAppointments(
    customerId: customerId,
    status: status,
    pageSize: pageSize,
  );

  /// Fetches staff users, optionally filtered by [salonId]. Keeps the
  /// endpoint inside the data layer so pages never name it directly.
  Future<dynamic> fetchStaff({int? salonId}) => apiGet(
    Endpoints.usersStaff,
    queryParams: salonId != null ? {'salon': salonId.toString()} : null,
  );

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
      // Cache-then-network (stale-while-revalidate): render the cached list
      // instantly, then always revalidate against the API and update.
      final cached = _cache.retrieveSalonsList();
      if (cached != null && cached.isNotEmpty) {
        _salons = cached
            .map<Salon>((json) => Salon.fromJson(json as Map<String, dynamic>))
            .toList();
        if (_salons.isNotEmpty && _selectedSalon == null) {
          _selectedSalon = _salons.first;
        }
        notifyListeners();
      }

      final response = await _apiService.get(Endpoints.salons);
      AppLogger.info('loadSalons Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? [];
      _salons = results
          .map<Salon>((json) => Salon.fromJson(json as Map<String, dynamic>))
          .toList();
      if (_salons.isNotEmpty && _selectedSalon == null) {
        _selectedSalon = _salons.first; // Default select
      }
      notifyListeners();
      // Persist the parsed list so retrieval needs no envelope handling.
      await _cache.storeSalonsList(results);
    } catch (e) {
      AppLogger.info('loadSalons Error: $e');
    }
  }

  Future<void> loadBranches() async {
    try {
      if (_selectedSalon == null) return;
      // Note: Branch endpoint might need to be added to Endpoints.dart if it doesn't exist
      // For now using the existing pattern
      final response = await _apiService.get(
        '/salons/salons/${_selectedSalon!.id}/branches/',
      );
      AppLogger.info('loadBranches Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? [];
      _branches = results
          .map<Branch>((json) => Branch.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.info('loadBranches Error: $e');
    }
  }

  Future<void> loadServices() async {
    try {
      if (_selectedSalon == null) return;
      final response = await _apiService.get(
        '/salons/${_selectedSalon!.id}/services/',
      );
      AppLogger.info('loadServices Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? response['options'] ?? [];
      _services = results
          .map<SalonService>(
            (json) => SalonService.fromMap(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppLogger.info('loadServices Error: $e');
    }
  }

  Future<void> loadInventory() async {
    try {
      if (_selectedSalon == null) return;
      final response = await _apiService.get(
        Endpoints.salonInventory(_selectedSalon!.id),
      );
      AppLogger.info('loadInventory Response: $response');
      final List<dynamic> results =
          response['results'] ?? response['data'] ?? [];
      _inventory = results
          .map<InventoryItem>(
            (json) => InventoryItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppLogger.info('loadInventory Error: $e');
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
        AppLogger.info('Creating Product with data: $data');
        // Actual endpoint logic here or simulation with endpoint setups
        final response = await _apiService.post(
          '/salons/${_selectedSalon!.id}/inventory/',
          data: data,
        );
        AppLogger.info('createProduct Response: $response');
        await loadInventory(); // Reload to capture new list
      } catch (e) {
        AppLogger.info('createProduct Error: $e');
      }
    }
  }

  Future<void> adjustStockOnBackend(String inventoryId, int increment) async {
    try {
      AppLogger.info('Adjusting Stock count for $inventoryId by $increment');
      // Simulated endpoint PUT logic
      final response = await _apiService.post(
        '/salons/inventory/$inventoryId/adjust_stock/',
        data: {'increment': increment},
      );
      AppLogger.info('adjustStock Response: $response');
      await loadInventory(); // Reload to capture new quantities
    } catch (e) {
      AppLogger.info('adjustStock Error: $e');
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
          'slogan': ?slogan,
          'openingTime': ?openingTime,
          'closingTime': ?closingTime,
        };
        AppLogger.info('Updating Salon on Backend with fields: $fields');
        final response = await _apiService.updateSalonWithImages(
          salonId: _selectedSalon!.id,
          fields: fields,
          images: images,
        );
        AppLogger.info('updateSalonOnBackend Response: $response');
        _selectedSalon = Salon.fromJson(response);
        notifyListeners();
        // Salon data changed — drop cached copies so the next read
        // revalidates instead of rendering stale owner edits.
        await _cache.remove(CacheKeys.salonsList);
        await _cache.remove(
          '${CacheKeys.salonDetailsPrefix}${_selectedSalon!.id}',
        );
      } catch (e) {
        AppLogger.info('updateSalonOnBackend Error: $e');
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

  @override
  void dispose() {
    for (final unsubscribe in _cacheSubscriptions) {
      unsubscribe();
    }
    _cacheSubscriptions.clear();
    super.dispose();
  }
}
