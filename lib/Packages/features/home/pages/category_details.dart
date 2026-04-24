import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Models/salon/category_model.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../../Providers/main_providers.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/ads_horizontal_list.dart';
import '../widgets/offers_horizontal_list.dart';
import '../../salon/widgets/barbershop_card.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';

class CategoryDetailsPage extends StatefulWidget {
  final Category category;
  final bool giftMode;
  final String? giftGender;

  const CategoryDetailsPage({
    super.key, 
    required this.category,
    this.giftMode = false,
    this.giftGender,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  late SidebarController _sidebarController;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _ads = [];
  List<dynamic> _offers = [];
  List<dynamic> _salons = [];
  Map<String, dynamic>? _previousSalon;
  
  bool _isLoadingAds = true;
  bool _isLoadingOffers = true;
  bool _isLoadingSalons = true;
  bool _isLoadingPrevious = true;
  
  Position? _currentPosition;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _sidebarController = SidebarController();
    _sidebarController.init(this);
    _loadAllData();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _determinePosition();
    _loadAds();
    _loadOffers();
    _loadSalons();
    _loadPreviousAppointment();
  }

  Future<void> _loadPreviousAppointment() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.id == null) {
        setState(() => _isLoadingPrevious = false);
        return;
      }
      
      final response = await _api.getAppointments(
        customerId: authProvider.user!.id,
        status: 'COMPLETED',
        pageSize: 1,
      );
      
      final results = response['results'] as List?;
      if (results != null && results.isNotEmpty) {
        final lastAppt = results.first;
        final salonId = lastAppt['salon'];
        if (salonId != null) {
          final salonDetails = await _api.getSalonDetails(salonId);
          if (mounted) {
            setState(() {
              _previousSalon = salonDetails;
              _isLoadingPrevious = false;
            });
          }
        } else {
          setState(() => _isLoadingPrevious = false);
        }
      } else {
        setState(() => _isLoadingPrevious = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPrevious = false);
    }
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
        forGift: widget.giftMode,
        giftGender: widget.giftGender,
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                IconButtonStyled(
                  icon: Icons.menu_rounded,
                  onPressed: () => _sidebarController.toggleSidebar(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchSalon,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark ? AppColors.almostBlack600 : AppColors.almostBlack50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _loadAllData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Horizontal slider for offers
                  OffersHorizontalList(offers: _offers, isLoading: _isLoadingOffers),
                  
                  const SizedBox(height: 24),
                  
                  // Horizontal slider for ads
                  AdsHorizontalList(ads: _ads, isLoading: _isLoadingAds),
                  
                  const SizedBox(height: 24),

                  // Card for previous customer appointment Salon
                  _buildPreviousSalonCard(),

                  const SizedBox(height: 24),
                  _buildSalonsHeader(),
                  _buildSalonsList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        Sidebar(controller: _sidebarController),
      ],
    );
  }

  Widget _buildPreviousSalonCard() {
    if (_isLoadingPrevious) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: LinearProgressIndicator(),
      );
    }

    if (_previousSalon == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.yourLastVisit,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          BarbersalonCard(
            title: _previousSalon!['salonName'] ?? _previousSalon!['salon_name'] ?? 'Last Salon',
            workingHours: '${_previousSalon!['openingTime'] ?? '09:00 AM'} - ${_previousSalon!['closingTime'] ?? '11:00 PM'}',
            profilePicture: 'assets/salons/${_previousSalon!['salon_logo']?.toString().split('/').last ?? 'salon1.jpeg'}',
            isClickable: true,
            salonLocation: _previousSalon!['location'] ?? 'Amman, Jordan',
            salonRating: double.tryParse(_previousSalon!['salonRating']?.toString() ?? '5.0') ?? 5.0,
            onCardTap: () {
              Navigator.pushNamed(
                context, 
                '/salon_details', 
                arguments: {
                  'salonData': _previousSalon,
                  'giftMode': widget.giftMode,
                  'giftGender': widget.giftGender,
                },
              );
            },
          ),
        ],
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

    final filteredSalons = _salons.where((salon) {
      final name = (salon['salonName'] ?? salon['salon_name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    if (filteredSalons.isEmpty) {
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
      itemCount: filteredSalons.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final salon = filteredSalons[index];
        return BarbersalonCard(
          title: salon['salonName'] ?? salon['salon_name'],
          workingHours: '${salon['openingTime'] ?? '09:00 AM'} - ${salon['closingTime'] ?? '11:00 PM'}',
          profilePicture: 'assets/salons/${salon['salon_logo']?.toString().split('/').last ?? 'salon1.jpeg'}',
          isClickable: true,
          salonLocation: salon['location'] ?? 'Amman, Jordan',
          salonRating: double.tryParse(salon['salonRating']?.toString() ?? '5.0') ?? 5.0,
          onCardTap: () {
            Navigator.pushNamed(
              context, 
              '/salon_details', 
              arguments: {
                'salonData': salon,
                'giftMode': widget.giftMode,
                'giftGender': widget.giftGender,
              },
            );
          },
        );
      },
    );
  }
}
