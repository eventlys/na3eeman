class ImageHelper {
  static const String baseImagePath = 'assets/images';
  static const String placeholderImage = '$baseImagePath/placeholder.jpg';

  static String getShopGalleryImage(String shopId, int index) {
    return '$baseImagePath/shops/$shopId/gallery/${index + 1}.jpg';
  }

  static List<String> getShopGalleryImages(String shopId, {int count = 4}) {
    List<String> images = [];
    for (int i = 0; i < count; i++) {
      images.add(getShopGalleryImage(shopId, i));
    }
    return images;
  }

  static bool isNetworkImage(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static String getImageProvider(String imagePath) {
    if (isNetworkImage(imagePath)) {
      return 'network';
    }
    return 'asset';
  }
}
