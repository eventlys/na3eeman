import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../Models/shops_model.dart';
import '../../Models/soonest_appointment_model.dart';
import '../../Models/user_model.dart';
import '../../Theme/glass_appbar.dart';
import '../../components/cards/barbershop_card.dart';
import '../../components/common/links/text_links.dart';
import '../../components/customer_shop_ads.dart';
import '../../features/Backgrounds/bd_faded.dart';
import '../../features/sidebar/sidebar.dart';
import '../../features/sidebar/sidebar_controller.dart';
import '../Navigations/shop_details.dart';
import '../Widgets/custom_navigation_bar.dart';
import '../Widgets/points_tracker_widget.dart';
import '../Widgets/soonest_appointment_card.dart';
// ... your other imports

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController(); // Add scroll controller

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    _loadPoints();
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  void _loadPoints() {
    // Implement your points loading logic here
  }

  void _handleCardTap(Map<String, dynamic> shopData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShopDetailsPage(shopData: shopData),
      ),
    );
  }

  void _handleFavoriteChanged(bool isFavorite) {
    print('Favorite status changed: $isFavorite');
  }

  @override
  Widget build(BuildContext context) {
    final user = User(
      id: 1,
      email: 'customer@example.com',
      role: 'customer',
      name: 'John Doe',
    );

    return FadedBackground(
      startColor: const Color(0xFF806C99),
      endColor: const Color(0xFFDFA8A4),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            // Main Content with Animation
            AnimatedBuilder(
              animation: sidebarController.animation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(
                      sidebarController.animation.value * 250,
                      sidebarController.animation.value * 25,
                    )
                    ..scale(1 - sidebarController.animation.value * 0.3),
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: 1 - sidebarController.animation.value * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(20),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:
                                sidebarController.animation.value * 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        extendBody: true,
                        body: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            // Use the fixed GlassSliverAppBar directly
                            GlassSliverAppBar(
                              title: 'Customer Home',
                              backgroundColor: Colors.transparent,
                              leading: IconButton( // Provide leading directly
                                icon: Image.asset(
                                  'assets/icons/menu.png',
                                  width: 30,
                                  height: 30,
                                  // color: Colors.white, // Optional: tint the icon
                                ),
                                onPressed: () => sidebarController.toggleSidebar(),
                              ),
                              showBackButton: false, // We're providing custom leading
                            ),

                            // Fixed horizontal section
                            SliverToBoxAdapter(
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    HorizontalShopScroll(),

                                    SoonestAppointmentCard(
                                      appointments: SoonestAppointmentData.getMockAppointments(),
                                      onAppointmentDelayed: (delayedAppointment) {
                                        print('Appointment delayed to: ${delayedAppointment.dateTime}');
                                      },
                                      onAppointmentRescheduleNeeded: (appointment) {
                                        print('Reschedule needed for: ${appointment.shopName}');
                                      },
                                    ),

                                    PointsTrackerWidget(),

                                    // NearBy shops link
                                    ClipRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                                          decoration: const BoxDecoration(
                                            color: Color(0x0dffffff),
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
                                                    color: Colors.grey.shade800,
                                                  ),
                                                ),
                                                const TextLink(
                                                  link: '/shops',
                                                  text: 'See all',
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Scrollable list section
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final shop = ShopData.getMockShops()[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: BarbershopCard(
                                      title: shop['title'] as String,
                                      workingHours: shop['workingHours'] as String,
                                      bottomLeftIconPath: shop['bottomLeftIconPath'] as String,
                                      bottomRightIconPath: shop['bottomRightIconPath'] as String,
                                      middleRightIconPath: shop['middleRightIconPath'] as String,
                                      middleRightActiveIconPath: shop['middleRightActiveIconPath'] as String,
                                      profilePicture: shop['profilePicture'] as String,
                                      size: const Size(330, 115),
                                      isClickable: shop['isClickable'] as bool,
                                      shopLocation: shop['shopLocation'] as String,
                                      shopRating: shop['shopRating'] as double,
                                      onCardTap: () => _handleCardTap(shop),
                                      onFavoriteChanged: _handleFavoriteChanged,
                                    ),
                                  );
                                },
                                childCount: min(5, ShopData.getMockShops().length),
                              ),
                            ),
                          ],
                        ),
                        bottomNavigationBar: CustomNavigationBar(
                          user: user,
                          currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Sidebar Overlay
            Sidebar(controller: sidebarController),
          ],
        ),
      ),
    );
  }
}
