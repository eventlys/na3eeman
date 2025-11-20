class AppPaths {
  // Asset Base Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String animationsPath = 'assets/animations/';

  // Icon Paths
  static const String homeIcon = '${iconsPath}home.png';
  static const String profileIcon = '${iconsPath}profile.png';
  static const String settingsIcon = '${iconsPath}settings.png';
  static const String heartIcon = '${iconsPath}heart.png';
  static const String heartFilledIcon = '${iconsPath}heart_filled.png';
  static const String locationIcon = '${iconsPath}location.png';
  static const String starIcon = '${iconsPath}star.png';
  static const String lockIcon = '${iconsPath}lock.png';
  static const String secureIcon = '${iconsPath}secure.png';
  static const String mailIcon = '${iconsPath}mail.png';
  static const String reportIcon = '${iconsPath}report.png';
  static const String fileStarIcon = '${iconsPath}file_star.png';
  static const String exitIcon = '${iconsPath}exit.png';
  static const String plusIcon = '${iconsPath}plus.png';

  // Staff Management Icons
  static const String barberIcon = '${iconsPath}barber.svg';
  static const String chartIcon = '${iconsPath}chart.svg';
  static const String reportIconSvg = '${iconsPath}report.svg';
  static const String branchIcon = '${iconsPath}branch.svg';
  static const String staffIcon = '${iconsPath}staff.svg';
  static const String payrollIcon = '${iconsPath}payroll.svg';
  static const String attendanceIcon = '${iconsPath}attendance.svg';

  // Animation Paths
  static const String loadingAnimation = '${animationsPath}loading.json';
  static const String successAnimation = '${animationsPath}success.json';
  static const String errorAnimation = '${animationsPath}error.json';
  static const String emptyAnimation = '${animationsPath}empty.json';

  // API Endpoint Paths
  static const String apiBase = '/api/v1';

  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';
  static const String logout = '$apiBase/auth/logout';
  static const String refreshToken = '$apiBase/auth/refresh';
  static const String forgotPassword = '$apiBase/auth/forgot-password';
  static const String resetPassword = '$apiBase/auth/reset-password';
  static const String verifyOtp = '$apiBase/auth/verify-otp';

  static const String userProfile = '$apiBase/user/profile';
  static const String updateProfile = '$apiBase/user/update';
  static const String changePassword = '$apiBase/user/change-password';

  static const String shops = '$apiBase/shops';
  static String shopById(String id) => '$shops/$id';
  static String shopServices(String shopId) => '$shops/$shopId/services';
  static String shopGallery(String shopId) => '$shops/$shopId/gallery';
  static String shopReviews(String shopId) => '$shops/$shopId/reviews';

  static const String appointments = '$apiBase/appointments';
  static String appointmentById(String id) => '$appointments/$id';
  static String cancelAppointment(String id) => '$appointments/$id/cancel';
  static String rescheduleAppointment(String id) => '$appointments/$id/reschedule';

  static const String payments = '$apiBase/payments';
  static String paymentStatus(String id) => '$payments/$id/status';

  static const String inventory = '$apiBase/inventory';
  static String inventoryItem(String id) => '$inventory/$id';

  static const String reports = '$apiBase/reports';
  static const String analytics = '$apiBase/analytics';

  // Local Storage Paths
  static const String appDocumentsDir = 'na3eeman';
  static const String cacheDir = 'cache';
  static const String tempDir = 'temp';
  static const String backupDir = 'backup';

  // Route Paths
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String shopDetailsRoute = '/shop-details';
  static const String appointmentBookingRoute = '/appointment-booking';
  static const String paymentRoute = '/payment';
  static const String orderHistoryRoute = '/order-history';
  static const String favoritesRoute = '/favorites';
}

// Helper extensions for path operations
extension PathExtensions on String {
  String get asImagePath => '${AppPaths.imagesPath}$this';
  String get asIconPath => '${AppPaths.iconsPath}$this';
  String get asAnimationPath => '${AppPaths.animationsPath}$this';
}
