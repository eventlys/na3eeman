import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          HorizontalShopScroll(),
        ]),
      ),
    );
  }
}

// Shop data model
class Shop {
  final String avatar;
  final String title;
  final String description;
  final DateTime date;
  final bool isSvg;
  final String backgroundImage; // New background variable

  Shop({
    required this.avatar,
    required this.title,
    required this.description,
    required this.date,
    required this.backgroundImage, // Required background
    this.isSvg = false,
  });
}

class HorizontalShopScroll extends StatelessWidget {
  final List<Shop> shops = [
    Shop(
      avatar: 'assets/mojies/image5.png',
      title: 'Your hair',
      description: 'deserves the best. Enjoy & relax in a luxury Barber shop environment',
      date: DateTime(2024, 1, 15),
      backgroundImage: 'assets/images/shop1.jpg',
    ),
    Shop(
      avatar: 'assets/mojies/image1.png',
      title: 'Premium Cuts',
      description: 'Experience the finest barber services in town',
      date: DateTime(2024, 1, 20),
      backgroundImage: 'assets/images/shop2.jpg',
      isSvg: true,
    ),
    Shop(
      avatar: 'assets/mojies/image10.png',
      title: 'Style Masters',
      description: 'Where style meets perfection and comfort',
      date: DateTime(2024, 1, 10),
      backgroundImage: 'assets/images/shop3.jpg',
    ),
    Shop(
      avatar: 'assets/mojies/image2.png',
      title: 'Gentleman\'s Choice',
      description: 'Luxury grooming for the modern man',
      date: DateTime(2024, 1, 25),
      backgroundImage: 'assets/images/shop4.jpg',
      isSvg: true,
    ),
  ];

  HorizontalShopScroll({super.key}) {
    // Sort shops by date (latest first)
    shops.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: null, // This disables clipping
      child: SizedBox(
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
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      margin: const EdgeInsets.only(right: 16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        shadows: const [ // Add this shadows property
          BoxShadow(
            color: Color(0x40000000), // Black with 25% opacity (0x40 = 64/255 ≈ 25%)
            offset: Offset(7, 7),   // x: 10, y: 10
            blurRadius: 15,           // blur: 20
            spreadRadius: -5,         // spread: -5
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 156,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: AssetImage(shop.backgroundImage),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 10,
                  offset: Offset(5, 6),
                  spreadRadius: -3,
                )
              ],
            ),
          ),

          // Dark overlay for better text readability
          Container(
            width: double.infinity,
            height: 156,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(35),
            ),
          ),

          // Avatar/Logo container - BOTTOM-RIGHT
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 106,
              height: 138,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.grey[800],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
              ),
              child: Image(
                image: AssetImage(shop.avatar),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                      color: Colors.red[400],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.white, size: 30),
                        const SizedBox(height: 5),
                        Text(
                          'Failed to load\n${shop.avatar.split('/').last}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Title text - MOVED TO LEFT
          Positioned(
            left: 20,
            top: 20,
            child: SizedBox(
              width: 180,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${shop.title}\n',
                      style: const TextStyle(
                        color: Color(0xFFEFDF79),
                        fontSize: 24,
                        fontFamily: 'Montserrat Alternates',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: _getMainDescription(shop.description),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Montserrat Alternates',
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to extract the first line for the title section
  String _getMainDescription(String description) {
    final lines = description.split('\n');
    return lines.isNotEmpty ? lines[0] : '';
  }
}

