import 'package:flutter/material.dart';
import '../../Services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar');
  final UnifiedStorageService _storage = UnifiedStorageService();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = _storage.getPreference('app_locale') as String?;
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;

    _locale = locale;
    await _storage.setPreference('app_locale', locale.languageCode);
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('ar');
    _storage.removePreference('app_locale');
    notifyListeners();
  }
}
