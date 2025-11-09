import 'package:flutter/material.dart';

class LanguageService {
  final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);
  final ValueNotifier<String> languageNotifier = ValueNotifier('English');

  Future<void> init() async {
    // Load saved language preference
    // For demo, we'll use English
    localeNotifier.value = const Locale('en', 'US');
    languageNotifier.value = 'English';
  }

  void changeLanguage(Locale locale) {
    localeNotifier.value = locale;
    if (locale.languageCode == 'ar') {
      languageNotifier.value = 'العربية';
    } else {
      languageNotifier.value = 'English';
    }
    // Save preference to storage
  }
}
