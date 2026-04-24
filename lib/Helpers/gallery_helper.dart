class ImageHelper {
  static const String baseImagePath = 'assets/images';
  static const String placeholderImage = '$baseImagePath/placeholder.jpg';

  static String getSalonGalleryImage(String salonId, int index) {
    return '$baseImagePath/salons/$salonId/gallery/${index + 1}.jpg';
  }

  static List<String> getSalonGalleryImages(String salonId, {int count = 4}) {
    List<String> images = [];
    for (int i = 0; i < count; i++) {
      images.add(getSalonGalleryImage(salonId, i));
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
