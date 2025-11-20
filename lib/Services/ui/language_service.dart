import 'package:flutter/material.dart';
import '../../Helpers/logger.dart';
import '../storage_service.dart';

class LanguageService with ChangeNotifier {
  final UnifiedStorageService _localStorage = UnifiedStorageService();
  // final LoggingInterceptor _logger = LoggingInterceptor();

  Locale? _currentLocale;
  String _currentLanguage = 'English';

  // Supported languages
  static const Map<String, Locale> supportedLocales = {
    'English': Locale('en', 'US'),
    'العربية': Locale('ar', 'SA'),
  };

  // Language data
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'welcome': 'Welcome',
      'book_appointment': 'Book Appointment',
      'my_appointments': 'My Appointments',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
    },
    'ar': {
      'welcome': 'مرحباً',
      'book_appointment': 'حجز موعد',
      'my_appointments': 'مواعيدي',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
    },
  };

  // Getters
  Locale? get currentLocale => _currentLocale;
  String get currentLanguage => _currentLanguage;
  List<String> get supportedLanguages => supportedLocales.keys.toList();

  Future<void> init() async {
    try {
      await _localStorage.initialize();

      // Load saved language preference
      final savedLanguage = _localStorage.getPreference('selected_language');

      if (savedLanguage != null && supportedLocales.containsKey(savedLanguage)) {
        _currentLanguage = savedLanguage;
        _currentLocale = supportedLocales[savedLanguage];
      } else {
        // Default to English
        _currentLanguage = 'English';
        _currentLocale = supportedLocales['English'];
      }

      AppLogger.debug('Language service initialized: $_currentLanguage');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to initialize language service: $e');
      // Fallback to English
      _currentLanguage = 'English';
      _currentLocale = supportedLocales['English'];
      notifyListeners();
    }
  }

  void changeLanguage(String language) {
    try {
      if (!supportedLocales.containsKey(language)) {
        throw Exception('Unsupported language: $language');
      }

      _currentLanguage = language;
      _currentLocale = supportedLocales[language];

      // Save preference
      _localStorage.setPreference('selected_language', language);

      AppLogger.debug('Language changed to: $language');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to change language: $e');
      rethrow;
    }
  }

  String translate(String key) {
    try {
      final localeCode = _currentLocale?.languageCode ?? 'en';
      final translations = _translations[localeCode] ?? _translations['en']!;
      return translations[key] ?? key;
    } catch (e) {
      AppLogger.error('Translation failed for key: $key - $e');
      return key;
    }
  }

  bool isRTL() {
    return _currentLocale?.languageCode == 'ar';
  }

  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  Alignment get alignment {
    return isRTL() ? Alignment.centerRight : Alignment.centerLeft;
  }

  // Method to get language name from locale
  String getLanguageName(Locale locale) {
    final entry = supportedLocales.entries.firstWhere(
      (entry) => entry.value.languageCode == locale.languageCode,
      orElse: () => MapEntry('English', const Locale('en', 'US')),
    );
    return entry.key;
  }

  // Method to check if language is supported
  bool isLanguageSupported(String language) {
    return supportedLocales.containsKey(language);
  }

  // Method to get all supported locales
  List<Locale> getSupportedLocales() {
    return supportedLocales.values.toList();
  }

  // Method to reset to default language
  void resetToDefault() {
    changeLanguage('English');
  }
}

// Extension for easy translation
extension TranslationExtension on String {
  String tr(BuildContext context) {
    final languageService = context.dependOnInheritedWidgetOfExactType<InheritedLanguageService>();
    return languageService?.translate(this) ?? this;
  }
}

// Inherited widget for language service
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

  @override
  bool updateShouldNotify(InheritedLanguageService oldWidget) {
    return oldWidget.languageService.currentLanguage != languageService.currentLanguage;
  }

  static InheritedLanguageService? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedLanguageService>();
  }
}
