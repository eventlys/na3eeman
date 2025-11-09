import 'package:flutter/material.dart';
import '../Auth/otp_verification_page.dart';
import '../Auth/reset_password.dart';
import '../Auth/forgot_password.dart';
import '../Packages/HomePages/login.dart';
import '../Packages/HomePages/signup.dart';
import '../Packages/HomePages/customer_home.dart';
import '../Packages/HomePages/barber_home.dart';
// import '../Packages/HomePages/owner_home.dart';
import '../Packages/HomePages/admin_home.dart';
import '../Packages/Lists/appointments_page.dart';
import '../Packages/Lists/shops.dart';
import '../Packages/Navigations/Favorites.dart';
import '../Packages/Navigations/cart_page.dart';
// import '../Packages/Navigations/favorites_page.dart';
import '../Packages/Navigations/history_page.dart';
import '../Packages/Navigations/logout.dart';
import '../Packages/Navigations/profile_page.dart';
import '../Packages/Navigations/reports.dart';
import '../Packages/Navigations/settings.dart';
import '../Packages/Navigations/shop_owner_dashboard.dart';
import '../Packages/Navigations/staff_management_page.dart';
// import '../Provider/favorites_provider.dart';
// import '../Services/favorites_service.dart';

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
    '/cart': (context) => const CartPage(),
    '/logout': (context) => const LogoutPage(),
    '/settings': (context) => const SettingsPage(),
    '/favorites': (context) => const FavoritesPage(),
    '/report': (context) => const ReportPage(),
    '/owner': (context) => const ShopOwnerDashboard(),
    '/staff': (context) => const StaffManagementPage(),
    // '/favorites': (context) => ChangeNotifierProvider(
    //   create: (_) => FavoritesProvider(FavoritesService()),
    //   child: const FavoritesPage(),),
  };
}

