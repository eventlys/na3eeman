import 'package:flutter/material.dart';
import '../../../../Models/shops_model.dart';
import '../../../Widgets/barbershop_card.dart';
import '../../../../features/Backgrounds/bd_faded.dart';
import '../../../../Theme/glass_appbar.dart';
import '../../../Navigations/shop_details.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  final ScrollController _scrollController = ScrollController();

  void _handleCardTap(Map<String, dynamic> shopData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ShopDetailsPage(
              shopData: shopData,
            ),
      ),
    );
  }

  void _handleFavoriteChanged(bool isFavorite) {
    print('Favorite status: $isFavorite');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allShops = ShopData.getMockShops();

    return Stack(
      children: [
        // FadedBackground covering the entire screen
        Positioned.fill(
          child: FadedBackground(
            startColor: Color(0x80806C99),
            endColor: const Color(0xFFDFA8A4),
          ),
        ),
        // Scaffold on top with transparent background
        Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Expanded GlassSliverAppBar with gradient and dynamic size
              GlassSliverAppBar(
                title: 'Navigate Barbershops',
                showBackButton: true,
                textColor: Colors.white,
                pinned: true,
              ),
              // Shop list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final shopData = allShops[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: BarbershopCard(
                        title: shopData['title'] as String,
                        workingHours: shopData['workingHours'] as String,
                        bottomLeftIconPath: shopData['bottomLeftIconPath'] as String,
                        bottomRightIconPath: shopData['bottomRightIconPath'] as String,
                        middleRightIconPath: shopData['middleRightIconPath'] as String,
                        middleRightActiveIconPath: shopData['middleRightActiveIconPath'] as String,
                        profilePicture: shopData['profilePicture'] as String,
                        size: const Size(330, 115),
                        isClickable: shopData['isClickable'] as bool,
                        shopLocation: shopData['shopLocation'] as String,
                        shopRating: shopData['shopRating'] as double,
                        onCardTap: () => _handleCardTap(shopData),
                        onFavoriteChanged: _handleFavoriteChanged,
                      ),
                    );
                  },
                  childCount: allShops.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}







