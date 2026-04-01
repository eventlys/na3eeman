import 'package:flutter/material.dart';

import '../../../Core/themes/animated_cart_button.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductSection extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ProductSection({
    super.key,
    required this.shopData,
  });

  @override
  Widget build(BuildContext context) {
    // Use shop-specific services if available, otherwise use default
    final products = shopData['products'] as List<Map<String, String>>? ?? [
      {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
      {'name': 'Beard Trim', 'price': '\$15', 'made': 'Tommy'},
      {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
      {'name': 'Hair Wash', 'price': '\$10', 'made': 'Home Made'},
    ];

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('products_prices'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 16),
          ...products.map((service) => _buildServiceItem(
            name: service['name'] as String,
            price: service['price'] as String,
            made: service['made'] as String,
          )).toList(),
        ],
      ),
    );
  }

  // main_file.dart
 // Import the animated button

  Widget _buildServiceItem({
    required String name,
    required String price,
    required String made,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  made,
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            price,
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          CustomAnimatedIcon(
            icon: Icons.add_shopping_cart,
            onTap: () {
              print('Added $name to cart');
            },
            backgroundColor: Color(0x804CAF50),
            size: 20,
          ),
        ],
      ),
    );
  }
}

