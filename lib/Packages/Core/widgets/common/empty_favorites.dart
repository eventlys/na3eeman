import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../constants/app_color.dart';
// import 'package:easy_localization/easy_localization.dart';

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
            Text(AppLocalizations.of(context)!.noFavoritesYet,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.itemsYouAddToYourFavoritesWillAppearHere,
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
              label: Text(AppLocalizations.of(context)!.browseProducts),
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

