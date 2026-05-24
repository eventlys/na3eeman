import '../../../config/environment.dart';

class AppConstants {
  // App Information
  static const String appName = 'Na3eeman';
  static const String appTagline = 'Premium Expert Experience';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Store Links
  static const String appStoreLink = 'https://apps.apple.com/app/idYOUR_APP_ID';
  static const String playStoreLink =
      'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';

  // API Constants
  static String get baseUrl => Environment.config.apiBaseUrl;
  static String get webAppUrl => Environment.config.webAppUrl;
  static String get adminEmail => Environment.config.adminEmail;
  static String get supportEmail => Environment.config.supportEmail;
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxRetryAttempts = 3;

  // API Endpoints - Updated to match your backend
  // Authentication Endpoints
  static const String registerEndpoint = '/usr/auth/register/';
  static const String loginEndpoint = '/usr/auth/login/';
  static const String logoutEndpoint = '/usr/auth/logout/';
  static const String verifyEmailEndpoint = '/usr/auth/verify-email/';
  static const String verifyPhoneEndpoint = '/usr/auth/verify-phone/';
  static const String googleAuthEndpoint = '/usr/auth/google/';
  static const String appleAuthEndpoint = '/usr/auth/apple/';
  static const String refreshTokenEndpoint = '/usr/auth/token/refresh/';
  static const String verifyTokenEndpoint = '/usr/auth/token/verify/';

  // User Profile Endpoints
  static const String userProfileEndpoint = '/usr/prof/';
  static const String updateProfileEndpoint = '/usr/prof/update/';
  static const String changePasswordEndpoint = '/usr/prof/change-password/';
  static const String updateProfilePictureEndpoint = '/usr/prof/picture/';
  static const String updateLocationEndpoint = '/usr/prof/location/';
  static const String continueProfileEndpoint = '/usr/prof/continue/';
  static const String deleteProfileEndpoint = '/usr/prof/delete/';

  // User Management Endpoints
  static const String checkUsernameEndpoint = '/usr/check/username/';
  static const String checkEmailEndpoint = '/usr/check/email/';
  static const String whoamiEndpoint = '/usr/whoami/';
  static const String userProfilesEndpoint = '/usr/profiles/';
  static const String userProfileByIdEndpoint = '/usr/profiles/{id}/';
  static const String userByIdEndpoint = '/usr/users/{id}/';
  static const String changeUserRoleEndpoint = '/usr/users/change-role/';
  static const String expertsEndpoint = '/usr/experts/';
  static const String customersEndpoint = '/usr/customers/';

  // Salon Endpoints
  static const String salonsEndpoint = '/salon/salons';
  static const String salonAppointmentsEndpoint = '/salon/appointments';
  static const String salonReviewsEndpoint = '/salon/reviews';
  static const String salonSubscriptionsEndpoint = '/salon/subscriptions';
  static const String salonStylesEndpoint = '/salon/styles';
  static const String salonOptionsEndpoint = '/salon/options';
  static const String salonPackagesEndpoint = '/salon/packages';
  static const String salonProductsEndpoint = '/salon/products';
  static const String salonInventoryEndpoint = '/salon/inventory';
  static const String salonExpertsEndpoint = '/salon/experts';

  // Loyalty Endpoints
  static const String loyaltyBalanceEndpoint = '/loyalty/balance';
  static const String loyaltyAdminAdjustEndpoint = '/loyalty/admin-adjust';
  static const String loyaltyRedeemFreeCutEndpoint = '/loyalty/redeem-free-cut';
  static const String loyaltyAdminAdjustPointsEndpoint =
      '/loyalty/admin/adjust-points';

  // Health Check
  static const String healthEndpoint = '/usr/health/';

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 350);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  // Debounce Timers
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);
  static const Duration buttonDebounceDuration = Duration(milliseconds: 300);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String appSettingsKey = 'app_settings';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 254;
  static const int maxPhoneLength = 15;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // Layout Constraints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Sidebar
  static const double sidebarWidth = 280.0;
  static const double sidebarAnimationDuration = 400;

  // Salon Constants
  static const double minSalonRating = 1.0;
  static const double maxSalonRating = 5.0;
  static const int maxGalleryImages = 10;
  static const int maxServicesPerSalon = 20;

  // Staff Management Constants
  static const List<String> expertSpecialties = [
    'Haircut',
    'Beard Trim',
    'Shave',
    'Hair Color',
    'Styling',
    'Fade',
    'Kids Cut',
    'Senior Cut',
  ];

  static const Map<String, double> servicePrices = {
    'Haircut': 25.00,
    'Beard Trim': 15.00,
    'Shave': 20.00,
    'Hair Color': 60.00,
    'Styling': 35.00,
  };

  // Appointment Constants
  static const int appointmentReminderMinutes = 30;
  static const int maxAppointmentDuration = 240; // 4 hours in minutes
  static const int minAppointmentAdvanceDays = 0;
  static const int maxAppointmentAdvanceDays = 90;

  // Payment Constants
  static const double minPaymentAmount = 0.01;
  static const double maxPaymentAmount = 10000.0;
  static const int currencyDecimalPlaces = 2;

  // Points System
  static const int pointsForInvite = 50;
  static const int pointsForRating = 10;
  static const int pointsForAppointment = 25;
  static const int pointsForFeedback = 15;

  // Cache Durations
  static const Duration salonCacheDuration = Duration(minutes: 30);
  static const Duration userCacheDuration = Duration(hours: 1);
  static const Duration configCacheDuration = Duration(hours: 24);
  static const int cacheTimeout = 300;

  // File Size Limits (in bytes)
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Other Constants
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 300; // 5 minutes
  static const int resendOtpCooldown = 30; // 30 seconds
}
