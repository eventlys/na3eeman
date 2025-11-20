import 'dart:ui';

class AppConstants {
  static const String appName = 'My App';
  static const String appStoreLink = 'https://apps.apple.com/app/idYOUR_APP_ID';
  static const String playStoreLink = 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';

  // Staff Management Constants
  static const List<String> barberSpecialties = [
    'Haircut',
    'Beard Trim',
    'Shave',
    'Hair Color',
    'Styling',
    'Fade',
    'Kids Cut',
    'Senior Cut'
  ];

  static const Map<String, double> servicePrices = {
    'Haircut': 25.00,
    'Beard Trim': 15.00,
    'Shave': 20.00,
    'Hair Color': 60.00,
    'Styling': 35.00,
  };
}

