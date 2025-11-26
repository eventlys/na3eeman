import 'package:flutter/material.dart';
import '../../../../Helpers/error_handler.dart';
import '../../../../Helpers/gallery_helper.dart';
import '../../../../Services/business_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';

class ModernShopGallery extends StatefulWidget {
  final int imageCount;
  final String shopId;
  final List<String>? imageUrls;
  final bool useNetworkImages;

  const ModernShopGallery({
    super.key,
    required this.imageCount,
    required this.shopId,
    this.imageUrls,
    this.useNetworkImages = false,
  });

  @override
  State<ModernShopGallery> createState() => _ModernShopGalleryState();
}

class _ModernShopGalleryState extends State<ModernShopGallery> {
  final ShopGalleryService _galleryService = ShopGalleryService();
  late Future<List<String>> _imagesFuture;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didUpdateWidget(ModernShopGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shopId != widget.shopId ||
        oldWidget.imageUrls != widget.imageUrls) {
      _loadImages();
    }
  }

  void _loadImages() {
    setState(() {
      if (widget.imageUrls != null && widget.imageUrls!.isNotEmpty) {
        _imagesFuture = _galleryService.getShopGalleryImagesFromUrls(
          widget.imageUrls!,
          limit: widget.imageCount,
        );
      } else {
        _imagesFuture = _galleryService.getShopGalleryImages(
          widget.shopId,
          limit: widget.imageCount,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.picture,
                width: 24,
                height: 24,
                color: AppColor.lightText,
              ),
              SizedBox(width: 8),
              Text(
                'Gallery',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<String>>(
            future: _imagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error!);
              } else if (snapshot.hasData) {
                _images = snapshot.data!;
                final displayCount = widget.imageCount > _images.length
                    ? _images.length
                    : widget.imageCount;
                return _buildMasonryLayout(displayCount, _images);
              } else {
                return _buildEmptyState();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMasonryLayout(int count, List<String> imageUrls) {
    if (count == 0) return _buildEmptyState();

    return Container(
      height: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - taller images
          Expanded(
            child: Column(
              children: [
                _buildImageCard(imageUrls[0], height: 200),
                if (count > 2) const SizedBox(height: 8),
                if (count > 2) _buildImageCard(imageUrls[2], height: 142),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right column - shorter images
          Expanded(
            child: Column(
              children: [
                if (count > 1) _buildImageCard(imageUrls[1], height: 142),
                if (count > 1) const SizedBox(height: 8),
                if (count > 3) _buildOverlayImageCard(count - 3, imageUrls[3], height: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imagePath, {required double height}) {
    final isNetworkImage = ImageHelper.isNetworkImage(imagePath);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.darkWithOpacity,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: isNetworkImage
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: height,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImageLoadingPlaceholder(height);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageErrorPlaceholder(height);
                  },
                )
              : Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: height,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageErrorPlaceholder(height);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildOverlayImageCard(int remainingCount, String imagePath, {required double height}) {
    final isNetworkImage = ImageHelper.isNetworkImage(imagePath);

    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isNetworkImage
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: height,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildImageLoadingPlaceholder(height);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImageErrorPlaceholder(height);
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: height,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImageErrorPlaceholder(height);
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColor.darkWithOpacity,
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: AppColor.light,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoadingPlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColor.skeletonBaseLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColor.loadingPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildImageErrorPlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColor.skeletonBaseLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Image.asset(
          AppImages.error,
          width: 32,
          height: 32,
          color: AppColor.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.skeletonBaseLight,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColor.loadingPrimaryLight),
            SizedBox(height: 8),
            Text(
              'Loading gallery...',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.skeletonBaseLight,
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.error,
              width: 48,
              height: 48,
              color: AppColor.lightTextSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'Failed to load images',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
            SizedBox(height: 4),
            Text(
              ErrorHandler.handleError(error),
              style: TextStyle(color: AppColor.lightTextHint, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColor.skeletonBaseLight,
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.picture,
              width: 48,
              height: 48,
              color: AppColor.lightTextSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'No images available',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
