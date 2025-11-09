/*
import 'package:flutter/material.dart';
import '../features/ads/customer_shop_ads.dart';

class HorizontalShopScroll extends StatelessWidget {
  final List<Shop> shops = [
    Shop(
      avatar: 'assets/shop1.png',
      title: 'Your hair',
      description: 'deserves the best.\nEnjoy & relax in a luxury\nBarber shop environment',
      date: DateTime(2024, 1, 15),
      backgroundImage: 'assets/background1.png', // Add background image
    ),
    Shop(
      avatar: 'assets/shop2.svg',
      title: 'Premium Cuts',
      description: 'Experience the finest\nbarber services in town',
      date: DateTime(2024, 1, 20),
      backgroundImage: 'assets/background2.png',
      isSvg: true,
    ),
    Shop(
      avatar: 'assets/shop3.png',
      title: 'Style Masters',
      description: 'Where style meets\nperfection and comfort',
      date: DateTime(2024, 1, 10),
      backgroundImage: 'assets/background3.png',
    ),
    Shop(
      avatar: 'assets/shop4.svg',
      title: 'Gentleman\'s Choice',
      description: 'Luxury grooming\nfor the modern man',
      date: DateTime(2024, 1, 25),
      backgroundImage: 'assets/background4.png',
      isSvg: true,
    ),
  ];

  HorizontalShopScroll({super.key}) {
    // Sort shops by date (latest first)
    shops.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return ShopCard(shop: shop);
        },
      ),
    );
  }
}*/
