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
    final hasImage = category.image != null && category.image!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          image: hasImage ? DecorationImage(
            image: category.image!.startsWith('http') 
                ? NetworkImage(category.image!) 
                : AssetImage(category.image!) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (!hasImage)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                      ),
                    ],
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.nameEn.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (category.icon.isNotEmpty && category.icon != 'none')
                          Text(
                            category.icon, // Using icon field for sub-description or similar if needed
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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
