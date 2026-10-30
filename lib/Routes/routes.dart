import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/ui/navigation_service.dart';

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
import '../Packages/features/Navigations/faq_page.dart';

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
import '../Packages/features/Navigations/favorites_list_page.dart';
import '../Packages/features/Navigations/history_page.dart';
import '../Packages/features/Navigations/logout.dart';
import '../Packages/features/Navigations/reports_list_page.dart';
import '../Packages/features/Navigations/settings.dart';

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
// import '../Packages/features/onboarding/pages/loading_page.dart';
import '../Packages/features/subscription/pages/subscription_upgrade.dart';
import '../Packages/features/disputes/pages/dispute_resolution.dart';
import '../Providers/features/auth_provider.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // ── Entry ─────────────────────────────────────────────────────────────
    // '/loading': (context) => const LoadingPage(), // Commented out custom loading page
    '/': (context) => const DefaultLoadingPage(),
    '/onboarding': (context) => const OnboardingPage(),
    '/login': (context) => LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/forgot-password': (context) => const ForgotPasswordPage(),
    '/otp-verification': (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return OtpVerificationPage(email: email);
    },
    '/reset-password': (context) {
      final token = ModalRoute.of(context)!.settings.arguments as String;
      return ResetPasswordPage(resetToken: token);
    },

    // ── Customer ──────────────────────────────────────────────────────────
    '/customer_home': (context) => const CustomerHomePage(),
    '/category_details': (context) {
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
    '/category_selection': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
          {};
      final giftMode = args['giftMode'] as bool? ?? false;
      final giftGender = args['giftGender'] as String?;
      return CategorySelectionPage(giftMode: giftMode, giftGender: giftGender);
    },
    '/salons': (context) => const SalonListPage(),
    '/salon_details': (context) {
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
    '/book_appointment': (context) => const BookAppointmentPage(),
    '/appointments': (context) => const AppointmentsPage(),
    '/history': (context) => const HistoryPage(),
    '/favorites': (context) => const FavoritesPage(),
    '/profile': (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.isStaffMember == true) {
        return const StaffProfilePage();
      }
      return const ProfilePage();
    },
    '/user_profile': (context) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user?.isStaffMember == true) {
        return const StaffProfilePage();
      }
      return const ProfilePage();
    },
    '/settings': (context) => const SettingsPage(),
    '/faq': (context) => const FAQPage(),
    '/staff_schedules': (context) => const StaffSchedulesPage(),

    // ── Staff & Management ────────────────────────────────────────────────
    '/expert_home': (context) => const ExpertDashboard(),
    '/expert_dashboard': (context) => const ExpertDashboard(),
    '/my_times': (context) => const MyTimesPage(),
    '/receptionist_dashboard': (context) => const ReceptionistDashboard(),
    '/intern_dashboard': (context) => const InternDashboard(),
    '/intern_activity': (context) => const InternActivityPage(),
    // ── New tier-aware owner dashboard ──────────────────────────────────────
    '/owner_dashboard': (context) => const OwnerDashboardPage(),
    '/management_dashboard': (context) => const OwnerManagementDashboardPage(),
    '/management/revenue': (context) => const RevenueControlsPage(),
    '/management/vouchers': (context) => const VoucherManagementPage(),
    '/management/salon': (context) => const SalonManagementPage(),
    '/management/inventory': (context) => const ReceptionistInventoryPage(),
    '/management/products': (context) => const ReceptionistProductsPage(),
    '/active_campaigns': (context) => const CampaignManagementPage(),
    '/feedback_page': (context) => const FeedbackPage(),
    // Legacy alias — kept for backward compat while migrating references
    '/salon_owner_dashboard': (context) => const SalonOwnerDashboard(),
    '/staff': (context) => const StaffManagementPage(),
    '/management/intern-attendance': (context) =>
        const InternAttendanceReportPage(),

    // ── Legacy Admin (placeholder) ────────────────────────────────────────
    '/admin_home': (context) => const AdminHomePage(),

    // ── Super Admin Dashboard (God Mode) ─────────────────────────────────
    '/admin': (context) => const AdminDashboardPage(),
    '/admin/users': (context) => const AdminUserManagementPage(),
    '/admin/finance': (context) => const AdminFinancialReportsPage(),
    '/admin/analytics': (context) => const AdminUserAnalyticsPage(),
    '/admin/compliance': (context) => const AdminCompliancePage(),
    '/admin/system': (context) => const AdminSystemHealthPage(),
    '/admin/errors': (context) => const AdminErrorReportsPage(),
    '/admin/subs': (context) => const AdminSubscriptionManagementPage(),
    '/admin/create-staff': (context) => const AdminCreateStaffPage(),
    '/admin/service-requests': (context) => const AdminServiceRequestsPage(),
    '/admin/feedback-review': (context) => const FeedbackReviewPage(),

    // ── Shared / Utility ──────────────────────────────────────────────────
    '/report': (context) => const ReportsPage(),
    '/logout': (context) => const LogoutPage(),

    // ── NEW Missing Pages ─────────────────────────────────────────────────
    '/subscription/upgrade': (context) => const SubscriptionUpgradePage(),
    '/disputes': (context) => const DisputeResolutionPage(),

    // ── Competitive Parity — Customer ─────────────────────────────────────
    '/loyalty/history': (context) => const LoyaltyHistoryPage(),
    '/loyalty/referral': (context) => const ReferralCardPage(),
    '/gift-card': (context) => const GiftCardPage(),

    // ── Competitive Parity — Staff / Owner ────────────────────────────────
    '/pos': (context) => const PosTerminalPage(),
    '/management/offers': (context) => const OffersManagementPage(),
    '/management/analytics': (context) => const AnalyticsDashboardPage(),
    '/management/expenses': (context) => const ExpensesPage(),
    '/management/payroll': (context) => const PayrollPage(),
    '/appointments/search': (context) => const AppointmentSearchPage(),
    '/management/data': (context) => const DataManagementPage(),
  };
}

class DefaultLoadingPage extends StatefulWidget {
  const DefaultLoadingPage({super.key});

  @override
  State<DefaultLoadingPage> createState() => _DefaultLoadingPageState();
}

class _DefaultLoadingPageState extends State<DefaultLoadingPage> {
  @override
  void initState() {
    super.initState();
    _loadAppStatus();
  }

  Future<void> _loadAppStatus() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load auth details from storage (loads token and restores session)
    await authProvider.loadSavedAuth();
    
    if (!mounted) return;

    final bool isLoggedIn = authProvider.isAuthenticated;

    if (isLoggedIn) {
      final userRole = authProvider.userType?.name ?? 'customer';
      final user = authProvider.user;
      final String? tier = user?.subscriptionTier?.name.toUpperCase();

      NavigationService.navigateToHomeBasedOnRole(
        context,
        userRole,
        tier: tier,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
