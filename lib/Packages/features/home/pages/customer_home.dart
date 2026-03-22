import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Services/enums/gender.dart';
// import 'package:na3eeman/Packages/Core/widgets/shared/error_widget.dart';


import '../../../../Helpers/logger.dart';
import '../../../../Models/shop/shops_model.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Services/api/api_service.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../appointments/widgets/soonest_appointment_card.dart';
import '../../shop/widgets/barbershop_card.dart';
import '../../shop/widgets/customer_shop_ads.dart' hide Shop;

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController();
  bool _isSidebarOpen = false;

  late AuthProvider _authProvider;
  late ShopProvider _shopProvider;
  late AppointmentProvider _appointmentProvider;
  late FavoritesProvider _favoritesProvider;
  final ApiService _apiService = ApiService();

  List<Shop> _shops = [];
  Map<String, dynamic> _userPoints = {'points': 0};
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _shopProvider = Provider.of<ShopProvider>(context, listen: false);
      _appointmentProvider =Provider.of<AppointmentProvider>(context, listen: false);
      _favoritesProvider =Provider.of<FavoritesProvider>(context, listen: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadAllData();
      });
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadShops(),
        _loadUserPoints(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadShops() async {
    try {
      await _shopProvider.loadShopData();
      if (mounted) setState(() => _shops = _shopProvider.shops);
    } catch (e) {
      if (mounted) setState(() => _shops = []);
    }
  }

  Future<void> _loadUserPoints() async {
    try {
      if (_authProvider.user?.id != null) {
        final pointsData = await _apiService.getLoyaltyBalance(_authProvider.user!.id);
        setState(() {
          _userPoints = {'points': pointsData.points};
        });
      }
    } catch (e) {
      setState(() => _userPoints = {'points': 0});
    }
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
    sidebarController.toggleSidebar();
  }

  void _handleFavoriteChanged(bool isFavorite, Shop shop) async {
    final shopMap = {
      'id': shop.id,
      'shopName': shop.shopName,
    };
    try {
      if (isFavorite) {
        await _favoritesProvider.addToFavorites(shopMap);
      } else {
        await _favoritesProvider.removeFromFavorites(shop.id.toString());
      }
    } catch (e) {
      AppLogger.error('Failed to update favorite', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _authProvider.user?.firstName ?? 'there';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // drawer: Sidebar(controller: sidebarController), // Removed
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButtonStyled(
                icon: Icons.menu_rounded,
                onPressed: _toggleSidebar,
              ),
              const Spacer(),
              IconButtonStyled(
                icon: Icons.notifications_none_rounded,
                onPressed: () => _showNotifications(context),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: Theme.of(context).primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName! 👋',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready for your fresh look today?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.cream600 : AppColors.almostBlack300,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Loyalty / Points Card
                    _buildPointsTracker(isDark),

                    const SizedBox(height: 32),

                    // Ads / Promotions
                    Text(
                      'special_offers'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HorizontalShopScroll(),


                    const SizedBox(height: 32),

                    // Soonest Appointment
                    const SoonestAppointmentCard(),

                    const SizedBox(height: 32),

                    // Top Services
                    _buildTopServices(isDark),

                    const SizedBox(height: 32),

                    // Nearby Shops Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby Barber Shops',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/shops'),
                          child: Text('See All', style: TextStyle(color: Theme.of(context).primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Shop list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final shop = _shops[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: BarbershopCard(
                        title: shop.shopName,
                        workingHours: '${shop.openingTime} – ${shop.closingTime}',
                        profilePicture: 'assets/images/shop_placeholder.png',
                        isClickable: true,
                        shopLocation: shop.location,
                        shopRating: shop.avgRating ?? 4.5,
                        onCardTap: () => Navigator.pushNamed(context, '/shop_details', arguments: shop.toJson()),
                        onFavoriteChanged: (isFav) => _handleFavoriteChanged(isFav, shop),
                      ),
                    );
                  },
                  childCount: min(5, _shops.length),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    ),
    Sidebar(controller: sidebarController),
    ],
    );
  }

  Widget _buildPointsTracker(bool isDark) {
    final points = _userPoints['points'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR BALANCE',
                style: TextStyle(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.stars_rounded, color: AppColors.cream400, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$points Points',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _redeemPoints,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopServices(bool isDark) {
    final gender = _authProvider.user?.gender ?? Gender.male;

    final List<Map<String, dynamic>> services = gender == Gender.female
        ? [
            {'icon': Icons.face_retouching_natural_rounded, 'label_key': 'service_hair', 'filter': 'hair'},
            {'icon': Icons.brush_rounded, 'label_key': 'service_beauty', 'filter': 'beauty'},
            {'icon': Icons.favorite_rounded, 'label_key': 'service_brides', 'filter': 'brides'},
            {'icon': Icons.clean_hands_rounded, 'label_key': 'service_nails', 'filter': 'nails'},
            {'icon': Icons.spa_rounded, 'label_key': 'service_spa', 'filter': 'spa'},
            {'icon': Icons.flash_on_rounded, 'label_key': 'service_laser', 'filter': 'laser'},
            {'icon': Icons.face_retouching_natural_rounded, 'label_key': 'service_skin_care', 'filter': 'skin_care'},
          ]
        : [
            {'icon': Icons.content_cut_rounded, 'label_key': 'service_grooming', 'filter': 'grooming'},
            {'icon': Icons.spa_rounded, 'label_key': 'service_spa', 'filter': 'spa'},
            {'icon': Icons.clean_hands_rounded, 'label_key': 'service_nails', 'filter': 'nails'},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'our_services'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to search page with filter
                  Navigator.pushNamed(
                    context, 
                    '/shops', 
                    arguments: {'service_filter': service['filter'] as String}
                  );
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.almostBlack600 : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(service['icon'] as IconData, color: Theme.of(context).primaryColor, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (service['label_key'] as String).tr(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'Notifications',
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                child: Icon(Icons.notifications_rounded, color: Theme.of(context).primaryColor),
              ),
              title: Text('Notification Title ${index + 1}'),
              subtitle: Text('This is a notification message mockup details.'),
              trailing: const Text('2h ago', style: TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
    );
  }

  void _redeemPoints() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'Redeem Points',
        child: Column(
          children: [
            const Text('You have 0 points to redeem.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
              child: const Text('Cancel'),
            )
          ],
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'Points History',
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Earned ${index + 50} Points'),
              subtitle: const Text('For booking appointment #123'),
              trailing: const Text('+50', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheetContainer({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
