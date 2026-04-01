import 'package:na3eeman/Helpers/config.dart';

/// API Endpoints
/// 
/// All endpoints are aligned with the new backend /api/v1/ structure.
/// Base URL from AppConfig already includes /api/v1
class Endpoints {
  // Base URL
  static String get baseUrl => AppConfig.baseUrl;

  // ==================== AUTHENTICATION ====================
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String socialLogin = '/auth/social-login/';
  
  // JWT Tokens
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String tokenVerify = '/auth/token/verify/';

  // Password Management
  static const String passwordReset = '/auth/password/reset/';
  static const String passwordResetConfirm = '/auth/password/reset/confirm/';
  static const String passwordChange = '/auth/password/change/';
  static const String firstLoginPasswordChange = '/auth/password/first-login-change/';

  // ==================== USER PROFILE ====================
  static const String currentUser = '/auth/me/';  // Current user profile (was /auth/profile)
  static const String profile = '/auth/me/';  // Alias for backward compatibility
  static const String profileBarber = '/auth/profile/employee/';  // Fixed: backend uses /employee/ not /barber/
  static const String profileOwner = '/auth/profile/owner/';
  static const String profilePicture = '/auth/profile/picture/';
  static const String profileLocation = '/auth/profile/location/';
  static const String profileDeactivate = '/auth/profile/deactivate/';

  // ==================== SOCIAL AUTH ====================
  static const String socialLink = '/auth/social/link/';
  static const String socialUnlink = '/auth/social/unlink/';
  static const String socialAccounts = '/auth/social/accounts/';

  // ==================== VERIFICATION ====================
  static const String sendEmailVerification = '/auth/verify/email/send/';
  static const String verifyEmail = '/auth/verify/email/confirm/';
  static const String sendPhoneVerification = '/auth/verify/phone/send/';
  static const String verifyPhone = '/auth/verify/phone/confirm/';

  // ==================== AVAILABILITY CHECKS ====================
  static const String checkUsername = '/auth/check/username/';
  static const String checkEmail = '/auth/check/email/';

  // ==================== USER LISTS ====================
  static const String usersBarbers = '/auth/users/barbers/';
  static const String usersOwners = '/auth/users/owners/';
  static const String usersCustomers = '/auth/users/customers/';
  static const String usersStaff = '/auth/users/staff/';

  // ==================== ADMIN ENDPOINTS ====================
  static const String adminCreateStaff = '/auth/admin/create-staff/';
  static String adminResetStaffPassword(int userId) => '/auth/admin/reset-staff-password/$userId/';
  static String adminChangeUserRole(int userId) => '/auth/admin/change-role/$userId/';
  static const String adminUsers = '/auth/admin/users/';
  static String adminUserDetail(int userId) => '/auth/admin/users/$userId/';
  static const String adminUserStats = '/auth/admin/stats/'; 

  // ==================== INTERN MANAGEMENT ====================
  static const String internTasks = '/auth/intern/tasks/';
  static String internTaskDetail(int id) => '/auth/intern/tasks/$id/';
  static const String internTargets = '/auth/intern/targets/';
  static const String internAttach = '/auth/intern/attach/';
  static const String internActivity = '/auth/intern/activity/';

  // ==================== INVITATIONS ====================
  static const String invitationsSend = '/auth/invitations/send/';
  static const String invitationsRegister = '/auth/invitations/register/';

  // ==================== 2FA ====================
  static const String twoFASetup = '/auth/security/2fa/setup/';
  static const String twoFAVerify = '/auth/security/2fa/verify/';

  // ==================== SHOPS ====================
  static const String shops = '/shops/shops/';
  static String shopDetails(int id) => '/shops/shops/$id/';
  static const String shopSearch = '/shops/shops/';  // Use query params  
  static const String nearbyShops = '/shops/shops/';  // Use query params with lat/lng
  static const String favoriteShops = '/shops/shops/';  // Filter by favorites
  
  // Shop nested resources
  static String shopOptions(int shopId) => '/shops/shops/$shopId/options/';
  static String shopPackages(int shopId) => '/shops/shops/$shopId/packages/';
  static String shopProducts(int shopId) => '/shops/shops/$shopId/products/';
  static String shopInventory(int shopId) => '/shops/shops/$shopId/inventory/';
  static String shopBarbers(int shopId) => '/shops/shops/$shopId/barbers/';
  static String shopReviews(int shopId) => '/shops/shops/$shopId/reviews/';
  static String shopSchedule(int shopId) => '/shops/shops/$shopId/schedule/';  // If exists
  static String shopServices(int shopId) => '/shops/shops/$shopId/options/';  // Same as options

  // ==================== APPOINTMENTS ====================
  static const String appointments = '/shops/appointments/';
  static String appointmentDetails(int id) => '/shops/appointments/$id/';
  static const String appointmentBook = '/shops/appointments/';  // POST to list endpoint
  static String appointmentCancel(int id) => '/shops/appointments/$id/cancel/';
  static String appointmentReschedule(int id) => '/shops/appointments/$id/reschedule/';
  static String appointmentComplete(int id) => '/shops/appointments/$id/complete/';
  static String appointmentConfirmCashPayment(int id) => '/shops/appointments/$id/confirm_payment/';  // Fixed: backend uses confirm_payment not confirm-cash
  
  // User appointments
  static const String userAppointments = '/shops/appointments/';  // Filter by user
  static const String soonestAppointment = '/shops/appointments/';  // Sort by date, limit 1
  static const String freeAppointment = '/shops/appointments/free/';  // If endpoint exists

  // ==================== REVIEWS ====================
  static const String reviews = '/shops/reviews/';
  static String reviewDetails(int id) => '/shops/reviews/$id/';

  // ==================== SUBSCRIPTIONS ====================
  static const String subscriptions = '/shops/subscriptions/';
  static String subscriptionDetails(int id) => '/shops/subscriptions/$id/';

  // ==================== OWNER / SUBSCRIPTION MANAGEMENT ====================
  static const String ownerProfile = '/auth/profile/owner/';
  // Note: The following endpoints need to be implemented on the backend in users/views.py
  // static const String ownerSubscription = '/owners/subscription/';
  // static const String ownerSubscriptionUpgrade = '/owners/subscription/upgrade/';
  // static const String ownerSubscriptionCancel = '/owners/subscription/cancel/';
  // static const String ownerSubscriptionRenew = '/owners/subscription/renew/';
  // static const String ownerTrial = '/owners/subscription/trial/';
  // static const String ownerFeatureAccess = '/owners/features/check/';
  // static const String ownerStaffLimit = '/owners/staff/limit/';

  // ==================== HAIRCUT STYLES ====================
  static const String haircutStyles = '/shops/haircut-styles/';
  static String haircutStyleDetails(int id) => '/shops/haircut-styles/$id/';

  // ==================== LOYALTY ====================
  static const String loyaltyBalance = '/loyalty/balance/';
  static const String loyaltyTransactions = '/loyalty/transactions/';  // If exists
  static const String loyaltyRedeemFreeCut = '/loyalty/redeem-free-cut/';
  static const String loyaltyAdminAdjustPoints = '/loyalty/admin/adjust-points/';

  // ==================== PAYMENTS ====================
  // Note: These endpoints may not exist yet in backend
  static const String payments = '/payments/';
  static const String paymentIntent = '/payments/intent/';
  static const String paymentConfirm = '/payments/confirm/';

  // ==================== ANALYTICS ====================
  static const String adminAnalyticsOverview = '/analytics/overview/';
  static const String adminAnalyticsUsers = '/analytics/users/';
  static const String adminAnalyticsUsage = '/analytics/usage/';
  static const String adminAnalyticsFinancial = '/analytics/financial/';
  static const String adminAnalyticsSystem = '/analytics/system/';
  static const String analyticsEvents = '/analytics/events/';
  static String shopRetailSnapshot(int shopId) => '/shops/shops/$shopId/retail_snapshot/';
  static String shopTeamLeaderboard(int shopId) => '/shops/shops/$shopId/team_leaderboard/';
  static String shopDailyEarnings(int shopId) => '/shops/shops/$shopId/daily_earnings/';
  static String shopResourceOccupancy(int shopId) => '/shops/shops/$shopId/resource_occupancy/';
  static String shopEmployees(int shopId) => '/shops/shops/$shopId/employees/';

  // Notifications
  static const String notifications = '/auth/notifications/';
  static String notificationMarkRead(int id) => '/auth/notifications/$id/mark-read/';
  static const String notificationsMarkAllRead = '/auth/notifications/mark-all-read/';

  // Campaigns
  static String shopOffers(int shopId) => '/shops/shops/$shopId/offers/';
  static String shopAdCampaigns(int shopId) => '/shops/shops/$shopId/campaigns/';

  // ==================== UTILITY ====================
  static const String health = '/health/';

  // ==================== HELPER METHODS ====================
  
  /// Build URL with query parameters
  static String buildUrl(String endpoint, Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) {
      return endpoint;
    }

    final cleanParams = Map<String, dynamic>.from(params)
      ..removeWhere((key, value) => value == null || value == '');

    if (cleanParams.isEmpty) return endpoint;

    final queryString = cleanParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint$separator$queryString';
  }

  /// Build full URL with base
  static String fullUrl(String endpoint) {
    // Remove leading slash if base URL already has it
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$cleanBase/$cleanEndpoint';
  }

  /// Get paginated URL
  static String withPagination(String endpoint, {int page = 1, int? pageSize}) {
    return buildUrl(endpoint, {
      'page': page,
      if (pageSize != null) 'page_size': pageSize,
    });
  }

  /// Get search URL
  static String withSearch(String endpoint, String query) {
    return buildUrl(endpoint, {'search': query});
  }

  /// Get filtered URL
  static String withFilters(String endpoint, Map<String, dynamic> filters) {
    return buildUrl(endpoint, filters);
  }

  /// Get nearby shops URL
  static String getNearbyShopsUrl({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) {
    return buildUrl(shops, {
      'lat': latitude,
      'lng': longitude,
      if (radiusKm != null) 'radius': radiusKm,
    });
  }

  /// Replace path parameters (e.g., /shops/{id} -> /shops/123)
  static String replacePathParams(String endpoint, Map<String, dynamic> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}

/// Legacy endpoint mappings for backward compatibility
/// TODO: Remove after full migration
class ApiEndpoints {
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String refresh = '/auth/token/refresh/';
  static const String currentUser = '/auth/me/';
  static const String profile = '/auth/me/';
  
  // Map old endpoint names to new ones
  static String get forgotPassword => Endpoints.passwordReset;
  static String get resetPassword => Endpoints.passwordResetConfirm;
  static String get changePassword => Endpoints.passwordChange;
  static String get socialLogin => Endpoints.socialLogin;
  
  static String get shops => Endpoints.shops;
  static String get shopSearch => Endpoints.shopSearch;
  static String get nearbyShops => Endpoints.nearbyShops;
  
  static String get appointments => Endpoints.appointments;
  static String get appointmentBook => Endpoints.appointmentBook;
  
  // Helper to replace {id} placeholder
  static String shopDetails(int id) => Endpoints.shopDetails(id);
  static String appointmentDetails(int id) => Endpoints.appointmentDetails(id);
}
