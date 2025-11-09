import 'package:flutter/material.dart';
import '../Services/theme_service.dart';
import '../Services/language_service.dart';

class DialogHelper {
  static void showLanguageBottomSheet(
      BuildContext context, LanguageService languageService) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇺🇸'),
                title: const Text('English'),
                trailing: languageService.languageNotifier.value == 'English'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  languageService.changeLanguage(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦'),
                title: const Text('العربية'),
                trailing: languageService.languageNotifier.value == 'العربية'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  languageService.changeLanguage(const Locale('ar', 'AR'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showThemeBottomSheet(
      BuildContext context, ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Mode'),
                trailing: themeService.themeModeNotifier.value == 'Light'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeService.changeTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: themeService.themeModeNotifier.value == 'Dark'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeService.changeTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_iphone),
                title: const Text('System Default'),
                trailing: themeService.themeModeNotifier.value == 'System'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeService.changeTheme(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
