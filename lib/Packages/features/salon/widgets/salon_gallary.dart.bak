import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
// import '../../../../core/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class ModernSalonGallery extends StatefulWidget {
  final int imageCount;
  final String salonId;
  final List<String>? imageUrls;

  const ModernSalonGallery({
    super.key,
    required this.imageCount,
    required this.salonId,
    this.imageUrls,
  });

  @override
  State<ModernSalonGallery> createState() => _ModernSalonGalleryState();
}

class _ModernSalonGalleryState extends State<ModernSalonGallery> {
  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls ?? [
      'assets/images/gallery1.png',
      'assets/images/gallery2.png',
      'assets/images/gallery3.png',
      'assets/images/gallery4.png',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.showcase,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: Text(AppLocalizations.of(context)!.viewAll, style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/salon_placeholder.png', // Fallback for now
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
