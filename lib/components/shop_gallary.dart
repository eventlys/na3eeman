/*
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ModernShopGallery extends StatefulWidget {
  final int imageCount;
  final String directoryPath;

  const ModernShopGallery({
    super.key,
    required this.imageCount,
    required this.directoryPath,
  });

  @override
  State<ModernShopGallery> createState() => _ModernShopGalleryState();
}

class _ModernShopGalleryState extends State<ModernShopGallery> {
  List<File> _imageFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImagesFromDirectory();
  }

  Future<void> _loadImagesFromDirectory() async {
    try {
      final directory = Directory(widget.directoryPath);

      if (await directory.exists()) {
        final files = await directory.list().toList();

        // Filter image files
        final imageFiles = files
            .where((file) => file is File && _isImageFile(file.path))
            .cast<File>()
            .toList();

        // Sort by name or modification time
        imageFiles.sort((a, b) => a.path.compareTo(b.path));

        setState(() {
          _imageFiles = imageFiles;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = widget.imageCount > _imageFiles.length
        ? _imageFiles.length
        : widget.imageCount;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 16),
          _isLoading
              ? _buildLoadingState()
              : _buildMasonryLayout(displayCount),
        ],
      ),
    );
  }

  Widget _buildMasonryLayout(int count) {
    if (count == 0) return _buildEmptyState();

    return Container(
      height: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - taller images
          Expanded(
            child: Column(
              children: [
                _buildImageCard(_imageFiles[0], height: 220),
                if (count > 2) SizedBox(height: 8),
                if (count > 2) _buildImageCard(_imageFiles[2], height: 172),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Right column - shorter images
          Expanded(
            child: Column(
              children: [
                if (count > 1) _buildImageCard(_imageFiles[1], height: 172),
                if (count > 1) SizedBox(height: 8),
                if (count > 3) _buildOverlayImageCard(count - 3, height: 220),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(File imageFile, {required double height}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0x42000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                decoration: BoxDecoration(
                  color: Color(0xFF424242),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.error, color: Color(0xFF9E9E9E)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayImageCard(int remainingCount, {required double height}) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _imageFiles[3],
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0x8A000000),
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
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

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFF424242),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading images...',
              style: TextStyle(color: Color(0xFF9E9E9E)),
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
        color: Color(0xFF424242),
        border: Border.all(color: Color(0xFF616161)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 48, color: Color(0xFF9E9E9E)),
            SizedBox(height: 8),
            Text(
              'No images found in directory',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
            SizedBox(height: 8),
            Text(
              widget.directoryPath,
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../../Models/shops_model.dart';

class ModernShopGallery extends StatelessWidget {
  final int imageCount;
  final String shopTitle;

  const ModernShopGallery({
    super.key,
    required this.imageCount,
    required this.shopTitle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrls = ShopData.getShopGalleryImages(shopTitle);
    final displayCount = imageCount > imageUrls.length
        ? imageUrls.length
        : imageCount;

    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 16),
          _buildMasonryLayout(displayCount, imageUrls),
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
                if (count > 2) SizedBox(height: 8),
                if (count > 2) _buildImageCard(imageUrls[2], height: 142),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Right column - shorter images
          Expanded(
            child: Column(
              children: [
                if (count > 1) _buildImageCard(imageUrls[1], height: 142),
                if (count > 1) SizedBox(height: 8),
                if (count > 3) _buildOverlayImageCard(count - 3, imageUrls[3], height: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imagePath, {required double height}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0x42000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                decoration: BoxDecoration(
                  color: Color(0xFF424242),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.error, color: Color(0xFF9E9E9E)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayImageCard(int remainingCount, String imagePath, {required double height}) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0x8A000000),
            ),
            child: Center(
              child: Text(
                '+$remainingCount',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
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

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFF424242),
        border: Border.all(color: Color(0xFF616161)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 48, color: Color(0xFF9E9E9E)),
            SizedBox(height: 8),
            Text(
              'No images available',
              style: TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}
