import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:na3eeman/Packages/Core/widgets/shared/error_widget.dart';
import '../../../../Helpers/logger.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/enums/gender.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';
import '../../../Core/utils/helpers/themes_helpers.dart';
import '../../Navigation/sidebar.dart';
import '../../Navigation/sidebar_controller.dart';
import '../../appointments/widgets/soonest_appointment_card.dart';
import '../../shop/pages/shop_details.dart';
import '../../shop/widgets/barbershop_card.dart';
import '../../shop/widgets/customer_shop_ads.dart';
import '../../../../Services/api/api_service.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController();
  bool _isSidebarOpen = false;
  UserGender? _userGender;

  // Add providers and services
  late AuthProvider _authProvider;
  late ShopProvider _shopProvider;
  late AppointmentProvider _appointmentProvider;
  final ApiService _apiService = ApiService();
  final FavoritesProvider _favoritesProvider = FavoritesProvider();

  // Data holders
  List<dynamic> _shops = [];
  List<dynamic> _appointments = [];
  Map<String, dynamic> _userPoints = {'points': 0};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);

    // Initialize providers
    _authProvider = AuthProvider();
    _shopProvider = ShopProvider();
    _appointmentProvider = AppointmentProvider();

    _loadAllData();
    _determineUserGender();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load data from services and providers
      await Future.wait([
        _loadShops(),
        _loadAppointments(),
        _loadUserPoints(),
      ]);

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadShops() async {
    try {
      await _shopProvider.loadShopData();
      setState(() {
        _shops = _shopProvider.shops;
      });
    } catch (e) {
      // Fallback to mock data if needed
      setState(() {
        _shops = _getMockShops();
      });
    }
  }

  Future<void> _loadAppointments() async {
    try {
      await _appointmentProvider.loadAppointments();
      setState(() {
        _appointments = _appointmentProvider.myAppointments;
      });
    } catch (e) {
      // Fallback to mock data if needed
      setState(() {
        _appointments = _getMockAppointments();
      });
    }
  }

  Future<void> _loadUserPoints() async {
    try {
      if (_authProvider.user?.id != null) {
        final pointsData = await _apiService.getLoyaltyBalance(_authProvider.user!.id);
        setState(() {
          // Check what properties actually exist on LoyaltyBalance
          _userPoints = {
            'points': pointsData.points,
            // Remove freeHaircuts if it doesn't exist
          };
        });
      }
    } catch (e) {
      // Fallback to default points
      setState(() {
        _userPoints = {'points': 250};
      });
    }
  }

  void _determineUserGender() {
    // Get gender from auth provider if available - convert from Gender enum to UserGender
    final userGender = _authProvider.userGender;
    setState(() {
      if (userGender == Gender.male) {
        _userGender = UserGender.male;
      } else if (userGender == Gender.female) {
        _userGender = UserGender.female;
      } else {
        _userGender = UserGender.nonBinary;
      }
    });
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    sidebarController.toggleSidebar();
  }

  void _handleCardTap(Map<String, dynamic> shopData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopDetailsPage(shopData: shopData),
      ),
    );
  }

  void _handleFavoriteChanged(bool isFavorite, Map<String, dynamic> shopData) async {
    try {
      if (isFavorite) {
        final success = await _favoritesProvider.addToFavorites(shopData);
        if (success && mounted) {
          context.showSuccessToast('Added to favorites!');

          // Log the favorite action for analytics
          AppLogger.info(
            'Favorite added',
            extra: {
              'shopId': shopData['id'],
              'shopName': shopData['shopName'],
              'userId': _authProvider.user?.id,
            }
          );
        }
      } else {
        final shopId = shopData['id'].toString();
        final success = await _favoritesProvider.removeFromFavorites(shopId);
        if (success && mounted) {
          context.showInfoToast('Removed from favorites');

          // Log the favorite action for analytics
          AppLogger.info(
            'Favorite removed',
            extra: {
              'shopId': shopData['id'],
              'shopName': shopData['shopName'],
              'userId': _authProvider.user?.id,
            }
          );
        }
      }
    } catch (e) {
      // Log error for developers
      AppLogger.error(
        'Failed to update favorite status',
        error: e,
        extra: {
          'shopId': shopData['id'],
          'isFavorite': isFavorite,
          'userId': _authProvider.user?.id,
        }
      );

      // Show error message to user
      if (mounted) {
        context.showErrorToast(
          'Failed to update favorites. Please try again.',
          onRetry: () => _handleFavoriteChanged(isFavorite, shopData),
        );
      }
    }
  }

  Future<void> _handleRedeemPoints() async {
    try {
      if (_authProvider.user?.id != null) {
        await _apiService.redeemFreeHaircut(_authProvider.user!.id);
        await _loadUserPoints(); // Refresh points
      }
    } catch (e) {
      print('Error redeeming points: $e');
    }
  }

  // Helper method to format appointment data for SoonestAppointmentCard
  Map<String, dynamic>? _getSoonestAppointment() {
    if (_appointments.isEmpty) return null;

    // Find the soonest appointment
    final soonest = _appointments.reduce((a, b) {
      final aTime = a.startTime ?? DateTime.now();
      final bTime = b.startTime ?? DateTime.now();
      return aTime.isBefore(bTime) ? a : b;
    });

    return {
      'id': soonest.id,
      'shopName': soonest.shop?.shopName ?? 'Barber Shop',
      'dateTime': soonest.startTime ?? DateTime.now().add(Duration(hours: 2)),
      'services': soonest.services?.map((s) => s.name).toList() ?? ['Haircut'],
      'totalPrice': soonest.totalPrice ?? 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAllData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final soonestAppointment = _getSoonestAppointment();

    return ScaffoldWithSidebar(
      sidebar: Sidebar(controller: sidebarController),
      isSidebarOpen: _isSidebarOpen,
      onSidebarToggle: _toggleSidebar,
      child: AppScaffold(
        title: 'Customer Home',
        showAppBar: false,
        useGlassSliverAppBar: true,
        showBackButton: false,
        user: _authProvider.user, // Use provider user
        scrollController: _scrollController,
        userGender: _userGender,
        isDarkMode: isDark,
        glassLeading: IconButton(
          icon: Image.asset(
            AppImages.menu,
            width: 30,
            height: 30,
            color: _getIconColor(isDark, _userGender),
          ),
          onPressed: _toggleSidebar,
        ),
        customBody: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    HorizontalShopScroll(),

                    // Only show SoonestAppointmentCard if there's an appointment
                    if (soonestAppointment != null)
                      SoonestAppointmentCard(),

                    _buildPointsTracker(),

                    _buildNearbyShopsHeader(isDark, _userGender),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shop = _shops[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: BarbershopCard(
                      title: shop['shopName'] ?? shop['title'] ?? 'Shop',
                      workingHours: shop['workingHours'] ?? '9:00 AM - 8:00 PM',
                      bottomLeftIconPath: shop['bottomLeftIconPath'] ?? 'assets/icons/location.png',
                      bottomRightIconPath: shop['bottomRightIconPath'] ?? 'assets/icons/star.png',
                      middleRightIconPath: shop['middleRightIconPath'] ?? 'assets/icons/heart_outline.png',
                      middleRightActiveIconPath: shop['middleRightActiveIconPath'] ?? 'assets/icons/heart_filled.png',
                      profilePicture: shop['profilePicture'] ?? 'assets/images/shop_placeholder.png',
                      size: const Size(330, 115),
                      isClickable: true,
                      shopLocation: shop['location'] ?? shop['shopLocation'] ?? 'Unknown Location',
                      shopRating: (shop['avgRating'] ?? shop['shopRating'] ?? 4.5).toDouble(),
                      onCardTap: () => _handleCardTap(shop),
                      onFavoriteChanged: (isFavorite) => _handleFavoriteChanged(isFavorite, shop),
                    ),
                  );
                },
                childCount: min(5, _shops.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsTracker() {
    final points = _userPoints['points'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getGenderGradient(_userGender),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getGenderShadowColor(_userGender)!.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getGenderTextColor(_userGender),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$points points',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: _getGenderTextColor(_userGender),
                ),
              ),
            ],
          ),
          PrimaryButton(
            text: 'Redeem',
            onPressed: _handleRedeemPoints,
            variant: ButtonVariant.outlined,
            buttonColor: _getGenderButtonColor(_userGender),
            textColor: _getGenderTextColor(_userGender),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyShopsHeader(bool isDark, UserGender? gender) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: _getGenderBackgroundColor(gender, isDark).withValues(alpha: 0.7),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shops near by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getGenderTextColor(gender),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to shops page
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: _getGenderAccentColor(gender),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for fallback data
  List<dynamic> _getMockShops() {
    return [
      {
        'shopName': 'Modern Cuts',
        'workingHours': '9:00 AM - 8:00 PM',
        'location': 'Downtown',
        'avgRating': 4.5,
        'profilePicture': 'assets/images/shop1.jpg',
      },
      {
        'shopName': 'Classic Barbers',
        'workingHours': '8:00 AM - 7:00 PM',
        'location': 'City Center',
        'avgRating': 4.8,
        'profilePicture': 'assets/images/shop2.jpg',
      },
    ];
  }

  List<dynamic> _getMockAppointments() {
    return [
      {
        'id': '1',
        'shopName': 'Modern Cuts',
        'startTime': DateTime.now().add(Duration(hours: 2)),
        'services': ['Haircut', 'Beard Trim'],
        'totalPrice': 45.0,
      },
    ];
  }

  // Gender-based color methods (keep existing)
  Color _getIconColor(bool isDark, UserGender? gender) {
    if (gender != null) {
      return _getGenderPrimaryColor(gender, isDark);
    }
    return isDark ? AppColor.darkText : AppColor.lightText;
  }

  Color _getGenderPrimaryColor(UserGender gender, bool isDark) {
    switch (gender) {
      case UserGender.male:
        return isDark ? AppColor.darkMaleBG : AppColor.lightMaleBG;
      case UserGender.female:
        return isDark ? AppColor.darkFemaleBG : AppColor.lightFemaleBG;
      case UserGender.nonBinary:
        return isDark ? AppColor.darkNonBinaryBG : AppColor.lightNonBinaryBG;
    }
  }

  Color _getGenderTextColor(UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return AppColor.lightMaleBG;
        case UserGender.female:
          return AppColor.lightFemaleBG;
        case UserGender.nonBinary:
          return AppColor.lightNonBinaryBG;
      }
    }
    return AppColor.lightText;
  }

  Color _getGenderAccentColor(UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return AppColor.maleAccent;
        case UserGender.female:
          return AppColor.femaleAccent;
        case UserGender.nonBinary:
          return AppColor.nonBinaryAccent;
      }
    }
    return AppColor.lightInfo;
  }

  Color _getGenderButtonColor(UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return AppColor.lightMaleBG;
        case UserGender.female:
          return AppColor.lightFemaleBG;
        case UserGender.nonBinary:
          return AppColor.lightNonBinaryBG;
      }
    }
    return AppColor.primary;
  }

  Color _getGenderBackgroundColor(UserGender? gender, bool isDark) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return isDark ? AppColor.darkMaleBackground : AppColor.maleBackground;
        case UserGender.female:
          return isDark ? AppColor.darkFemaleBackground : AppColor.femaleBackground;
        case UserGender.nonBinary:
          return isDark ? AppColor.darkNonBinaryBackground : AppColor.nonBinaryBackground;
      }
    }
    return isDark ? AppColor.darkCard : AppColor.lightCard;
  }

  Color? _getGenderShadowColor(UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return AppColor.maleAccent;
        case UserGender.female:
          return AppColor.femaleAccent;
        case UserGender.nonBinary:
          return AppColor.nonBinaryAccent;
      }
    }
    return AppColor.primary;
  }

  LinearGradient _getGenderGradient(UserGender? gender) {
    if (gender != null) {
      switch (gender) {
        case UserGender.male:
          return LinearGradient(
            colors: [AppColor.maleBackground, AppColor.maleBackground.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case UserGender.female:
          return LinearGradient(
            colors: [AppColor.femaleBackground, AppColor.femaleBackground.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case UserGender.nonBinary:
          return LinearGradient(
            colors: [AppColor.nonBinaryBackground, AppColor.nonBinaryBackground.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
      }
    }
    return LinearGradient(
      colors: [AppColor.lightPrimary, AppColor.lightSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
