import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Models/shop/category_model.dart';
import '../widgets/ads_horizontal_list.dart';
import '../widgets/offers_horizontal_list.dart';
import '../../shop/widgets/barbershop_card.dart';

class CategoryDetailsPage extends StatefulWidget {
  final Category category;

  const CategoryDetailsPage({super.key, required this.category});

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  final ApiService _api = ApiService();
  
  List<dynamic> _ads = [];
  List<dynamic> _offers = [];
  List<dynamic> _salons = [];
  
  bool _isLoadingAds = true;
  bool _isLoadingOffers = true;
  bool _isLoadingSalons = true;
  
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _determinePosition();
    _loadAds();
    _loadOffers();
    _loadSalons();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _loadAds() async {
    try {
      final ads = await _api.getAdsByCategory(widget.category.id);
      if (mounted) {
        setState(() {
          _ads = ads;
          _isLoadingAds = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAds = false);
    }
  }

  Future<void> _loadOffers() async {
    try {
      final offers = await _api.getOffersByCategory(widget.category.id);
      if (mounted) {
        setState(() {
          _offers = offers;
          _isLoadingOffers = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingOffers = false);
    }
  }

  Future<void> _loadSalons() async {
    try {
      // Use defaults if location fails
      final lat = _currentPosition?.latitude ?? 31.9454;
      final lng = _currentPosition?.longitude ?? 35.9284;
      
      final response = await _api.getNearbySalonsByCategory(
        latitude: lat,
        longitude: lng,
        categoryId: widget.category.id,
      );
      
      if (mounted) {
        setState(() {
          _salons = response['results'] ?? [];
          _isLoadingSalons = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSalons = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              AdsHorizontalList(ads: _ads, isLoading: _isLoadingAds),
              
              const SizedBox(height: 24),
              OffersHorizontalList(offers: _offers, isLoading: _isLoadingOffers),
              
              const SizedBox(height: 24),
              _buildSalonsHeader(),
              _buildSalonsList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalonsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Salons specialized in ${widget.category.nameEn}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSalonsList() {
    if (_isLoadingSalons) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_salons.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.storefront_rounded, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No salons found in this category yet.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _salons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final shop = _salons[index];
        return BarbershopCard(
          title: shop['shopName'] ?? shop['shop_name'],
          workingHours: '${shop['openingTime'] ?? '09:00 AM'} - ${shop['closingTime'] ?? '11:00 PM'}',
          profilePicture: 'assets/salons/${shop['shop_logo']?.toString().split('/').last ?? 'salon1.jpeg'}',
          isClickable: true,
          shopLocation: shop['location'] ?? 'Amman, Jordan',
          shopRating: double.tryParse(shop['shopRating']?.toString() ?? '5.0') ?? 5.0,
          onCardTap: () {
            // Future navigation to shop details
          },
        );
      },
    );
  }
}
