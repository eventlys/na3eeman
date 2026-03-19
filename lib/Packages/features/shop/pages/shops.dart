import 'package:flutter/material.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../widgets/barbershop_card.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _shops = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _searchController = TextEditingController();

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

      final response = await _apiService.getShops(page: 1, limit: 20);
      final shopsList = List<Map<String, dynamic>>.from(response['shops'] ?? []);

      if (mounted) {
        setState(() {
          if (shopsList.isEmpty) {
            _shops = _getMockShops(); // Fallback if empty
          } else {
            _shops = shopsList;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shops = _getMockShops(); // Fallback on error
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getMockShops() {
    return [
      {
        'id': 101,
        'shopName': 'Modern Cuts Barbershop',
        'title': 'Modern Cuts Barbershop',
        'workingHours': '09:00 AM – 10:00 PM',
        'location': 'Abdali, Amman, Jordan',
        'shopLocation': 'Abdali, Amman',
        'shopRating': 4.8,
        'image': 'assets/images/shop_placeholder.png',
      },
      {
        'id': 102,
        'shopName': 'Elite Grooming Lounge',
        'title': 'Elite Grooming Lounge',
        'workingHours': '10:00 AM – 09:00 PM',
        'location': 'Sweifieh, Amman, Jordan',
        'shopLocation': 'Sweifieh, Amman',
        'shopRating': 4.5,
      },
      {
        'id': 103,
        'shopName': 'Rose Beauty Center',
        'title': 'Rose Beauty Center',
        'workingHours': '09:00 AM – 08:00 PM',
        'location': 'Shmeisani, Amman, Jordan',
        'shopLocation': 'Shmeisani, Amman',
        'shopRating': 4.7,
      },
      {
        'id': 104,
        'shopName': 'Gentleman Choice',
        'title': 'Gentleman Choice',
        'workingHours': '10:00 AM – 10:00 PM',
        'location': 'Tabarbour, Amman, Jordan',
        'shopLocation': 'Tabarbour, Amman',
        'shopRating': 4.2,
      },
    ];
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Discover Shops', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButtonStyled(
            icon: Icons.filter_list_rounded,
            onPressed: () {}, // Filter dialog
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                filled: true,
                fillColor: isDark ? AppColors.almostBlack600 : AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Implement search logic
              },
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SecondaryButton(
              text: 'Retry',
              onPressed: _loadShops,
              width: 120,
            ),
          ],
        ),
      );
    }

    if (_shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: AppColors.almostBlack200),
            const SizedBox(height: 16),
            const Text('No shops found nearby', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _shops.length,
      itemBuilder: (context, index) {
        final shop = _shops[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: BarbershopCard(
            title: shop['shopName'] ?? shop['title'] ?? 'Unknown',
            workingHours: shop['workingHours'] ?? '9:00 AM - 9:00 PM',
            profilePicture: 'assets/images/shop_placeholder.png',
            isClickable: true,
            shopLocation: shop['shopLocation'] ?? shop['location'] ?? 'Downtown',
            shopRating: (shop['shopRating'] as num?)?.toDouble() ?? 4.5,
            onCardTap: () => Navigator.pushNamed(context, '/shop_details', arguments: shop),
            onFavoriteChanged: (isFav) {
              // Handle favorite
            },
          ),
        );
      },
    );
  }
}
