// ignore_for_file: unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// import '../../../../core/theme/colors.dart';

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
  Widget _buildImageFallback(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Icon(
        Icons.store_rounded,
        color: Theme.of(context).primaryColor,
        size: 48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls ?? const <String>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "showcase".tr(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    insetPadding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gallery',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Flexible(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: images[index].startsWith('http')
                                      ? Image.network(
                                          images[index],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildImageFallback(context),
                                        )
                                      : _buildImageFallback(context),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                "view_all".tr(),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
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
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: images[index].startsWith('http')
                      ? Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImageFallback(context),
                        )
                      : _buildImageFallback(context),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
