// import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'home.dart';
import 'orders.dart';
import 'profile.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _selectedIndex = 2; // Since this is Favorites

  final List<Widget> _pages = [
    Placeholder(child: CHomePage()),
    Placeholder(child: COrdersPage()),
    Placeholder(child: FavoritesPage()),
    Placeholder(child: CProfilePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEAE8),
      body: Container(
        width: 440,
        height: 956,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              top: 57,
              child: Container(
                width: 400,
                height: 710,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: Colors.white.withValues(alpha: 0.70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 15,
                            offset: Offset(2, -2),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Montserrat Alternates',
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: Colors.white.withValues(alpha: 0.70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 15,
                            offset: Offset(2, -2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage("https://placehold.co/70x70"),
                              ),
                              SizedBox(width: 25),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order: 51',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'status',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Image.network("https://placehold.co/25x25", width: 25, height: 25),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 6,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
            color: Colors.pink.shade100,
          ),
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem('assets/home.png', 0),
                _buildNavItem('assets/lightning.png', 1),
                _buildNavItem('assets/fire.png', 2),
                _buildNavItem('assets/profile.png', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.convex,
              boxShape: NeumorphicBoxShape.circle(),
              depth: isSelected ? 10 : 4,
              lightSource: LightSource.topLeft,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                iconPath,
                width: isSelected ? 40 : 30,
                height: isSelected ? 40 : 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
