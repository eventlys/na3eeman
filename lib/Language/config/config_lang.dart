import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

class AppLocalization {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'EG'),
  ];
  
  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const Map<String, Map<String, String>> translations = {
    'en_US': {
      'app_title': 'Na3eeman',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'sign_up': 'Sign Up',
      'welcome': 'Welcome',
      'shops': 'Shops',
      'appointments': 'Appointments',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'search': 'Search',
      'no_results': 'No results found',
      'try_again': 'Try Again',
      'error_occurred': 'An error occurred',
      'loading': 'Loading...',
    },
    'ar_EG': {
      'app_title': 'نعيمن',
      'login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'sign_up': 'إنشاء حساب',
      'welcome': 'مرحباً',
      'shops': 'المتاجر',
      'appointments': 'المواعيد',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'search': 'بحث',
      'no_results': 'لا توجد نتائج',
      'try_again': 'حاول مرة أخرى',
      'error_occurred': 'حدث خطأ',
      'loading': 'جاري التحميل...',
    },
  };
  
  static String getString(String key) {
    final locale = Get.locale ?? const Locale('en', 'US');
    final localeKey = '${locale.languageCode}_${locale.countryCode}';
    
    final translation = translations[localeKey]?[key] ?? 
                       translations['en_US']?[key] ?? 
                       key;
    
    return translation;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return AppLocalization.supportedLocales.any(
      (supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode &&
        supportedLocale.countryCode == locale.countryCode,
    );
  }
  
  @override
  Future<AppLocalization> load(Locale locale) async {
    return AppLocalization();
  }
  
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
