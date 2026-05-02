import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../Providers/app_providers.dart';
import '../../Services/ui/theme_service.dart';
import '../../Services/ui/language_service.dart';

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
              Text(tr('select_language'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇺🇸'),
                title: Text(tr('english')),
                trailing: languageService.currentLanguage == 'English'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  languageService.changeLanguage('English');
                  context.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦'),
                title: const Text('العربية'),
                trailing: languageService.currentLanguage == 'العربية'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  languageService.changeLanguage('العربية');
                  context.setLocale(const Locale('ar', 'EG'));
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
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('select_theme'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: Text(tr('light_mode')),
                trailing: !themeProvider.isDark
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeService.changeTheme(ThemeMode.light);
                  themeProvider.setBrightness(Brightness.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: Text(tr('dark_mode')),
                trailing: themeProvider.isDark
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  themeService.changeTheme(ThemeMode.dark);
                  themeProvider.setBrightness(Brightness.dark);
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