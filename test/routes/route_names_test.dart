import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Routes/route_names.dart';

void main() {
  group('RouteNames', () {
    test('canonical entry routes', () {
      expect(RouteNames.root, '/');
      expect(RouteNames.onboarding, '/onboarding');
      expect(RouteNames.login, '/login');
      expect(RouteNames.signup, '/signup');
      expect(RouteNames.forgotPassword, '/forgot-password');
      expect(RouteNames.otpVerification, '/otp-verification');
      expect(RouteNames.resetPassword, '/reset-password');
    });

    test('canonical customer routes', () {
      expect(RouteNames.customerHome, '/customer_home');
      expect(RouteNames.salons, '/salons');
      expect(RouteNames.salonDetails, '/salon_details');
      expect(RouteNames.appointments, '/appointments');
      expect(RouteNames.bookAppointment, '/book_appointment');
      expect(RouteNames.profile, '/profile');
      expect(RouteNames.settings, '/settings');
      expect(RouteNames.history, '/history');
      expect(RouteNames.favorites, '/favorites');
    });

    test('canonical staff/owner routes', () {
      expect(RouteNames.expertDashboard, '/expert_dashboard');
      expect(RouteNames.receptionistDashboard, '/receptionist_dashboard');
      expect(RouteNames.internDashboard, '/intern_dashboard');
      expect(RouteNames.ownerDashboard, '/owner_dashboard');
      expect(RouteNames.managementDashboard, '/management_dashboard');
      expect(RouteNames.staff, '/staff');
    });

    test('canonical admin routes', () {
      expect(RouteNames.admin, '/admin');
      expect(RouteNames.adminUsers, '/admin/users');
    });

    test('legacy aliases keep their historical values', () {
      // These must never change while the aliases remain in the route table.
      expect(RouteNames.expertHome, '/expert_home');
      expect(RouteNames.userProfile, '/user_profile');
      expect(RouteNames.adminHome, '/admin_home');
      expect(RouteNames.salonOwnerDashboard, '/salon_owner_dashboard');
    });
  });
}
