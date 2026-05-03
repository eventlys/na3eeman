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
  static const String profileExpert = '/auth/profile/expert/';  // Changed from expert/expert
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
  static const String usersExperts = '/auth/users/experts/';
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
  static const String adminUserRequests = '/auth/admin/requests/';

  // ==================== SUBSCRIPTIONS ====================
  static const String subscriptionPlans = '/salons/subscription-plans/';
  // ==================== INTERN MANAGEMENT ====================
  static const String internTasks = '/auth/intern/tasks/';
  static String internTaskDetail(int id) => '/auth/intern/tasks/$id/';
  static const String internAttach = '/auth/intern/attach/';
  static const String internActivity = '/auth/intern/activity/';
  static const String attendanceLog = '/salons/attendance/';

  // ==================== INVITATIONS ====================
  static const String invitationsSend = '/auth/invitations/send/';
  static const String invitationsRegister = '/auth/invitations/register/';

  // ==================== 2FA ====================
  static const String twoFASetup = '/auth/security/2fa/setup/';
  static const String twoFAVerify = '/auth/security/2fa/verify/';

  // ==================== SALONS ====================
  static const String salons = '/salons/salons/';
  static String salonDetails(int id) => '/salons/salons/$id/';
  static const String salonSearch = '/salons/salons/';  // Use query params  
  static const String nearbySalons = '/salons/salons/';  // Use query params with lat/lng
  static const String favoriteSalons = '/salons/salons/';  // Filter by favorites
  static const String categories = '/salons/categories/';
  static const String allOffers = '/salons/all-offers/';
  static const String allCampaigns = '/salons/all-campaigns/';
  
  // Salon nested resources
  static String salonOptions(int salonId) => '/salons/salons/$salonId/options/';
  static String salonPackages(int salonId) => '/salons/salons/$salonId/packages/';
  static String salonProducts(int salonId) => '/salons/salons/$salonId/products/';
  static String salonInventory(int salonId) => '/salons/salons/$salonId/inventory/';
  static String salonExperts(int salonId) => '/salons/salons/$salonId/experts/';
  static String salonReviews(int salonId) => '/salons/salons/$salonId/reviews/';
  static String salonGallery(int salonId) => '/salons/salons/$salonId/gallery/';
  static String salonServices(int salonId) => '/salons/salons/$salonId/options/';  // Same as options
  static String salonSchedule(int salonId) => '/salons/salons/$salonId/schedule/';
  static const String workingHours = '/salons/working-hours/';
  static const String pto = '/salons/pto/';

  // ==================== APPOINTMENTS ====================
  static const String appointments = '/salons/appointments/';
  static String appointmentDetails(int id) => '/salons/appointments/$id/';
  static const String appointmentBook = '/salons/appointments/';  // POST to list endpoint
  static String appointmentCancel(int id) => '/salons/appointments/$id/cancel/';
  static String appointmentReschedule(int id) => '/salons/appointments/$id/reschedule/';
  static String appointmentComplete(int id) => '/salons/appointments/$id/complete/';
  static String appointmentConfirmCashPayment(int id) => '/salons/appointments/$id/confirm_payment/';  // Fixed: backend uses confirm_payment not confirm-cash
  
  // User appointments
  static const String userAppointments = '/salons/appointments/';  // Filter by user
  static const String soonestAppointment = '/salons/appointments/';  // Sort by date, limit 1
  static const String freeAppointment = '/salons/appointments/free/';  // If endpoint exists

  // ==================== REVIEWS ====================
  static const String reviews = '/salons/reviews/';
  static String reviewDetails(int id) => '/salons/reviews/$id/';

  // ==================== SUBSCRIPTIONS ====================
  static const String subscriptions = '/salons/subscriptions/';
  static String subscriptionDetails(int id) => '/salons/subscriptions/$id/';
  static const String platformSubscriptionPlans = '/salons/subscription-plans/';

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
  static const String haircutStyles = '/salons/haircut-styles/';
  static String haircutStyleDetails(int id) => '/salons/haircut-styles/$id/';

  // ==================== LOYALTY ====================
  static const String loyaltyBalance = '/loyalty/balance/';
  static const String loyaltyTransactions = '/loyalty/transactions/';
  static const String loyaltyRedeemFreeCut = '/loyalty/redeem-free-cut/';
  static const String loyaltyAwardPoints = '/loyalty/award-points/';
  static const String loyaltyRules = '/loyalty/rules/';
  static const String loyaltyRedeemPoints = '/loyalty/redeem-points/';
  static const String loyaltyAdminAdjustPoints = '/loyalty/admin-adjust/';
  static const String giftCardList = '/loyalty/gift-cards/';
  static const String giftCardPurchase = '/loyalty/gift-cards/purchase/';
  static const String userGiftCards = '/loyalty/my-gift-cards/';
  static const String feedback = '/loyalty/feedback/';
  static const String adminFeedbackReview = '/loyalty/admin/feedback-review/';

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
  static String salonRetailSnapshot(int salonId) => '/salons/salons/$salonId/retail_snapshot/';
  static String salonTeamLeaderboard(int salonId) => '/salons/salons/$salonId/team_leaderboard/';
  static String salonDailyEarnings(int salonId) => '/salons/salons/$salonId/daily_earnings/';
  static String salonResourceOccupancy(int salonId) => '/salons/salons/$salonId/resource_occupancy/';
  static String salonPaymentConfig(int salonId) => '/salons/salons/$salonId/payment-config/';
  static const String vouchers = '/salons/vouchers/';

  // Notifications
  static const String notifications = '/auth/notifications/';
  static String notificationMarkRead(int id) => '/auth/notifications/$id/mark-read/';
  static const String notificationsMarkAllRead = '/auth/notifications/mark-all-read/';

  // Campaigns
  static String salonOffers(int salonId) => '/salons/salons/$salonId/offers/';
  static String salonAdCampaigns(int salonId) => '/salons/salons/$salonId/campaigns/';

  // ==================== CONTENT ====================
  static const String faqs = '/content/faqs/';
  static String faqDetails(int id) => '/content/faqs/$id/';
  static const String rules = '/content/rules/';
  static String rulesByRole(String role) => '/content/rules/by-role/$role/';
  static const String guides = '/content/guides/';
  static String guidesByRole(String role) => '/content/guides/by-role/$role/';
  static const String privacyPolicy = '/content/privacy-policy/current/';

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
      'page_size': ?pageSize,
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

  /// Get nearby salons URL
  static String getNearbySalonsUrl({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) {
    return buildUrl(salons, {
      'lat': latitude,
      'lng': longitude,
      'radius': ?radiusKm,
    });
  }

  /// Get nearby salons URL with category
  static String getNearbySalonsByCategoryUrl({
    required double latitude,
    required double longitude,
    required int categoryId,
    double? radiusKm,
    bool? forGift,
    String? giftGender,
  }) {
    return buildUrl(salons, {
      'lat': latitude,
      'lng': longitude,
      'category': categoryId,
      'radius': ?radiusKm,
      'for_gift': ?forGift,
      'gift_gender': ?giftGender,
    });
  }

  /// Replace path parameters (e.g., /salons/{id} -> /salons/123)
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
  
  static String get salons => Endpoints.salons;
  static String get salonSearch => Endpoints.salonSearch;
  static String get nearbySalons => Endpoints.nearbySalons;
  
  static String get appointments => Endpoints.appointments;
  static String get appointmentBook => Endpoints.appointmentBook;
  
  // Helper to replace {id} placeholder
  static String salonDetails(int id) => Endpoints.salonDetails(id);
  static String appointmentDetails(int id) => Endpoints.appointmentDetails(id);
}
