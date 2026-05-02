import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logger.dart';

class LocalizationHelper {
  static final LocalizationHelper _instance = LocalizationHelper._internal();

  factory LocalizationHelper() => _instance;

  LocalizationHelper._internal();

  final Map<String, Map<String, String>> _localizedStrings = {};
  Locale _currentLocale = const Locale('en', 'US');

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ar', 'SA'), // Arabic
  ];

  // Default locale
  static const Locale defaultLocale = Locale('en', 'US');

  // Get current locale
  Locale get currentLocale => _currentLocale;

  // Check if a locale is supported
  bool isLocaleSupported(Locale locale) {
    return supportedLocales.any((supported) =>
      supported.languageCode == locale.languageCode
    );
  }

  // Load localization strings
  Future<bool> load(Locale locale) async {
    try {
      final languageCode = locale.languageCode;

      // Load the JSON file from assets
      final jsonString = await rootBundle.loadString(
        'assets/locales/$languageCode.json',
      );

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Convert the JSON map to string map
      _localizedStrings[languageCode] = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      _currentLocale = locale;

      AppLogger.debug('Localization loaded for: $languageCode');
      return true;
    } catch (e) {
      AppLogger.error('Failed to load localization for ${locale.languageCode}', error: e);

      // Fallback to English
      if (locale.languageCode != 'en') {
        return await load(defaultLocale);
      }

      return false;
    }
  }

  // Translate a key
  String translate(String key, {Map<String, String>? params}) {
    try {
      final languageCode = _currentLocale.languageCode;
      var translation = _localizedStrings[languageCode]?[key] ?? key;

      // Replace parameters if provided
      if (params != null) {
        params.forEach((paramKey, paramValue) {
          translation = translation.replaceAll('{{$paramKey}}', paramValue);
        });
      }

      return translation;
    } catch (e) {
      AppLogger.error('Translation failed for key: $key', error: e);
      return key;
    }
  }

  // Check if a key exists
  bool keyExists(String key) {
    final languageCode = _currentLocale.languageCode;
    return _localizedStrings[languageCode]?.containsKey(key) ?? false;
  }

  // Get all keys for current locale
  List<String> getKeys() {
    final languageCode = _currentLocale.languageCode;
    return _localizedStrings[languageCode]?.keys.toList() ?? [];
  }

  // Change locale
  Future<bool> changeLocale(Locale newLocale) async {
    if (!isLocaleSupported(newLocale)) {
      AppLogger.warning('Locale not supported: $newLocale');
      return false;
    }

    if (_currentLocale.languageCode != newLocale.languageCode) {
      return await load(newLocale);
    }

    return true;
  }

  // Check if current locale is RTL
  bool isRTL() {
    return _currentLocale.languageCode == 'ar';
  }

  // Get text direction for current locale
  TextDirection get textDirection {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  // Get alignment based on text direction
  Alignment get alignment {
    return isRTL() ? Alignment.centerRight : Alignment.centerLeft;
  }

  // Get cross-axis alignment based on text direction
  CrossAxisAlignment get crossAxisAlignment {
    return isRTL() ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  // Get main-axis alignment based on text direction
  MainAxisAlignment get mainAxisAlignment {
    return isRTL() ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  // Format number based on locale
  String formatNumber(num number) {
    // Basic implementation - in production, use intl package
    if (isRTL()) {
      // Arabic numerals
      final arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      return number.toString().split('').map((digit) {
        if (int.tryParse(digit) != null) {
          return arabicNumerals[int.parse(digit)];
        }
        return digit;
      }).join();
    }

    return number.toString();
  }

  // Format currency based on locale
  String formatCurrency(double amount, {String? currencyCode}) {
    // Basic implementation - in production, use intl package
    final formattedAmount = amount.toStringAsFixed(2);

    if (isRTL()) {
      return '${formatNumber(amount)} ${currencyCode ?? ''}'.trim();
    } else {
      return '${currencyCode ?? '\$'} $formattedAmount';
    }
  }

  // Format date based on locale
  String formatDate(DateTime date, {String? format}) {
    // Basic implementation - in production, use intl package
    if (isRTL()) {
      // Arabic date format
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }

  // Get current locale display name
  String get currentLocaleDisplayName {
    return getLocaleDisplayName(_currentLocale);
  }

  // Get all supported locales with display names
  Map<Locale, String> getSupportedLocalesWithNames() {
    final Map<Locale, String> locales = {};
    for (final locale in supportedLocales) {
      locales[locale] = getLocaleDisplayName(locale);
    }
    return locales;
  }

  // Pluralization helper (basic implementation)
  String pluralize(String key, int count, {Map<String, String>? params}) {
    final pluralKey = count == 1 ? '${key}_singular' : '${key}_plural';

    if (keyExists(pluralKey)) {
      final translation = translate(pluralKey, params: params);
      return translation.replaceAll('{{count}}', count.toString());
    }

    // Fallback to basic translation
    final baseTranslation = translate(key, params: params);
    return '$baseTranslation ($count)';
  }

  // Gender-aware translation helper
  String genderAware(String key, String gender, {Map<String, String>? params}) {
    final genderKey = '${key}_$gender';

    if (keyExists(genderKey)) {
      return translate(genderKey, params: params);
    }

    // Fallback to neutral version
    final neutralKey = '${key}_neutral';
    if (keyExists(neutralKey)) {
      return translate(neutralKey, params: params);
    }

    // Fallback to base key
    return translate(key, params: params);
  }

  // Context-aware translation helper
  String contextAware(String key, String context, {Map<String, String>? params}) {
    final contextKey = '${key}_$context';

    if (keyExists(contextKey)) {
      return translate(contextKey, params: params);
    }

    // Fallback to base key
    return translate(key, params: params);
  }

  // Batch translation for multiple keys
  Map<String, String> translateMultiple(List<String> keys, {Map<String, Map<String, String>>? params}) {
    final translations = <String, String>{};

    for (final key in keys) {
      final keyParams = params?[key];
      translations[key] = translate(key, params: keyParams);
    }

    return translations;
  }

  // Clear all loaded translations
  void clear() {
    _localizedStrings.clear();
    _currentLocale = defaultLocale;
  }

  // Get translation statistics
  Map<String, dynamic> getStatistics() {
    final languageCode = _currentLocale.languageCode;
    final translations = _localizedStrings[languageCode] ?? {};

    return {
      'current_locale': _currentLocale.toString(),
      'loaded_keys': translations.length,
      'supported_locales': supportedLocales.length,
      'is_rtl': isRTL(),
    };
  }
}

// Extension for easy translation in widgets
extension LocalizationExtension on String {
  String tr(BuildContext context, {Map<String, String>? params}) {
    final localizationHelper = LocalizationHelper();
    return localizationHelper.translate(this, params: params);
  }

  String trn(BuildContext context, int count, {Map<String, String>? params}) {
    final localizationHelper = LocalizationHelper();
    return localizationHelper.pluralize(this, count, params: params);
  }

  String trg(BuildContext context, String gender, {Map<String, String>? params}) {
    final localizationHelper = LocalizationHelper();
    return localizationHelper.genderAware(this, gender, params: params);
  }

  String trc(BuildContext context, String contextType, {Map<String, String>? params}) {
    final localizationHelper = LocalizationHelper();
    return localizationHelper.contextAware(this, contextType, params: params);
  }
}

// Localization delegate for MaterialApp
class AppLocalizationsDelegate extends LocalizationsDelegate<LocalizationHelper> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationHelper().isLocaleSupported(locale);
  }

  @override
  Future<LocalizationHelper> load(Locale locale) async {
    final localizationHelper = LocalizationHelper();
    await localizationHelper.load(locale);
    return localizationHelper;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
