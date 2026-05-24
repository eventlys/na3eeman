import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'logger.dart';

class StorageHelper {
  static final StorageHelper _instance = StorageHelper._internal();

  factory StorageHelper() => _instance;

  StorageHelper._internal();

  // Get application documents directory
  static Future<Directory> get appDocumentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  // Get temporary directory
  static Future<Directory> get temporaryDirectory async {
    return await getTemporaryDirectory();
  }

  // Get application support directory
  static Future<Directory> get applicationSupportDirectory async {
    return await getApplicationSupportDirectory();
  }

  // Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      AppLogger.error('Error checking file existence: $filePath', error: e);
      return false;
    }
  }

  // Read file as string
  static Future<String?> readFileAsString(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error reading file: $filePath', error: e);
      return null;
    }
  }

  // Read file as bytes
  static Future<List<int>?> readFileAsBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      AppLogger.error('Error reading file as bytes: $filePath', error: e);
      return null;
    }
  }

  // Write string to file
  static Future<bool> writeStringToFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(content);
      AppLogger.debug('File written successfully: $filePath');
      return true;
    } catch (e) {
      AppLogger.error('Error writing file: $filePath', error: e);
      return false;
    }
  }

  // Write bytes to file
  static Future<bool> writeBytesToFile(String filePath, List<int> bytes) async {
    try {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      AppLogger.debug('File written successfully: $filePath');
      return true;
    } catch (e) {
      AppLogger.error('Error writing file as bytes: $filePath', error: e);
      return false;
    }
  }

  // Delete file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.debug('File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error deleting file: $filePath', error: e);
      return false;
    }
  }

  // Copy file
  static Future<bool> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        AppLogger.debug('File copied: $sourcePath → $destinationPath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error(
        'Error copying file: $sourcePath → $destinationPath',
        error: e,
      );
      return false;
    }
  }

  // Move file
  static Future<bool> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.rename(destinationPath);
        AppLogger.debug('File moved: $sourcePath → $destinationPath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error(
        'Error moving file: $sourcePath → $destinationPath',
        error: e,
      );
      return false;
    }
  }

  // Get file size
  static Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.size;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting file size: $filePath', error: e);
      return null;
    }
  }

  // Get file modification time
  static Future<DateTime?> getFileModifiedTime(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return stat.modified;
      }
      return null;
    } catch (e) {
      AppLogger.error(
        'Error getting file modification time: $filePath',
        error: e,
      );
      return null;
    }
  }

  // List files in directory
  static Future<List<FileSystemEntity>> listFiles(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        return await directory.list().toList();
      }
      return [];
    } catch (e) {
      AppLogger.error(
        'Error listing files in directory: $directoryPath',
        error: e,
      );
      return [];
    }
  }

  // Create directory
  static Future<bool> createDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      await directory.create(recursive: true);
      AppLogger.debug('Directory created: $directoryPath');
      return true;
    } catch (e) {
      AppLogger.error('Error creating directory: $directoryPath', error: e);
      return false;
    }
  }

  // Delete directory
  static Future<bool> deleteDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        AppLogger.debug('Directory deleted: $directoryPath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error deleting directory: $directoryPath', error: e);
      return false;
    }
  }

  // Check available storage space (approximate)
  static Future<int?> getAvailableStorageSpace() async {
    try {
      final directory = await temporaryDirectory;
      // This is a simplified check - actual implementation may vary by platform
      return 1024 * 1024 * 100; // Assume 100MB available for demo
    } catch (e) {
      AppLogger.error('Error checking available storage space', error: e);
      return null;
    }
  }

  // Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await temporaryDirectory;
      final files = await listFiles(tempDir.path);

      int deletedCount = 0;
      for (final file in files) {
        if (file is File) {
          // Delete files older than 7 days
          final modified = await getFileModifiedTime(file.path);
          if (modified != null) {
            final age = DateTime.now().difference(modified);
            if (age.inDays > 7) {
              await deleteFile(file.path);
              deletedCount++;
            }
          }
        }
      }

      AppLogger.debug('Cleaned up $deletedCount temporary files');
    } catch (e) {
      AppLogger.error('Error cleaning up temporary files', error: e);
    }
  }

  // Save JSON data to file
  static Future<bool> saveJsonToFile(
    String filePath,
    Map<String, dynamic> data,
  ) async {
    try {
      final jsonString = json.encode(data);
      return await writeStringToFile(filePath, jsonString);
    } catch (e) {
      AppLogger.error('Error saving JSON to file: $filePath', error: e);
      return false;
    }
  }

  // Load JSON data from file
  static Future<Map<String, dynamic>?> loadJsonFromFile(String filePath) async {
    try {
      final jsonString = await readFileAsString(filePath);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error loading JSON from file: $filePath', error: e);
      return null;
    }
  }

  // Backup file
  static Future<bool> backupFile(String filePath) async {
    try {
      final backupPath = '$filePath.backup';
      return await copyFile(filePath, backupPath);
    } catch (e) {
      AppLogger.error('Error backing up file: $filePath', error: e);
      return false;
    }
  }

  // Restore from backup
  static Future<bool> restoreFromBackup(String filePath) async {
    try {
      final backupPath = '$filePath.backup';
      if (await fileExists(backupPath)) {
        return await copyFile(backupPath, filePath);
      }
      return false;
    } catch (e) {
      AppLogger.error('Error restoring from backup: $filePath', error: e);
      return false;
    }
  }

  // Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final docsDir = await appDocumentsDirectory;
      final tempDir = await temporaryDirectory;

      final docsFiles = await listFiles(docsDir.path);
      final tempFiles = await listFiles(tempDir.path);

      int docsSize = 0;
      int tempSize = 0;

      for (final file in docsFiles) {
        if (file is File) {
          final size = await getFileSize(file.path);
          docsSize += size ?? 0;
        }
      }

      for (final file in tempFiles) {
        if (file is File) {
          final size = await getFileSize(file.path);
          tempSize += size ?? 0;
        }
      }

      return {
        'documents_directory': {
          'path': docsDir.path,
          'file_count': docsFiles.length,
          'total_size': docsSize,
          'formatted_size': _formatBytes(docsSize),
        },
        'temporary_directory': {
          'path': tempDir.path,
          'file_count': tempFiles.length,
          'total_size': tempSize,
          'formatted_size': _formatBytes(tempSize),
        },
        'total_size': docsSize + tempSize,
        'formatted_total_size': _formatBytes(docsSize + tempSize),
      };
    } catch (e) {
      AppLogger.error('Error getting storage statistics', error: e);
      return {};
    }
  }

  // Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Check if path is within app directory (security check)
  static Future<bool> isPathWithinAppDirectory(String filePath) async {
    try {
      final docsDir = await appDocumentsDirectory;
      final tempDir = await temporaryDirectory;
      final supportDir = await applicationSupportDirectory;

      final normalizedPath = File(filePath).absolute.path;

      return normalizedPath.startsWith(docsDir.absolute.path) ||
          normalizedPath.startsWith(tempDir.absolute.path) ||
          normalizedPath.startsWith(supportDir.absolute.path);
    } catch (e) {
      AppLogger.error('Error checking path security: $filePath', error: e);
      return false;
    }
  }
}
