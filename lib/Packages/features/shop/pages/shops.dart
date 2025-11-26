import 'package:flutter/material.dart';

import '../../../../Services/api/api_service.dart';
import '../../../Core/backgrounds/bd_faded.dart';
import '../../../Core/themes/glass_appbar.dart';
import '../widgets/barbershop_card.dart';
import 'shop_details.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService(); // Your API service instance
  List<Map<String, dynamic>> _shops = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await _apiService.getShops(
        page: 1,
        limit: 20,
        // You can add other parameters here like:
        // location: 'some location',
        // minRating: 4.0,
        // openNow: true,
      );

      setState(() {
        // Assuming the response contains a 'shops' list
        _shops = List<Map<String, dynamic>>.from(response['shops'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load shops: $e';
        _isLoading = false;
      });
    }
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
    print('Favorite status: $isFavorite');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // FadedBackground covering the entire screen
        Positioned.fill(
          child: FadedBackground(
            startColor: const Color(0x80806C99),
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
              // Loading, error, or shop list
              _buildContent(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadShops,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_shops.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text('No shops found'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final shopData = _shops[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: BarbershopCard(
              title: shopData['title'] as String? ?? 'Unknown Shop',
              workingHours: shopData['workingHours'] as String? ?? 'Hours not available',
              bottomLeftIconPath: shopData['bottomLeftIconPath'] as String? ?? '',
              bottomRightIconPath: shopData['bottomRightIconPath'] as String? ?? '',
              middleRightIconPath: shopData['middleRightIconPath'] as String? ?? '',
              middleRightActiveIconPath: shopData['middleRightActiveIconPath'] as String? ?? '',
              profilePicture: shopData['profilePicture'] as String? ?? '',
              size: const Size(330, 115),
              isClickable: shopData['isClickable'] as bool? ?? true,
              shopLocation: shopData['shopLocation'] as String? ?? 'Location not available',
              shopRating: (shopData['shopRating'] as num?)?.toDouble() ?? 0.0,
              onCardTap: () => _handleCardTap(shopData),
              onFavoriteChanged: _handleFavoriteChanged,
            ),
          );
        },
        childCount: _shops.length,
      ),
    );
  }
}
