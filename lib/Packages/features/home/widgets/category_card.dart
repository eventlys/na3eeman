import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/colors.dart';
import '../../../../Models/salon/category_model.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  String _getLocalAssetPath() {
    final gender = category.targetGender.toLowerCase().trim();
    final name = category.nameEn.toLowerCase().trim();

    String fileName = '';

    if (gender == 'female') {
      if (name.contains('hair')) {
        fileName = 'Hair.jpg';
      } else if (name.contains('nail')) {
        fileName = 'Nails.jpeg';
      } else if (name.contains('makeup')) {
        fileName = 'Makeup.jpg';
      } else if (name.contains('skin') || name.contains('care')) {
        fileName = 'Skincare.jpg';
      } else if (name.contains('bride') || name.contains('bridal')) {
        fileName = 'Bridal.jpg';
      } else if (name.contains('henna')) {
        fileName = 'Henna.jpg';
      } else if (name.contains('private')) {
        fileName = 'Private.jpg';
      } else if (name.contains('spa') || name.contains('massage')) {
        fileName = 'Spa.jpg';
      } else {
        fileName = 'Hair.jpg'; // fallback
      }
      return 'assets/categories/female/$fileName';
    } else {
      // male
      if (name.contains('hair') || name.contains('beard')) {
        fileName = 'Hair.jpg';
      } else if (name.contains('nail')) {
        fileName = 'Nails.jpg';
      } else if (name.contains('groom')) {
        fileName = 'Groom.jpg';
      } else if (name.contains('spa') || name.contains('massage')) {
        fileName = 'Spa.jpg';
      } else if (name.contains('private')) {
        fileName = 'Private.jpg';
      } else if (name.contains('group')) {
        fileName = 'Group.jpg';
      } else if (name.contains('skin') || name.contains('care')) {
        fileName = 'Skin.jpg';
      } else {
        fileName = 'Hair.jpg'; // fallback
      }
      return 'assets/categories/male/$fileName';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localAsset = _getLocalAssetPath();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: AssetImage(localAsset),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.2),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'category_${category.nameEn.toLowerCase().replaceAll(RegExp(r"[\s\-&()+/]+"), '_').replaceAll("'", "")}'
                            .tr()
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (category.icon.isNotEmpty && category.icon != 'none')
                        Text(
                          category.icon
                              .split(',')
                              .map((s) {
                                final name = s.trim();
                                final key =
                                    'service_${name.toLowerCase().replaceAll(RegExp(r"[\s\-&()+/]+"), '_').replaceAll("'", "")}';
                                return key.tr();
                              })
                              .join(', '),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

    return Icon(iconData, color: Theme.of(context).primaryColor, size: 32);
  }
}
