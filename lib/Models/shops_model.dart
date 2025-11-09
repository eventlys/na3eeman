import 'package:flutter/material.dart';
import '../components/cards/barbershop_card.dart';

class ShopData {
  static List<Map<String, dynamic>> getMockShops() {
    return [
      {
        'title': 'Elite Barbers',
        'workingHours': '8:00 - 20:00',
        'bottomLeftIconPath': 'assets/icons/location.png',
        'bottomRightIconPath': 'assets/icons/star.png',
        'middleRightIconPath': 'assets/icons/heart_gray.png',
        'middleRightActiveIconPath': 'assets/icons/heart.png',
        'profilePicture': 'assets/images/shop1.jpg',
        'isClickable': true,
        'shopLocation': '123 Main Street, Downtown, City Center',
        'shopRating': 4.8,
        'galleryImages': [
          'assets/images/shop1.jpg',
          'assets/images/shop3.jpg',
          'assets/images/shop4.jpg',
          'assets/images/shop5.jpg',
          'assets/images/shop2.jpg',
        ],
        'services': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK', 'duration': '30 min'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made', 'duration': '20 min'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance', 'duration': '45 min'},
        ],
        'products': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
        ]
      },
      {
        'title': 'Gentleman\'s Cut',
        'workingHours': '9:00 - 21:00',
        'bottomLeftIconPath': 'assets/icons/location.png',
        'bottomRightIconPath': 'assets/icons/star.png',
        'middleRightIconPath': 'assets/icons/heart_gray.png',
        'middleRightActiveIconPath': 'assets/icons/heart.png',
        'profilePicture': 'assets/images/shop2.jpg',
        'isClickable': true,
        'shopLocation': '456 Oak Avenue, Business District',
        'shopRating': 4.6,
        'galleryImages': [
          'assets/images/shop2.jpg',
          'assets/images/shop3.jpg',
          'assets/images/shop4.jpg',
          'assets/images/shop5.jpg',
          'assets/images/shop6.jpg',
        ],
        'services': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK', 'duration': '30 min'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made', 'duration': '20 min'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance', 'duration': '45 min'},
        ],
        'products': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
        ]
      },
      {
        'title': 'Classic Barbershop',
        'workingHours': '10:00 - 19:00',
        'bottomLeftIconPath': 'assets/icons/location.png',
        'bottomRightIconPath': 'assets/icons/star.png',
        'middleRightIconPath': 'assets/icons/heart_gray.png',
        'middleRightActiveIconPath': 'assets/icons/heart.png',
        'profilePicture': 'assets/images/shop3.jpg',
        'isClickable': false,
        'shopLocation': '789 Elm Street, Old Town',
        'shopRating': 4.2,
        'galleryImages': [
          'assets/images/shop3.jpg',
          'assets/images/shop4.jpg',
          'assets/images/shop7.jpg',
          'assets/images/shop5.jpg',
          'assets/images/shop6.jpg',
        ],
        'services': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK', 'duration': '30 min'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made', 'duration': '20 min'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance', 'duration': '45 min'},
        ],
        'products': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
        ]
      },
      {
        'title': 'Star Barbers',
        'workingHours': '8:00 - 00:00',
        'bottomLeftIconPath': 'assets/icons/location.png',
        'bottomRightIconPath': 'assets/icons/star.png',
        'middleRightIconPath': 'assets/icons/heart_gray.png',
        'middleRightActiveIconPath': 'assets/icons/heart.png',
        'profilePicture': 'assets/images/shop4.jpg',
        'isClickable': true,
        'shopLocation': '123 Main Street, Downtown, City Center',
        'shopRating': 4.8,
        'galleryImages': [
          'assets/images/shop4.jpg',
          'assets/images/shop3.jpg',
          'assets/images/shop8.jpg',
          'assets/images/shop5.jpg',
          'assets/images/shop2.jpg',
        ],
        'services': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK', 'duration': '30 min'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made', 'duration': '20 min'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance', 'duration': '45 min'},
        ],
        'products': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
        ]
      },
      {
        'title': 'His Majesty',
        'workingHours': '9:00 - 21:00',
        'bottomLeftIconPath': 'assets/icons/location.png',
        'bottomRightIconPath': 'assets/icons/star.png',
        'middleRightIconPath': 'assets/icons/heart_gray.png',
        'middleRightActiveIconPath': 'assets/icons/heart.png',
        'profilePicture': 'assets/images/shop5.jpg',
        'isClickable': true,
        'shopLocation': '456 Oak Avenue, Business District',
        'shopRating': 4.6,
        'galleryImages': [
          'assets/images/shop7.jpg',
          'assets/images/shop3.jpg',
          'assets/images/shop4.jpg',
          'assets/images/shop5.jpg',
          'assets/images/shop6.jpg',
        ],
        'services': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK', 'duration': '30 min'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made', 'duration': '20 min'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance', 'duration': '45 min'},
        ],
        'products': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
        ]
      },
      {
        'title': 'Modern Cut',
        'workingHours': '10:00 - 19:00',
        'bottomLeftIconPath': 'assets/icons/location.png',
        'bottomRightIconPath': 'assets/icons/star.png',
        'middleRightIconPath': 'assets/icons/heart_gray.png',
        'middleRightActiveIconPath': 'assets/icons/heart.png',
        'profilePicture': 'assets/images/shop3.jpg',
        'isClickable': false,
        'shopLocation': '789 Elm Street, Old Town',
        'shopRating': 4.2,
        'galleryImages': [
          'assets/images/shop8.jpg',
          'assets/images/shop9.jpg',
          'assets/images/shop10.jpg',
          'assets/images/shop5.jpg',
          'assets/images/shop6.jpg',
        ],
        'services': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK', 'duration': '30 min'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made', 'duration': '20 min'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance', 'duration': '45 min'},
        ],
        'products': [
          {'name': 'Haircut', 'price': '\$25', 'made': 'CK'},
          {'name': 'Beard Trim', 'price': '\$15', 'made': 'Home Made'},
          {'name': 'Haircut & Beard', 'price': '\$35', 'made': 'Elegance'},
        ]
      },
    ];
  }

  // Get gallery images for a specific shop
  static List<String> getShopGalleryImages(String shopTitle) {
    final shop = getMockShops().firstWhere(
          (shop) => shop['title'] == shopTitle,
      orElse: () => getMockShops().first,
    );
    return shop['galleryImages'] ?? ['assets/images/default_shop.jpg'];
  }

  // Get services for a specific shop
  static List<Map<String, String>> getShopServices(String shopTitle) {
    final shop = getMockShops().firstWhere(
          (shop) => shop['title'] == shopTitle,
      orElse: () => getMockShops().first,
    );
    return List<Map<String, String>>.from(shop['services'] ?? []);
  }

  // Helper method to create BarbershopCard widgets from shop data
  static List<BarbershopCard> createShopCards({
    required Size cardSize,
    VoidCallback? onCardTap,
    Function(bool)? onFavoriteChanged,
  }) {
    return getMockShops().map((shopData) {
      return BarbershopCard(
        title: shopData['title'],
        workingHours: shopData['workingHours'],
        bottomLeftIconPath: shopData['bottomLeftIconPath'],
        bottomRightIconPath: shopData['bottomRightIconPath'],
        middleRightIconPath: shopData['middleRightIconPath'],
        middleRightActiveIconPath: shopData['middleRightActiveIconPath'],
        profilePicture: shopData['profilePicture'],
        size: cardSize,
        isClickable: shopData['isClickable'],
        shopLocation: shopData['shopLocation'],
        shopRating: shopData['shopRating'],
        onCardTap: onCardTap,
        onFavoriteChanged: onFavoriteChanged,
      );
    }).toList();
  }

  // Method to get shops as ListView
  static Widget createShopListView({
    required Size cardSize,
    ScrollController? scrollController,
    VoidCallback? onCardTap,
    Function(bool)? onFavoriteChanged,
    EdgeInsets padding = const EdgeInsets.all(16.0),
  }) {
    return ListView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: getMockShops().length,
      itemBuilder: (context, index) {
        final shop = getMockShops()[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: BarbershopCard(
            title: shop['title'],
            workingHours: shop['workingHours'],
            bottomLeftIconPath: shop['bottomLeftIconPath'],
            bottomRightIconPath: shop['bottomRightIconPath'],
            middleRightIconPath: shop['middleRightIconPath'],
            middleRightActiveIconPath: shop['middleRightActiveIconPath'],
            profilePicture: shop['profilePicture'],
            size: cardSize,
            isClickable: shop['isClickable'],
            shopLocation: shop['shopLocation'],
            shopRating: shop['shopRating'],
            onCardTap: onCardTap,
            onFavoriteChanged: onFavoriteChanged,
          ),
        );
      },
    );
  }
}

