import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Models/salon/category_model.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Providers/main_providers.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../widgets/ads_horizontal_list.dart';
import '../widgets/offers_horizontal_list.dart';
import '../../salon/widgets/expert_salon_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoryDetailsPage extends StatefulWidget {
  final Category category;
  final bool giftMode;
  final String? giftGender;
  final String? subQuery;

  const CategoryDetailsPage({
    super.key,
    required this.category,
    this.giftMode = false,
    this.giftGender,
    this.subQuery,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage>
    with TickerProviderStateMixin {
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

    if (widget.subQuery != null) {
      _searchQuery = widget.subQuery!.toLowerCase();
      _searchController.text = widget.subQuery!;
    }

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
      debugPrint('location_error_msg'.tr(args: [e.toString()]));
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
                      hintText: "search_salon".tr(),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.almostBlack600
                          : AppColors.almostBlack50,
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

                  _buildSubCategoriesRow(),

                  const SizedBox(height: 16),

                  // Horizontal slider for offers
                  OffersHorizontalList(
                    offers: _offers,
                    isLoading: _isLoadingOffers,
                  ),

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
            "your_last_visit".tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ExpertSalonCard(
            title:
                _previousSalon!['salonName'] ??
                _previousSalon!['salon_name'] ??
                'last_salon'.tr(),
            workingHours:
                '${_previousSalon!['openingTime'] ?? '09:00 AM'} - ${_previousSalon!['closingTime'] ?? '11:00 PM'}',
            profilePicture:
                'assets/salons/${_previousSalon!['salon_logo']?.toString().split('/').last ?? 'salon1.jpeg'}',
            isClickable: true,
            salonLocation: _previousSalon!['location'] ?? 'amman_jordan'.tr(),
            salonRating:
                double.tryParse(
                  _previousSalon!['salonRating']?.toString() ?? '5.0',
                ) ??
                5.0,
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
    final key = 'category_${widget.category.nameEn.toLowerCase().replaceAll(' & ', '_').replaceAll(' ', '_')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'salons_specialized_in'.tr(
          args: [
            key.tr(),
          ],
        ),
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      final name = (salon['salonName'] ?? salon['salon_name'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    if (filteredSalons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'no_salons_found_in_this_category_yet'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
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
        return ExpertSalonCard(
          title: salon['salonName'] ?? salon['salon_name'],
          workingHours:
              '${salon['openingTime'] ?? '09:00 AM'} - ${salon['closingTime'] ?? '11:00 PM'}',
          profilePicture:
              'assets/salons/${salon['salon_logo']?.toString().split('/').last ?? 'salon1.jpeg'}',
          isClickable: true,
          salonLocation: salon['location'] ?? 'amman_jordan'.tr(),
          salonRating:
              double.tryParse(salon['salonRating']?.toString() ?? '5.0') ?? 5.0,
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

  Widget _buildSubCategoriesRow() {
    if (widget.category.icon == 'none' || !widget.category.icon.contains(',')) {
      return const SizedBox.shrink();
    }

    final subCats = widget.category.icon
        .split(',')
        .map((s) => s.trim())
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'refine_by'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: subCats.length,
            itemBuilder: (context, index) {
              final sub = subCats[index];
              final isSelected = _searchQuery == sub.toLowerCase();
              final key = 'service_${sub.toLowerCase().replaceAll(' + ', '_').replaceAll(' +', '_').replaceAll('+ ', '_').replaceAll(' ', '_').replaceAll('-', '_').replaceAll('&', '_').replaceAll('\'', '').replaceAll('(', '').replaceAll(')', '').replaceAll('/', '_')}';
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(key.tr()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _searchQuery = sub.toLowerCase();
                        _searchController.text = sub;
                      } else {
                        _searchQuery = '';
                        _searchController.text = '';
                      }
                    });
                  },
                  backgroundColor: isDark
                      ? AppColors.almostBlack600
                      : AppColors.almostBlack50,
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
