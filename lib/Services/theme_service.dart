import 'package:flutter/material.dart';

class ThemeService {
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
  final ValueNotifier<String> themeModeNotifier = ValueNotifier('System');

  Future<void> init() async {
    // Load saved theme preference
    // For demo, we'll use system theme
    themeNotifier.value = ThemeMode.system;
    themeModeNotifier.value = 'System';
  }

  void changeTheme(ThemeMode themeMode) {
    themeNotifier.value = themeMode;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeNotifier.value = 'Light';
        break;
      case ThemeMode.dark:
        themeModeNotifier.value = 'Dark';
        break;
      case ThemeMode.system:
        themeModeNotifier.value = 'System';
        break;
    }
    // Save preference to storage
  }
}
