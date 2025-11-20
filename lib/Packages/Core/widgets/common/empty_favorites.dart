import 'package:flutter/material.dart';

import '../../constants/app_color.dart';

class EmptyFavorites extends StatelessWidget {
  final VoidCallback onBrowseProducts;

  const EmptyFavorites({
    super.key,
    required this.onBrowseProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 100,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Items you add to your favorites will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.lightTextHint,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onBrowseProducts,
              icon: const Icon(Icons.search),
              label: const Text('Browse Products'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

