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

  // Add other constants as needed
}

class AppColors {
  static const Color primaryColor = Color(0xFF2E86AB);
  static const Color secondaryColor = Color(0xFFA23B72);
  static const Color accentColor = Color(0xFFF18F01);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2B2D42);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Staff Management Specific Colors
  static const Color barberColor = Color(0xFF6D28D9);
  static const Color managerColor = Color(0xFF059669);
  static const Color assistantColor = Color(0xFFDC2626);
  static const Color receptionistColor = Color(0xFF7C3AED);
}

class AppStrings {
  static const String appName = "ShopOwner Pro";
  static const String dashboard = "Dashboard";
  static const String subscription = "Subscription";
  static const String inventory = "Inventory";
  static const String profitReports = "Profit Reports";
  static const String offers = "Offers & Ads";
  static const String branches = "Branch Management";

  // Staff Management Strings
  static const String staffManagement = "Staff Management";
  static const String barbers = "Barbers";
  static const String performance = "Performance";
  static const String staffReports = "Staff Reports";
  static const String assignManager = "Assign Manager";
  static const String staff = "Staff";
  static const String payroll = "Payroll";
  static const String attendance = "Attendance";
}

// Keep your existing AppIcons or add new ones
class AppIcons {
  static const String barber = "assets/icons/barber.svg";
  static const String chart = "assets/icons/chart.svg";
  static const String report = "assets/icons/report.svg";
  static const String branch = "assets/icons/branch.svg";
  static const String staff = "assets/icons/staff.svg";
  static const String payroll = "assets/icons/payroll.svg";
  static const String attendance = "assets/icons/attendance.svg";
}

