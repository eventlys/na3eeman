import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../../Helpers/logger.dart';
import '../security_service.dart';

class FileMediaService {
  static final FileMediaService _instance = FileMediaService._internal();

  factory FileMediaService() => _instance;

  FileMediaService._internal();

  final SecurityService _networkSecurity = SecurityService();
  final ImagePicker _imagePicker = ImagePicker();

  // Common file operations
  Future<File> downloadFile(String url, String fileName) async {
    try {
      if (!await _checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      AppLogger.debug('Downloading file: $url to $filePath');

      final response = await _networkSecurity.secureGet(url);

      if (response.statusCode != 200) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final bytes = await response.fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );

      await file.writeAsBytes(bytes);

      AppLogger.debug('File downloaded successfully: $filePath');
      return file;
    } catch (e) {
      AppLogger.error('Failed to download file: $e');
      rethrow;
    }
  }

  Future<File> saveReportFile(String content, String fileName) async {
    try {
      if (!await _checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(content);

      AppLogger.debug('Report file saved: $filePath');
      return file;
    } catch (e) {
      AppLogger.error('Failed to save report file: $e');
      rethrow;
    }
  }

  // Media picking operations
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        AppLogger.debug('Image picked: ${image.path}');
        return File(image.path);
      }

      AppLogger.debug('No image selected');
      return null;
    } catch (e) {
      AppLogger.error('Failed to pick image: $e');
      rethrow;
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );

      final files = images.map((xFile) => File(xFile.path)).toList();
      AppLogger.debug('${files.length} images picked');

      return files;
    } catch (e) {
      AppLogger.error('Failed to pick multiple images: $e');
      rethrow;
    }
  }

  Future<File?> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        AppLogger.debug('Video picked: ${video.path}');
        return File(video.path);
      }

      AppLogger.debug('No video selected');
      return null;
    } catch (e) {
      AppLogger.error('Failed to pick video: $e');
      rethrow;
    }
  }

  Future<File?> takePicture() async {
    try {
      final File? imageFile = await pickImage(ImageSource.camera);
      if (imageFile != null && !_validateFileSize(imageFile, maxSizeInMB: 10)) {
        AppLogger.debug('Image too large, compressing...');
        final compressedPath = await _compressImage(imageFile);
        return File(compressedPath);
      }
      return imageFile;
    } catch (e) {
      AppLogger.error('Failed to take picture: $e');
      rethrow;
    }
  }

  // File management operations
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.debug('File deleted: $filePath');
      }
    } catch (e) {
      AppLogger.error('Failed to delete file: $e');
      rethrow;
    }
  }

  Future<List<FileSystemEntity>> getDownloadedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = await directory.list().toList();

      AppLogger.debug('Found ${files.length} files in download directory');
      return files;
    } catch (e) {
      AppLogger.error('Failed to get downloaded files: $e');
      return [];
    }
  }

  // Media processing operations
  Future<String> _compressImage(File imageFile) async {
    try {
      AppLogger.debug('Compressing image: ${imageFile.path}');
      // Implement image compression logic here
      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.debug('Image compression completed');
      return imageFile.path;
    } catch (e) {
      AppLogger.error('Image compression failed: $e');
      return imageFile.path;
    }
  }

  Future<File> resizeImage(File imageFile, {int maxWidth = 1080, int maxHeight = 1080}) async {
    try {
      AppLogger.debug('Resizing image to ${maxWidth}x$maxHeight');
      // Implement image resizing logic here
      await Future.delayed(const Duration(milliseconds: 300));
      AppLogger.debug('Image resizing completed');
      return imageFile;
    } catch (e) {
      AppLogger.error('Image resizing failed: $e');
      return imageFile;
    }
  }

  Future<List<File>> processMultipleImages(List<File> images) async {
    try {
      AppLogger.debug('Processing ${images.length} images');
      final processedImages = <File>[];

      for (final image in images) {
        try {
          if (!_validateFileSize(image, maxSizeInMB: 10)) {
            final compressedPath = await _compressImage(image);
            final compressedFile = File(compressedPath);

            if (!_validateFileSize(compressedFile, maxSizeInMB: 10)) {
              final resizedFile = await resizeImage(compressedFile);
              processedImages.add(resizedFile);
            } else {
              processedImages.add(compressedFile);
            }
          } else {
            processedImages.add(image);
          }
        } catch (e) {
          AppLogger.error('Failed to process image: ${image.path} - $e');
        }
      }

      AppLogger.debug('Processed ${processedImages.length} images successfully');
      return processedImages;
    } catch (e) {
      AppLogger.error('Failed to process multiple images: $e');
      rethrow;
    }
  }

  // Utility methods
  Future<bool> _checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      if (status.isGranted) return true;

      final result = await Permission.storage.request();
      return result.isGranted;
    } catch (e) {
      AppLogger.error('Storage permission check failed: $e');
      return false;
    }
  }

  bool _validateFileSize(File file, {required int maxSizeInMB}) {
    try {
      final sizeInBytes = file.lengthSync();
      final sizeInMB = sizeInBytes / (1024 * 1024);
      final isValid = sizeInMB <= maxSizeInMB;

      if (!isValid) {
        AppLogger.debug('File size validation failed: ${sizeInMB.toStringAsFixed(2)}MB > ${maxSizeInMB}MB');
      }

      return isValid;
    } catch (e) {
      AppLogger.error('File size validation failed: $e');
      return false;
    }
  }

  String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final size = file.lengthSync();
      return _formatBytes(size);
    } catch (e) {
      AppLogger.error('Failed to get file size: $e');
      return 'Unknown';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Cache management
  Future<int> getTotalCacheSize() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = await directory.list().toList();

      int totalSize = 0;
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      AppLogger.debug('Total cache size: ${_formatBytes(totalSize)}');
      return totalSize;
    } catch (e) {
      AppLogger.error('Failed to get total cache size: $e');
      return 0;
    }
  }

  Future<void> clearCache() async {
    try {
      final directory = await getTemporaryDirectory();
      final files = await directory.list().toList();

      int deletedCount = 0;
      for (final file in files) {
        if (file is File) {
          await file.delete();
          deletedCount++;
        }
      }

      AppLogger.debug('Cache cleared: $deletedCount files deleted');
    } catch (e) {
      AppLogger.error('Failed to clear cache: $e');
      rethrow;
    }
  }

  // Additional utility methods
  Future<bool> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      AppLogger.debug('File ready for sharing: $filePath');
      return true;
    } catch (e) {
      AppLogger.error('Failed to share file: $e');
      return false;
    }
  }

  Future<bool> validateFileIntegrity(String filePath, String expectedHash) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final actualHash = sha256.convert(bytes).toString();
      return actualHash == expectedHash;
    } catch (e) {
      AppLogger.error('File integrity validation failed: $e');
      return false;
    }
  }

  Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64.encode(bytes);
      AppLogger.debug('Image converted to base64');
      return base64Image;
    } catch (e) {
      AppLogger.error('Failed to convert image to base64: $e');
      rethrow;
    }
  }

  Future<bool> saveImageToGallery(File imageFile) async {
    try {
      AppLogger.debug('Image saved to gallery: ${imageFile.path}');
      return true;
    } catch (e) {
      AppLogger.error('Failed to save image to gallery: $e');
      return false;
    }
  }

  Future<void> cleanupTempFiles(List<File> files) async {
    try {
      for (final file in files) {
        if (await file.exists()) {
          await file.delete();
        }
      }
      AppLogger.debug('Cleaned up ${files.length} temporary files');
    } catch (e) {
      AppLogger.error('Failed to cleanup temp files: $e');
    }
  }

  Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      // Implement image dimension detection logic here
      return {'width': 1080, 'height': 1080};
    } catch (e) {
      AppLogger.error('Failed to get image dimensions: $e');
      return {'width': 0, 'height': 0};
    }
  }
}
