import 'package:flutter/material.dart';

// Auth
import '../Packages/features/auth/pages/forgot_password.dart';
import '../Packages/features/auth/pages/otp_verification_page.dart';
import '../Packages/features/auth/pages/login.dart';
import '../Packages/features/auth/pages/reset_password.dart';
import '../Packages/features/auth/pages/signup.dart';

// Home
import '../Packages/features/home/pages/admin_home.dart';
import '../Packages/features/home/pages/customer_home.dart';

// Staff
import '../Packages/features/staff/pages/employee_dashboard.dart';
import '../Packages/features/staff/pages/receptionist_dashboard.dart';
import '../Packages/features/staff/pages/intern_dashboard.dart';
import '../Packages/features/shop/pages/shop_owner_dashboard.dart';
import '../Packages/features/staff/pages/employee_schedule_page.dart'; // Added

import '../Packages/features/owner/dashboard/pages/owner_dashboard_page.dart';
import '../Packages/features/owner/dashboard/pages/owner_management_dashboard_page.dart';
import '../Packages/features/owner/dashboard/pages/campaign_management_page.dart';
import '../Packages/features/staff/pages/intern_activity_page.dart';

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

// Shop
import '../Packages/features/shop/pages/shop_details.dart';
import '../Packages/features/shop/pages/shops.dart';
import '../Packages/features/shop/widgets/staff_management_page.dart';

// ── NEW: Super Admin Dashboard ──
import '../Packages/features/admin/pages/admin_dashboard.dart';
import '../Packages/features/admin/pages/admin_user_management.dart';
import '../Packages/features/admin/pages/admin_financial_reports.dart';
import '../Packages/features/admin/pages/user_analytics_page.dart';
import '../Packages/features/admin/pages/system_health_page.dart';
import '../Packages/features/admin/pages/error_reports_page.dart';
import '../Packages/features/admin/pages/subscription_management_page.dart';
import '../Packages/features/admin/pages/admin_compliance.dart';

// ── NEW: Missing Pages ──
import '../Packages/features/onboarding/pages/onboarding.dart';
import '../Packages/features/onboarding/pages/loading_page.dart';
import '../Packages/features/subscription/pages/subscription_upgrade.dart';
import '../Packages/features/disputes/pages/dispute_resolution.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    // ── Entry ─────────────────────────────────────────────────────────────
    '/': (context) => const LoadingPage(),
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
    '/shops': (context) => const ShopListPage(),
    '/shop_details': (context) {
      final shopData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ShopDetailsPage(shopData: shopData);
    },
    '/book_appointment': (context) => const BookAppointmentPage(),
    '/appointments': (context) => const AppointmentsPage(),
    '/history': (context) => const HistoryPage(),
    '/favorites': (context) => const FavoritesPage(),
    '/profile': (context) => const ProfilePage(),
    '/settings': (context) => const SettingsPage(),

    // ── Staff & Management ────────────────────────────────────────────────
    '/employee_dashboard': (context) => const EmployeeDashboard(),
    '/employee_schedule': (context) => const EmployeeSchedulePage(),
    '/receptionist_dashboard': (context) => const ReceptionistDashboard(),
    '/intern_dashboard': (context) => const InternDashboard(),
    '/intern_activity': (context) => const InternActivityPage(),
    // ── New tier-aware owner dashboard ──────────────────────────────────────
    '/owner_dashboard': (context) => const OwnerDashboardPage(),
    '/management_dashboard': (context) => const OwnerManagementDashboardPage(),
    '/active_campaigns': (context) => const CampaignManagementPage(),
    // Legacy alias — kept for backward compat while migrating references
    '/shop_owner_dashboard': (context) => const ShopOwnerDashboard(),
    '/staff': (context) => const StaffManagementPage(),

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

    // ── Shared / Utility ──────────────────────────────────────────────────
    '/report': (context) => const ReportsPage(),
    '/logout': (context) => const LogoutPage(),

    // ── NEW Missing Pages ─────────────────────────────────────────────────
    '/subscription/upgrade': (context) => const SubscriptionUpgradePage(),
    '/disputes': (context) => const DisputeResolutionPage(),
  };
}
