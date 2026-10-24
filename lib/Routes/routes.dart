import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Auth
import '../Packages/features/auth/pages/forgot_password.dart';
import '../Packages/features/auth/pages/otp_verification_page.dart';
import '../Packages/features/auth/pages/login.dart';
import '../Packages/features/auth/pages/reset_password.dart';
import '../Packages/features/auth/pages/signup.dart';

// Home
import '../Packages/features/home/pages/admin_home.dart';
import '../Packages/features/home/pages/customer_home.dart';
import '../Packages/features/home/pages/category_details.dart';
import '../Packages/features/home/pages/category_selection_page.dart';
import '../Models/salon/category_model.dart';

// Staff
import '../Packages/features/staff/pages/expert_dashboard.dart';
import '../Packages/features/staff/pages/receptionist_dashboard.dart';
import '../Packages/features/staff/pages/intern_dashboard.dart';
import '../Packages/features/salon/pages/salon_owner_dashboard.dart';
import '../Packages/features/staff/pages/my_times_page.dart';
import '../Packages/features/staff/pages/staff_profile_page.dart';
import '../Packages/features/staff/pages/staff_schedules_page.dart';
import '../Packages/features/navigation/pages/faq_page.dart';

import 'package:na3eeman/Packages/features/owner/dashboard/pages/owner_dashboard_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/owner_management_dashboard_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/campaign_management_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/feedback_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/revenue_controls_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/voucher_management_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/salon_management_page.dart';
import 'package:na3eeman/Packages/features/staff/pages/receptionist/receptionist_inventory_page.dart';
import 'package:na3eeman/Packages/features/staff/pages/receptionist/receptionist_products_page.dart';
import 'package:na3eeman/Packages/features/staff/pages/receptionist/appointment_search_page.dart';
import '../Packages/features/staff/pages/intern_activity_page.dart';
import '../Packages/features/staff/pages/intern_attendance_report_page.dart';

// Navigations
import '../Packages/features/navigation/pages/favorites_list_page.dart';
import '../Packages/features/navigation/pages/history_page.dart';
import '../Packages/features/navigation/pages/logout.dart';
import '../Packages/features/navigation/pages/reports_list_page.dart';
import '../Packages/features/navigation/pages/settings.dart';

// Appointments
import '../Packages/features/appointments/pages/appointments_page.dart';
import '../Packages/features/appointments/pages/book_appointment_page.dart';

// Profile
import '../Packages/features/profile/pages/profile_page.dart';
import '../Packages/features/profile/pages/loyalty_history_page.dart';
import '../Packages/features/profile/pages/referral_card_page.dart';
import '../Packages/features/profile/pages/gift_card_page.dart';

// POS + Offers + Analytics (new competitive parity)
import '../Packages/features/staff/pages/receptionist/pos_terminal_page.dart';
import '../Packages/features/owner/dashboard/pages/offers_management_page.dart';
import '../Packages/features/owner/dashboard/pages/analytics_dashboard_page.dart';
import '../Packages/features/owner/dashboard/pages/expenses_page.dart';
import '../Packages/features/owner/dashboard/pages/payroll_page.dart';
import '../Packages/features/owner/dashboard/pages/data_management_page.dart';

// Salon
import '../Packages/features/salon/pages/salon_details.dart';
import '../Packages/features/salon/pages/salons.dart';
import '../Packages/features/salon/widgets/staff_management_page.dart';

// ── NEW: Super Admin Dashboard ──
import '../Packages/features/admin/pages/admin_dashboard.dart';
import '../Packages/features/admin/pages/admin_user_management.dart';
import '../Packages/features/admin/pages/admin_financial_reports.dart';
import '../Packages/features/admin/pages/user_analytics_page.dart';
import '../Packages/features/admin/pages/system_health_page.dart';
import '../Packages/features/admin/pages/error_reports_page.dart';
import '../Packages/features/admin/pages/subscription_management_page.dart';
import '../Packages/features/admin/pages/admin_compliance.dart';
import '../Packages/features/admin/pages/admin_create_staff_page.dart';
import '../Packages/features/admin/pages/admin_service_requests_page.dart';
import '../Packages/features/admin/pages/feedback_review_page.dart';

// ── NEW: Missing Pages ──
import '../Packages/features/onboarding/pages/onboarding.dart';
import '../Packages/features/onboarding/pages/loading_page.dart';
import '../Packages/features/subscription/pages/subscription_upgrade.dart';
import '../Packages/features/disputes/pages/dispute_resolution.dart';
import '../Providers/features/auth_provider.dart';

import 'route_names.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // ── Entry ─────────────────────────────────────────────────────────────
    RouteNames.root: (context) => const LoadingPage(),
    RouteNames.onboarding: (context) => const OnboardingPage(),
    RouteNames.login: (context) => LoginPage(),
    RouteNames.signup: (context) => const SignupPage(),
    RouteNames.forgotPassword: (context) => const ForgotPasswordPage(),
    RouteNames.otpVerification: (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return OtpVerificationPage(email: email);
    },
    RouteNames.resetPassword: (context) {
      final token = ModalRoute.of(context)!.settings.arguments as String;
      return ResetPasswordPage(resetToken: token);
    },

    // ── Customer ──────────────────────────────────────────────────────────
    RouteNames.customerHome: (context) => const CustomerHomePage(),
    RouteNames.categoryDetails: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final category = args['category'] as Category;
      final giftMode = args['giftMode'] as bool? ?? false;
      final giftGender = args['giftGender'] as String?;
      final subQuery = args['subQuery'] as String?;
      return CategoryDetailsPage(
        category: category,
        giftMode: giftMode,
        giftGender: giftGender,
        subQuery: subQuery,
      );
    },
    RouteNames.categorySelection: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
          {};
      final giftMode = args['giftMode'] as bool? ?? false;
      final giftGender = args['giftGender'] as String?;
      return CategorySelectionPage(giftMode: giftMode, giftGender: giftGender);
    },
    RouteNames.salons: (context) => const SalonListPage(),
    RouteNames.salonDetails: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final salonData = args['salonData'] as Map<String, dynamic>;
      final giftMode = args['giftMode'] as bool? ?? false;
      final giftGender = args['giftGender'] as String?;
      return SalonDetailsPage(
        salonData: salonData,
        giftMode: giftMode,
        giftGender: giftGender,
      );
    },
    RouteNames.bookAppointment: (context) => const BookAppointmentPage(),
    RouteNames.appointments: (context) => const AppointmentsPage(),
    RouteNames.history: (context) => const HistoryPage(),
    RouteNames.favorites: (context) => const FavoritesPage(),
    RouteNames.profile: (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.isStaffMember == true) {
        return const StaffProfilePage();
      }
      return const ProfilePage();
    },
    // Legacy alias of RouteNames.profile — same builder, kept working for
    // existing references.
    RouteNames.userProfile: (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.isStaffMember == true) {
        return const StaffProfilePage();
      }
      return const ProfilePage();
    },
    RouteNames.settings: (context) => const SettingsPage(),
    RouteNames.faq: (context) => const FAQPage(),
    RouteNames.staffSchedules: (context) => const StaffSchedulesPage(),

    // ── Staff & Management ────────────────────────────────────────────────
    // Legacy alias of RouteNames.expertDashboard — same page, kept working
    // for existing references (stored prefs, deep links).
    RouteNames.expertHome: (context) => const ExpertDashboard(),
    RouteNames.expertDashboard: (context) => const ExpertDashboard(),
    RouteNames.myTimes: (context) => const MyTimesPage(),
    RouteNames.receptionistDashboard: (context) =>
        const ReceptionistDashboard(),
    RouteNames.internDashboard: (context) => const InternDashboard(),
    RouteNames.internActivity: (context) => const InternActivityPage(),
    // ── New tier-aware owner dashboard ──────────────────────────────────────
    RouteNames.ownerDashboard: (context) => const OwnerDashboardPage(),
    RouteNames.managementDashboard: (context) =>
        const OwnerManagementDashboardPage(),
    RouteNames.managementRevenue: (context) => const RevenueControlsPage(),
    RouteNames.managementVouchers: (context) => const VoucherManagementPage(),
    RouteNames.managementSalon: (context) => const SalonManagementPage(),
    RouteNames.managementInventory: (context) =>
        const ReceptionistInventoryPage(),
    RouteNames.managementProducts: (context) =>
        const ReceptionistProductsPage(),
    RouteNames.activeCampaigns: (context) => const CampaignManagementPage(),
    RouteNames.feedbackPage: (context) => const FeedbackPage(),
    // Legacy alias of the owner dashboard — kept for backward compat while
    // migrating references
    RouteNames.salonOwnerDashboard: (context) => const SalonOwnerDashboard(),
    RouteNames.staff: (context) => const StaffManagementPage(),
    RouteNames.managementInternAttendance: (context) =>
        const InternAttendanceReportPage(),

    // ── Admin ─────────────────────────────────────────────────────────────
    // Legacy alias of RouteNames.admin (placeholder page) — kept working
    // for existing references.
    RouteNames.adminHome: (context) => const AdminHomePage(),

    // ── Super Admin Dashboard (God Mode) ─────────────────────────────────
    RouteNames.admin: (context) => const AdminDashboardPage(),
    RouteNames.adminUsers: (context) => const AdminUserManagementPage(),
    RouteNames.adminFinance: (context) => const AdminFinancialReportsPage(),
    RouteNames.adminAnalytics: (context) => const AdminUserAnalyticsPage(),
    RouteNames.adminCompliance: (context) => const AdminCompliancePage(),
    RouteNames.adminSystem: (context) => const AdminSystemHealthPage(),
    RouteNames.adminErrors: (context) => const AdminErrorReportsPage(),
    RouteNames.adminSubs: (context) => const AdminSubscriptionManagementPage(),
    RouteNames.adminCreateStaff: (context) => const AdminCreateStaffPage(),
    RouteNames.adminServiceRequests: (context) =>
        const AdminServiceRequestsPage(),
    RouteNames.adminFeedbackReview: (context) => const FeedbackReviewPage(),

    // ── Shared / Utility ──────────────────────────────────────────────────
    RouteNames.report: (context) => const ReportsPage(),
    RouteNames.logout: (context) => const LogoutPage(),

    // ── NEW Missing Pages ─────────────────────────────────────────────────
    RouteNames.subscriptionUpgrade: (context) =>
        const SubscriptionUpgradePage(),
    RouteNames.disputes: (context) => const DisputeResolutionPage(),

    // ── Competitive Parity — Customer ─────────────────────────────────────
    RouteNames.loyaltyHistory: (context) => const LoyaltyHistoryPage(),
    RouteNames.loyaltyReferral: (context) => const ReferralCardPage(),
    RouteNames.giftCard: (context) => const GiftCardPage(),

    // ── Competitive Parity — Staff / Owner ────────────────────────────────
    RouteNames.pos: (context) => const PosTerminalPage(),
    RouteNames.managementOffers: (context) => const OffersManagementPage(),
    RouteNames.managementAnalytics: (context) => const AnalyticsDashboardPage(),
    RouteNames.managementExpenses: (context) => const ExpensesPage(),
    RouteNames.managementPayroll: (context) => const PayrollPage(),
    RouteNames.appointmentsSearch: (context) => const AppointmentSearchPage(),
    RouteNames.managementData: (context) => const DataManagementPage(),
  };
}
