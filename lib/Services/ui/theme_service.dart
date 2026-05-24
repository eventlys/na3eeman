// lib/Services/ui/theme_service.dart
import 'package:flutter/material.dart';
import '../storage_service.dart';

class ThemeService {
  final UnifiedStorageService _storageService = UnifiedStorageService();
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );
  final ValueNotifier<String> themeModeNotifier = ValueNotifier('System');

  Future<void> init() async {
    // Load saved theme preference
    final savedTheme = _storageService.getPreference('theme_mode');

    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          themeNotifier.value = ThemeMode.light;
          themeModeNotifier.value = 'Light';
          break;
        case 'dark':
          themeNotifier.value = ThemeMode.dark;
          themeModeNotifier.value = 'Dark';
          break;
        case 'system':
        default:
          themeNotifier.value = ThemeMode.system;
          themeModeNotifier.value = 'System';
          break;
      }
    } else {
      themeNotifier.value = ThemeMode.system;
      themeModeNotifier.value = 'System';
    }
  }

  void changeTheme(ThemeMode themeMode) {
    themeNotifier.value = themeMode;

    switch (themeMode) {
      case ThemeMode.light:
        themeModeNotifier.value = 'Light';
        _storageService.setPreference('theme_mode', 'light');
        break;
      case ThemeMode.dark:
        themeModeNotifier.value = 'Dark';
        _storageService.setPreference('theme_mode', 'dark');
        break;
      case ThemeMode.system:
        themeModeNotifier.value = 'System';
        _storageService.setPreference('theme_mode', 'system');
        break;
    }
  }

  // Get theme data based on current mode
  ThemeData getThemeData(BuildContext context, bool isDarkMode) {
    return isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    primaryColor: Colors.blue,
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    primaryColor: Colors.blue,
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900], elevation: 0),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      color: Colors.grey[800],
    ),
  );

  // Custom colors for the app
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  static const Color errorColor = Colors.red;
  static const Color infoColor = Colors.blue;

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}
