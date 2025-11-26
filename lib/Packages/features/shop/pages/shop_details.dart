import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Helpers/barber_list_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/enums/user_role.dart';
import '../../../Core/backgrounds/bd_faded.dart';
import '../../../Core/themes/glass_appbar.dart';
import '../../../Core/utils/helpers/themes_helpers.dart';
import '../../../Core/widgets/common/subscription_list_widget.dart';
import '../../navigation/widgets/custom_navigation_bar.dart';
import '../widgets/horizontal_barber_list.dart';
import '../widgets/inventory_manager.dart';
import '../widgets/products_sections.dart';
import '../widgets/reviews_section.dart';
import '../widgets/services_section.dart';
import '../widgets/shop_gallary.dart';
import '../widgets/shop_info_section.dart';

class ShopDetailsPage extends StatefulWidget {
  final Map<String, dynamic> shopData;

  const ShopDetailsPage({
    super.key,
    required this.shopData,
  });

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  late String _shopId;

  @override
  void initState() {
    super.initState();
    _shopId = widget.shopData['id']?.toString() ?? widget.shopData['_id']?.toString() ?? '';

    // Load shop barbers when the page initializes
    _loadShopBarbers();
  }

  void _loadShopBarbers() {
    final barberProvider = Provider.of<BarberProvider>(context, listen: false);

    // Convert shopId to int if needed (assuming your API expects int for shopId)
    final int? shopIdInt = int.tryParse(_shopId);

    if (shopIdInt != null) {
      barberProvider.loadBarbers(
        refresh: true,
        shopId: shopIdInt,
        isActive: true, // Only load active barbers
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSubscriptionSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Subscription successful!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<BarberData> _convertBarbersToBarberData(List<BarberDto> barbers) {
    return barbers.map((barber) {
      return BarberData(
        image: barber.profileImage ?? 'assets/default_avatar.png',
        available: barber.isActive,
        name: barber.name,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final shopName = widget.shopData['title'] ?? 'Shop';

    return Consumer2<AppStateProvider, BarberProvider>(
      builder: (context, appState, barberProvider, child) {
        final barbers = barberProvider.barbers;
        final isLoadingBarbers = barberProvider.isLoading;

        return Stack(
          children: [
            // FadedBackground covering the entire screen
            const FadedBackground(
              startColor: Color(0xFF806C99),
              endColor: Color(0xFFDFA8A4),
            ),

            // Scaffold on top with transparent background
            Scaffold(
              backgroundColor: Colors.transparent,
              extendBody: true,

              bottomNavigationBar: CustomNavigationBar(
                currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
              ),

              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Expanded GlassSliverAppBar with gradient and dynamic size
                  GlassSliverAppBar(
                    title: shopName,
                    showBackButton: true,
                    textColor: Colors.white,
                    pinned: true,
                  ),

                  // Shop details content
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Image Gallery Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ModernShopGallery(
                            imageCount: 6,
                            shopId: _shopId,
                            imageUrls: widget.shopData['images'] != null
                              ? List<String>.from(widget.shopData['images'])
                              : null,
                          ),
                        ),

                        // Shop Information Section
                        ShopInfoSection(shopData: widget.shopData),

                        // Barber List Section - Now using dynamic data
                        Consumer<BarberProvider>(
                          builder: (context, barberProvider, child) {
                            if (isLoadingBarbers && barbers.isEmpty) {
                              return _buildBarbersLoading();
                            }

                            if (barbers.isEmpty) {
                              return _buildNoBarbers();
                            }

                            return HorizontalBarberScroll(
                              barbers: _convertBarbersToBarberData(barbers),
                              avatarSize: 150,
                              spacing: 12,
                            );
                          },
                        ),

                        // Products Section
                        ProductSection(shopData: widget.shopData),

                        // Services Section - Fixed to use correct parameter
                        ServicesSection(
                          services: widget.shopData['services'] != null
                              ? List<Map<String, dynamic>>.from(widget.shopData['services'])
                              : [], // Provide empty list as fallback
                        ),

                        // Reviews Section
                        ReviewsSection(shopData: widget.shopData),

                        // Subscription Section - Fixed constructor
                        Container(
                          constraints: const BoxConstraints(),
                          child: SubscriptionListWidget(
                            onSubscriptionSuccess: _onSubscriptionSuccess,
                            gender: _getUserGender(appState), // Fixed gender parameter
                          ),
                        ),

                        // Inventory Section - Fixed constructor
                        // Only show inventory if user is owner or has appropriate permissions
                        if (_shouldShowInventory(appState))
                          SizedBox(
                            height: 600,
                            child: InventoryManager(
                              currentUser: _getCurrentUserData(appState), // Fixed currentUser parameter
                            ),
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get user gender in the correct format
  UserGender? _getUserGender(AppStateProvider appState) {
    // Convert from your Gender enum to UserGender if they're different
    // If they're the same, you can just return appState.userGender
    // If you need conversion, you might need something like:
    // return UserGender.values.firstWhere((e) => e.toString() == appState.userGender.toString());

    // For now, assuming they're compatible or the same enum
    return appState.userGender as UserGender?;
  }

  // Helper method to get current user data in the expected format
  Map<String, dynamic> _getCurrentUserData(AppStateProvider appState) {
    return {
      'id': appState.userId,
      'email': appState.userEmail,
      'role': appState.userRole, // Convert enum to string
      'gender': appState.userGender, // Convert enum to string
      'isLoggedIn': appState.isLoggedIn,
      'isOwner': appState.userRole == UserRole.owner,
      'isBarber': appState.userRole == UserRole.barber,
    };
  }

  // Helper method to determine if inventory should be shown
  bool _shouldShowInventory(AppStateProvider appState) {
    return appState.userRole == UserRole.owner ||
           appState.canAccessShopManagement();
  }

  Widget _buildBarbersLoading() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 15.0),
            child: Text(
              'Our Barbers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              ),
            ),
          ),
          Container(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBarbers() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 15.0),
            child: Text(
              'Our Barbers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              ),
            ),
          ),
          Container(
            height: 100,
            child: Center(
              child: Text(
                'No barbers available at this shop',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
