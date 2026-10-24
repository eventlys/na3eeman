/// Canonical route-name constants for [AppRoutes.routes].
///
/// Every key in the route table has a matching constant here. Prefer these
/// over string literals when calling `Navigator.pushNamed` and friends so
/// typos surface at compile time and renames stay mechanical.
class RouteNames {
  RouteNames._();

  // ── Entry ─────────────────────────────────────────────────────────────
  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';

  // ── Customer ──────────────────────────────────────────────────────────
  static const String customerHome = '/customer_home';
  static const String categoryDetails = '/category_details';
  static const String categorySelection = '/category_selection';
  static const String salons = '/salons';
  static const String salonDetails = '/salon_details';
  static const String bookAppointment = '/book_appointment';
  static const String appointments = '/appointments';
  static const String history = '/history';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  /// Legacy alias of [profile] — kept working for existing references.
  static const String userProfile = '/user_profile';
  static const String settings = '/settings';
  static const String faq = '/faq';
  static const String staffSchedules = '/staff_schedules';

  // ── Staff & Management ────────────────────────────────────────────────
  /// Legacy alias of [expertDashboard] — kept working for existing
  /// references (stored preferences, deep links).
  static const String expertHome = '/expert_home';
  static const String expertDashboard = '/expert_dashboard';
  static const String myTimes = '/my_times';
  static const String receptionistDashboard = '/receptionist_dashboard';
  static const String internDashboard = '/intern_dashboard';
  static const String internActivity = '/intern_activity';
  static const String ownerDashboard = '/owner_dashboard';
  static const String managementDashboard = '/management_dashboard';
  static const String managementRevenue = '/management/revenue';
  static const String managementVouchers = '/management/vouchers';
  static const String managementSalon = '/management/salon';
  static const String managementInventory = '/management/inventory';
  static const String managementProducts = '/management/products';
  static const String activeCampaigns = '/active_campaigns';
  static const String feedbackPage = '/feedback_page';

  /// Legacy alias of the salon owner dashboard — kept for backward compat.
  static const String salonOwnerDashboard = '/salon_owner_dashboard';
  static const String staff = '/staff';
  static const String managementInternAttendance =
      '/management/intern-attendance';

  // ── Admin ─────────────────────────────────────────────────────────────
  /// Legacy alias of [admin] (placeholder page) — kept working for
  /// existing references.
  static const String adminHome = '/admin_home';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminFinance = '/admin/finance';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminCompliance = '/admin/compliance';
  static const String adminSystem = '/admin/system';
  static const String adminErrors = '/admin/errors';
  static const String adminSubs = '/admin/subs';
  static const String adminCreateStaff = '/admin/create-staff';
  static const String adminServiceRequests = '/admin/service-requests';
  static const String adminFeedbackReview = '/admin/feedback-review';

  // ── Shared / Utility ──────────────────────────────────────────────────
  static const String report = '/report';
  static const String logout = '/logout';
  static const String subscriptionUpgrade = '/subscription/upgrade';
  static const String disputes = '/disputes';

  // ── Competitive Parity — Customer ─────────────────────────────────────
  static const String loyaltyHistory = '/loyalty/history';
  static const String loyaltyReferral = '/loyalty/referral';
  static const String giftCard = '/gift-card';

  // ── Competitive Parity — Staff / Owner ────────────────────────────────
  static const String pos = '/pos';
  static const String managementOffers = '/management/offers';
  static const String managementAnalytics = '/management/analytics';
  static const String managementExpenses = '/management/expenses';
  static const String managementPayroll = '/management/payroll';
  static const String appointmentsSearch = '/appointments/search';
  static const String managementData = '/management/data';
}
