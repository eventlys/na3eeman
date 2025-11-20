import 'package:flutter/material.dart';
import '../../../Models/olds/user_model.dart';
// import '../../Theme/sphere_neomorphic.dart';
import '../../../components/horizontal_barber_list.dart';
import '../../../components/shop_gallary.dart';
import '../../Backgrounds/bd_faded.dart';
import '../../../Theme/glass_appbar.dart';
import '../../Widgets/custom_navigation_bar.dart';
import '../../Widgets/inventory_manager.dart';
import '../../Widgets/products_sections.dart';
import '../../Widgets/reviews_section.dart';
import '../../Widgets/shop_info_section.dart';
import '../../Widgets/shop_services_section.dart';
import '../../Widgets/subscription_list_widget.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = User(
      id: 1,
      email: 'customer@example.com',
      role: 'customer',
      name: 'John Doe',
    );
    final shopName = widget.shopData['title'] ?? 'Shop';

    return Stack(
      children: [
        // FadedBackground covering the entire screen
        // Positioned.fill(
          const FadedBackground(
            startColor: Color(0xFF806C99),
            endColor: Color(0xFFDFA8A4),
          ),
        // ),
        // Scaffold on top with transparent background
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,

          bottomNavigationBar: CustomNavigationBar(
            user: user, // Your User object from auth provider
            currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
          ),

          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Expanded GlassSliverAppBar with gradient and dynamic size
              GlassSliverAppBar(
                title: '$shopName',
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
                      padding: EdgeInsets.all(16),
                      child: ModernShopGallery(
                        imageCount: 6,
                        shopTitle: shopName,
                      ),
                    ),

                    // Shop Information Section
                    ShopInfoSection(shopData: widget.shopData),

                    HorizontalBarberScroll(
                      barbers: [
                        BarberData(image: "assets/mojies/image11.png", available: true, name: "John"),
                        BarberData(image: "assets/mojies/image19.png", available: false, name: "Jane"),
                        BarberData(image: "assets/mojies/image6.png", available: true, name: "Jane"),
                        BarberData(image: "assets/mojies/image8.png", available: true, name: "Jane"),
                        BarberData(image: "assets/mojies/image65.png", available: true, name: "Jane"),
                      ],
                      avatarSize: 150,
                      spacing: 12,
                    ),

                    // Services Section
                    ProductSection(shopData: widget.shopData),

                    // Services Section
                    ServicesSection(shopData: widget.shopData),

                    // Reviews Section
                    ReviewsSection(shopData: widget.shopData),

                    // Subscription Section
                    Container(
                      constraints: BoxConstraints(
                        // maxHeight: 600, // Adjust this value as needed
                      ),
                      child: SubscriptionListWidget(
                        onSubscriptionSuccess: () {
                          // Handle successful subscription
                          print('Subscription successful!');
                        },
                      ),
                    ),

                    // Inventory Section
                    SizedBox(
                      height: 600,
                      child: InventoryManager(currentUser: user),
                    ),


                    SizedBox(height: 32),

                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


