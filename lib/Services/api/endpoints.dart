// lib/Services/api/endpoints.dart
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String validateResetToken = '/auth/validate-reset-token';
  static const String sendResetOtp = '/auth/send-reset-otp';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String changePassword = '/auth/change-password';
  static const String socialLogin = '/auth/social-login';
  static const String profile = '/auth/profile';
  static const String currentUser = '/auth/me';

  // Analytics endpoints
  static const String analyticsEvents = '/analytics/events';

  // Shop endpoints
  static const String shops = '/shops';
  static const String shopSearch = '/shops/search';
  static const String shopDetails = '/shops/{id}';
  static const String shopServices = '/shops/{id}/services';
  static const String shopReviews = '/shops/{id}/reviews';
  static const String shopSchedule = '/shops/{id}/schedule';
  static const String favoriteShops = '/shops/favorites';
  static const String nearbyShops = '/shops/nearby';

  // Appointment endpoints
  static const String appointments = '/appointments';
  static const String appointmentBook = '/appointments/book';
  static const String appointmentDetails = '/appointments/{id}';
  static const String appointmentCancel = '/appointments/{id}/cancel';
  static const String appointmentReschedule = '/appointments/{id}/reschedule';
  static const String appointmentConfirmCash = '/appointments/{id}/confirm-cash-payment';
  static const String userAppointments = '/appointments/user';
  static const String soonestAppointment = '/appointments/soonest';
  static const String freeAppointment = '/appointments/free';

  // Booking group endpoints
  static const String bookingGroups = '/booking-groups';
  static const String bookingGroupDetails = '/booking-groups/{id}';

  // Staff endpoints
  static const String staff = '/staff';
  static const String staffDetails = '/staff/{id}';
  static const String staffPerformance = '/staff/{id}/performance';
  static const String staffWorkingHours = '/staff/working-hours';
  static const String startWorkingHours = '/staff/working-hours/start';
  static const String endWorkingHours = '/staff/working-hours/end';
  static const String staffAttendance = '/staff/attendance';
  static const String staffPayroll = '/staff/payroll';
  static const String assignManager = '/branches/{id}/manager';

  // Loyalty endpoints
  static const String loyaltyBalance = '/loyalty/balance';
  static const String loyaltyProgram = '/loyalty/program';
  static const String awardPoints = '/loyalty/award-points';
  static const String incrementCounter = '/loyalty/increment-counter';
  static const String redeemFreeHaircut = '/loyalty/redeem-free-haircut';
  static const String awardFreeHaircut = '/loyalty/award-free-haircut';
  static const String checkAndAward = '/loyalty/check-and-award';
  static const String pointTransactions = '/loyalty/transactions';

  // Payment endpoints
  static const String paymentMethods = '/payment/methods';
  static const String processPayment = '/payment/process';
  static const String paymentHistory = '/payment/history';
  static const String confirmCashPayment = '/payments/confirm-cash';
  static const String createPaymentIntent = '/payments/create-intent';
  static const String refundPayment = '/payments/{id}/refund';

  // Inventory endpoints
  static const String inventory = '/inventory';
  static const String inventoryItem = '/inventory/{id}';
  static const String lowStock = '/inventory/low-stock';
  static const String inventoryAlerts = '/inventory/alerts';
  static const String updateQuantity = '/inventory/{id}/quantity';

  // Product endpoints
  static const String products = '/products';
  static const String productDetails = '/products/{id}';

  // Option endpoints (services)
  static const String options = '/options';
  static const String optionDetails = '/options/{id}';

  // Package endpoints
  static const String packages = '/packages';
  static const String packageDetails = '/packages/{id}';

  // Subscription endpoints
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionTiers = '/subscription/tiers';
  static const String subscribe = '/subscription/subscribe';
  static const String cancelSubscription = '/subscription/cancel';
  static const String updateSubscription = '/subscription/update';
  static const String reactivateSubscription = '/subscription/reactivate';
  static const String subscriptionInvoices = '/subscription/invoices';
  static const String applyCoupon = '/subscription/apply-coupon';
  static const String subscriptionUsage = '/subscription/usage';

  // Review endpoints
  static const String reviews = '/reviews';
  static const String reviewDetails = '/reviews/{id}';
  static const String shopReviewStats = '/shops/{id}/review-stats';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String userPreferences = '/users/preferences';
  static const String userLoyalty = '/users/loyalty';
  static const String userTransactions = '/users/transactions';

  // File upload endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';

  // Report endpoints
  static const String reportsProfit = '/reports/profit';
  static const String reportsEarnings = '/reports/earnings';
  static const String reportsStaff = '/reports/staff';
  static const String reportsAppointments = '/reports/appointments';
  static const String reportsInventory = '/reports/inventory';

  // Build URL with parameters
  static String buildUrl(String endpoint, {Map<String, String>? params}) {
    String url = endpoint;

    if (params != null) {
      params.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }

    return url;
  }

  // Helper methods for common endpoints
  static String getShopDetailsUrl(int shopId) {
    return buildUrl(shopDetails, params: {'id': shopId.toString()});
  }

  static String getAppointmentDetailsUrl(String appointmentId) {
    return buildUrl(appointmentDetails, params: {'id': appointmentId});
  }

  static String getStaffPerformanceUrl(String staffId) {
    return buildUrl(staffPerformance, params: {'id': staffId});
  }

  static String getShopReviewsUrl(int shopId) {
    return buildUrl(shopReviews, params: {'id': shopId.toString()});
  }

  static String getShopReviewStatsUrl(int shopId) {
    return buildUrl(shopReviewStats, params: {'id': shopId.toString()});
  }
}
