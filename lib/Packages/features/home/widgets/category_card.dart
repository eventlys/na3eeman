import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../Models/salon/category_model.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _buildIcon(context),
            ),
            const SizedBox(height: 12),
            Text(
              category.nameEn,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    // Map string icon names to actual Flutter icons (Ionicons or Material)
    IconData iconData;
    switch (category.icon.toLowerCase()) {
      case 'cut':
      case 'scissors':
        iconData = Icons.content_cut_rounded;
        break;
      case 'sparkles':
      case 'leaf':
        iconData = Icons.auto_awesome_rounded;
        break;
      case 'finger-print':
      case 'nail':
        iconData = Icons.touch_app_rounded;
        break;
      case 'fitness':
      case 'massage':
        iconData = Icons.spa_rounded;
        break;
      case 'thermometer':
      case 'water':
      case 'hydrofacial':
        iconData = Icons.water_drop_rounded;
        break;
      default:
        iconData = Icons.category_rounded;
    }

    return Icon(
      iconData,
      color: Theme.of(context).primaryColor,
      size: 32,
    );
  }
}
