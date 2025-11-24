import 'package:flutter/material.dart';
import '../Packages/features/Navigations/favorites_list_page.dart';
import '../Packages/features/Navigations/history_page.dart';
import '../Packages/features/Navigations/logout.dart';
import '../Packages/features/Navigations/reports_list_page.dart';
import '../Packages/features/Navigations/settings.dart';
import '../Packages/features/appointments/pages/appointments_page.dart';
import '../Packages/features/auth/pages/forgot_password.dart';
import '../Packages/features/auth/pages/otp_verification_page.dart';
import '../Packages/features/auth/pages/login.dart';
import '../Packages/features/auth/pages/reset_password.dart';
import '../Packages/features/auth/pages/signup.dart';
import '../Packages/features/home/pages/barber_home.dart';
import '../Packages/features/home/pages/admin_home.dart';
import '../Packages/features/cart_commented/pages/cart_page.dart';
import '../Packages/features/home/pages/customer_home.dart';
import '../Packages/features/profile/pages/profile_page.dart';
import '../Packages/features/shop/pages/shop_owner_dashboard.dart';
import '../Packages/features/shop/pages/shops.dart';
import '../Packages/features/shop/widgets/staff_management_page.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => LoginPage(),
    '/login': (context) => LoginPage(),
    '/signup': (context) => const SignupPage(),
    '/customer_home': (context) => const CustomerHomePage(),
    '/barber_home': (context) => const BarberHomePage(),
    // '/owner_home': (context) => const OwnerHomePage(),
    '/admin_home': (context) => const AdminHomePage(),
    '/history': (context) => const HistoryPage(),
    '/forgot-password': (context) => const ForgotPasswordPage(),
    '/otp-verification': (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return OtpVerificationPage(email: email);
    },
    '/reset-password': (context) {
      final token = ModalRoute.of(context)!.settings.arguments as String;
      return ResetPasswordPage(resetToken: token);
    },
    '/shops': (context) => const ShopListPage(),
    '/profile': (context) => const ProfilePage(),
    '/appointments': (context) => const AppointmentsPage(),
    // '/cart': (context) => const CartPage(),
    '/logout': (context) => const LogoutPage(),
    '/settings': (context) => const SettingsPage(),
    '/favorites': (context) => const FavoritesPage(),
    '/report': (context) => const ReportsPage(),
    '/owner': (context) => const ShopOwnerDashboard(),
    '/staff': (context) => const StaffManagementPage(),
    // '/favorites': (context) => ChangeNotifierProvider(
    //   create: (_) => FavoritesProvider(FavoritesService()),
    //   child: const FavoritesPage(),),
  };
}

