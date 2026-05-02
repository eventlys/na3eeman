import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../../Helpers/logger.dart';
import '../storage_service.dart';
import '../translation_service.dart';

class LanguageService with ChangeNotifier {
  final UnifiedStorageService _localStorage = UnifiedStorageService();

  Locale? _currentLocale;
  String _currentLanguage = 'العربية'; // Default to Arabic for Jordan market

  // Supported languages
  static const Map<String, Locale> supportedLocales = {
    'English': Locale('en', 'US'),
    'العربية': Locale('ar', 'JO'), // Changed to JO for Jordan
  };

  // Getters
  Locale? get currentLocale => _currentLocale;
  String get currentLanguage => _currentLanguage;
  String get currentLanguageCode => _currentLocale?.languageCode ?? 'ar';
  List<String> get supportedLanguages => supportedLocales.keys.toList();

  /// Initialize language service with device language auto-detection
  Future<void> init() async {
    try {
      await _localStorage.initialize();

      // Load saved language preference
      final savedLanguage = _localStorage.getPreference('selected_language');

      if (savedLanguage != null &&
          supportedLocales.containsKey(savedLanguage)) {
        // User has a saved preference - use it
        _currentLanguage = savedLanguage;
        _currentLocale = supportedLocales[savedLanguage];
        AppLogger.info('Loaded saved language: $savedLanguage');
      } else {
        // No saved preference - detect device language
        _detectAndSetDeviceLanguage();
      }

      AppLogger.info(
        'Language service initialized: $_currentLanguage (${_currentLocale?.languageCode})',
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to initialize language service: $e');
      // Fallback to Arabic for Jordan market
      _currentLanguage = 'العربية';
      _currentLocale = supportedLocales['العربية'];
      notifyListeners();
    }
  }

  /// Detect device language and set app language accordingly
  void _detectAndSetDeviceLanguage() {
    try {
      // Get device locale from platform
      final deviceLocale =
          Platform.localeName; // Returns 'ar_JO', 'en_US', etc.
      final languageCode = deviceLocale.split('_')[0]; // Extract 'ar' or 'en'

      AppLogger.info(
        'Detected device locale: $deviceLocale, language code: $languageCode',
      );

      // Map language code to our supported languages
      if (languageCode == 'ar') {
        _currentLanguage = 'العربية';
        _currentLocale = supportedLocales['العربية'];
        AppLogger.info('Set language to Arabic based on device');
      } else if (languageCode == 'en') {
        _currentLanguage = 'English';
        _currentLocale = supportedLocales['English'];
        AppLogger.info('Set language to English based on device');
      } else {
        // Default to Arabic for Jordan market (most likely case)
        _currentLanguage = 'العربية';
        _currentLocale = supportedLocales['العربية'];
        AppLogger.info('Unsupported device language, defaulting to Arabic');
      }
    } catch (e) {
      AppLogger.error('Failed to detect device language: $e');
      // Fallback to Arabic
      _currentLanguage = 'العربية';
      _currentLocale = supportedLocales['العربية'];
    }
  }

  /// Change language and save preference
  void changeLanguage(String language) {
    try {
      if (!supportedLocales.containsKey(language)) {
        throw Exception('Unsupported language: $language');
      }

      _currentLanguage = language;
      _currentLocale = supportedLocales[language];

      // Save preference
      _localStorage.setPreference('selected_language', language);

      AppLogger.info('Language changed to: $language');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to change language: $e');
      rethrow;
    }
  }

  /// Toggle between Arabic and English
  void toggleLanguage() {
    final newLanguage = _currentLanguage == 'العربية' ? 'English' : 'العربية';
    changeLanguage(newLanguage);
  }

  /// Translate a key using the comprehensive TranslationService
  String translate(String key) {
    try {
      final localeCode = _currentLocale?.languageCode ?? 'ar';
      return TranslationService.translate(key, localeCode);
    } catch (e) {
      AppLogger.error('Translation failed for key: $key - $e');
      return key;
    }
  }

  /// Check if current language is RTL (Right-to-Left)
  bool isRTL() {
    return _currentLocale?.languageCode == 'ar';
  }

  /// Get text direction based on current language
  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get alignment based on current language (RTL vs LTR)
  Alignment get alignment {
    return isRTL() ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// Get cross-axis alignment for columns/rows
  CrossAxisAlignment get crossAxisAlignment {
    return isRTL() ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  /// Get main-axis alignment for rows
  MainAxisAlignment get mainAxisAlignment {
    return isRTL() ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  /// Format currency using TranslationService
  String formatCurrency(double amount) {
    return TranslationService.formatCurrency(amount, currentLanguageCode);
  }

  /// Format date using TranslationService
  String formatDate(DateTime date) {
    return TranslationService.formatDate(date, currentLanguageCode);
  }

  /// Format time using TranslationService
  String formatTime(DateTime time) {
    return TranslationService.formatTime(time, currentLanguageCode);
  }

  /// Format duration using TranslationService
  String formatDuration(Duration duration) {
    return TranslationService.formatDuration(duration, currentLanguageCode);
  }

  /// Get weekday name
  String getWeekdayName(int dayNumber) {
    return TranslationService.getWeekdayName(dayNumber, currentLanguageCode);
  }

  /// Get month name
  String getMonthName(int monthNumber) {
    return TranslationService.getMonthName(monthNumber, currentLanguageCode);
  }

  /// Get language name from locale
  String getLanguageName(Locale locale) {
    final entry = supportedLocales.entries.firstWhere(
      (entry) => entry.value.languageCode == locale.languageCode,
      orElse: () => MapEntry('العربية', const Locale('ar', 'JO')),
    );
    return entry.key;
  }

  /// Check if language is supported
  bool isLanguageSupported(String language) {
    return supportedLocales.containsKey(language);
  }

  /// Get all supported locales
  List<Locale> getSupportedLocales() {
    return supportedLocales.values.toList();
  }

  /// Reset to device language (or Arabic if device language not supported)
  void resetToDeviceLanguage() {
    // Clear saved preference
    _localStorage.removePreference('selected_language');
    // Re-detect device language
    _detectAndSetDeviceLanguage();
    notifyListeners();
  }

  /// Reset to default language (Arabic for Jordan market)
  void resetToDefault() {
    changeLanguage('العربية');
  }
}

/// Extension for easy translation on strings
extension TranslationExtension on String {
  String tr(BuildContext context) {
    final languageService = context
        .dependOnInheritedWidgetOfExactType<InheritedLanguageService>();
    return languageService?.translate(this) ?? this;
  }
}

/// Inherited widget for language service
class InheritedLanguageService extends InheritedWidget {
  final LanguageService languageService;

  const InheritedLanguageService({
    super.key,
    required this.languageService,
    required super.child,
  });

  String translate(String key) {
    return languageService.translate(key);
  }

  bool isRTL() {
    return languageService.isRTL();
  }

  TextDirection get textDirection {
    return languageService.textDirection;
  }

  @override
  bool updateShouldNotify(InheritedLanguageService oldWidget) {
    return oldWidget.languageService.currentLanguage !=
        languageService.currentLanguage;
  }

  static InheritedLanguageService? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InheritedLanguageService>();
  }
}
