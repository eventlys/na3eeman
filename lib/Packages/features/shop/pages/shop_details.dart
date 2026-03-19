import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../widgets/shop_gallary.dart';
import '../widgets/shop_info_section.dart';
import '../widgets/services_section.dart';

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
  final Set<String> _selectedServiceNames = {};
  final List<Map<String, dynamic>> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  void _loadData() {
    final barberProvider = context.read<BarberProvider>();
    final shopId = widget.shopData['id'] ?? widget.shopData['_id'];
    if (shopId != null) {
      final id = int.tryParse(shopId.toString());
      if (id != null) barberProvider.loadBarbers(shopId: id);
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      final name = service['name'] ?? service['serviceName'] ?? 'Service';
      if (_selectedServiceNames.contains(name)) {
        _selectedServiceNames.remove(name);
        _selectedServices.removeWhere((s) => (s['name'] ?? s['serviceName'] ?? 'Service') == name);
      } else {
        _selectedServiceNames.add(name);
        _selectedServices.add(service);
      }
    });
  }

  double _calculateTotalCost() {
    return _selectedServices.fold(0.0, (sum, service) {
      final priceStr = (service['price'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return sum + (double.tryParse(priceStr) ?? 0.0);
    });
  }

  int _calculateTotalDuration() {
    return _selectedServices.fold(0, (sum, service) {
      final durationStr = (service['duration'] ?? '30').toString().replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(durationStr) ?? 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopName = widget.shopData['shopName'] ?? widget.shopData['title'] ?? 'Shop Details';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Collapsing Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                shopName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/shop_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            leading: const BackButton(color: AppColors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppColors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Favorites')));
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share Dialog Opened')));
                },
              ),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              
              // Shop Gallery
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ModernShopGallery(
                  imageCount: 4,
                  shopId: (widget.shopData['id'] ?? '').toString(),
                  imageUrls: widget.shopData['images'] != null
                      ? List<String>.from(widget.shopData['images'])
                      : null,
                ),
              ),

              const SizedBox(height: 32),

              // Info Section
              ShopInfoSection(shopData: widget.shopData),

              const SizedBox(height: 32),

              // Services Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Services',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ServicesSection(
                      selectedServiceNames: _selectedServiceNames,
                      onToggleService: _toggleService,
                      services: widget.shopData['services'] != null
                          ? List<Map<String, dynamic>>.from(widget.shopData['services'])
                          : [
                              {'name': 'Classic Haircut', 'price': '15.00', 'duration': '30 min'},
                              {'name': 'Beard Grooming', 'price': '10.00', 'duration': '20 min'},
                              {'name': 'Premium Shave', 'price': '20.00', 'duration': '40 min'},
                            ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Packages Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Packages',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      tileColor: AppColors.almostBlack50,
                      title: Text('Packages and bundles coming soon!'),
                      leading: Icon(Icons.card_giftcard),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Products Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Products',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      tileColor: AppColors.almostBlack50,
                      title: Text('Shop products catalog coming soon!'),
                      leading: Icon(Icons.shopping_bag_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Offers and Groups Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offers & Groups',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      tileColor: AppColors.almostBlack50,
                      title: Text('Exclusive offers coming soon!'),
                      leading: Icon(Icons.local_offer_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Feedback/Reviews Section Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Feedback',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 30),
                        const SizedBox(width: 8),
                        Text('4.8 / 5', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Text('(120 reviews)', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.almostBlack600 : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.almostBlack50),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                              SizedBox(width: 8),
                              Text('Ahmed M.', style: TextStyle(fontWeight: FontWeight.bold)),
                              Spacer(),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                              Icon(Icons.star, color: Colors.orange, size: 16),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Great service! Completely transformed my look. Highly recommended!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback Entry Dialog')));
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Add your feedback'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 48),

            ]),
          ),
        ],
      ),
      bottomNavigationBar: _selectedServices.isNotEmpty ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedServices.length} Services Selected',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Total: \$${_calculateTotalCost().toStringAsFixed(2)} | ${_calculateTotalDuration()} min',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Book Appointment',
                onPressed: () {
                  Navigator.pushNamed(context, '/book_appointment', arguments: {
                    'shopData': widget.shopData,
                    'selectedServices': _selectedServices,
                  });
                },
              ),
            ],
          ),
        ),
      ) : const SizedBox.shrink(),
    );
  }
}
