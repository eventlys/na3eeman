import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:na3eeman/Services/ui/sidebar_navigation_service.dart';
//
// import '../../features/sidebar/overlays/app_rules_overlay.dart';
// import '../../features/sidebar/overlays/contact_us_overlay.dart';
// import '../../features/sidebar/overlays/feedback_overlay.dart';
// import '../../features/sidebar/overlays/invite_friends_overlay.dart';
// import '../../features/sidebar/overlays/logout_confirmation_overlay.dart';
// import '../../features/sidebar/overlays/privacy_policy_overlay.dart';
// import '../../features/sidebar/overlays/report_problem_overlay.dart';
// import '../../features/sidebar/overlays/report_salon_overlay.dart';
// import '../../features/sidebar/overlays/security_policy_overlay.dart';
// import '../../features/sidebar/overlays/user_reports_overlay.dart';
//
// class OverlayService {
//   static void showPrivacyPolicy() {
//     _showDialog(
//       title: "privacy_policy".tr(),
//       icon: 'assets/icons/lock.png',
//       content: PrivacyPolicyOverlay(),
//     );
//   }
//
//   static void showSecurityPolicy() {
//     _showDialog(
//       title: "security_policy".tr(),
//       icon: 'assets/icons/secure.png',
//       content: SecurityPolicyOverlay(),
//     );
//   }
//
//   static void showAppRules() {
//     _showDialog(
//       title: "application_rules".tr(),
//       icon: 'assets/icons/report.png',
//       content: AppRulesOverlay(),
//     );
//   }
//
//   static void showInviteFriends() {
//     _showDialog(
//       title: "invite_friends".tr(),
//       icon: 'assets/icons/plus.png',
//       content: InviteFriendsOverlay(),
//     );
//   }
//
//   static void showContactUs() {
//     _showDialog(
//       title: "contact_us".tr(),
//       icon: 'assets/icons/mail_view.png',
//       content: ContactUsOverlay(),
//       isForm: true,
//     );
//   }
//
//   static void showReportSalon() {
//     _showDialog(
//       title: "report_salon".tr(),
//       icon: 'assets/icons/report.png',
//       content: ReportSalonOverlay(),
//       isForm: true,
//     );
//   }
//
//   static void showReportProblem() {
//     _showDialog(
//       title: "report_a_problem".tr(),
//       icon: 'assets/icons/report.png',
//       content: ReportProblemOverlay(),
//       isForm: true,
//     );
//   }
//
//     static void showFeedback() {
//     _showDialog(
//       title: "your_feedback_matters".tr(),
//       icon: 'assets/icons/chat_text.png',
//       content: FeedbackOverlay(),
//       isForm: true,
//     );
//   }
//
//   static void showUserReports() {
//     _showDialog(
//       title: "user_reports".tr(),
//       icon: 'assets/icons/file_star_view.png',
//       content: UserReportsOverlay(),
//     );
//   }
//
//   static void showLogoutConfirmation({required VoidCallback onConfirm}) {
//     _showDialog(
//       title: "logout".tr(),
//       icon: 'assets/icons/exit.png',
//       content: LogoutConfirmationOverlay(onConfirm: onConfirm),
//     );
//   }
//
//   static void _showDialog({
//     required String title,
//     required String icon,
//     required Widget content,
//     bool isForm = false,
//   }) {
//     final context = SideNavigationService.navigatorKey.currentContext;
//     if (context == null) return;
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Color(0x4dc25858),
//                 Color(0x80806C99),
//               ],
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min, // Key property - hug content
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Image.asset(
//                       icon,
//                       width: 30,
//                       height: 30,
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black, // Added for better contrast
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.black), // Added black color
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 4),
//                 const Divider(color: Colors.black54), // Added color for better visibility
//                 const SizedBox(height: 4),
//
//                 // Content - no fixed height constraints
//                 isForm ? SingleChildScrollView(child: content) : content,
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // static Widget _buildLogoutConfirmationContent({
//   //   required VoidCallback onConfirm,
//   // }) {
//   //   return Column(
//   //     mainAxisSize: MainAxisSize.min,
//   //     children: [
//   //       Text("are_you_sure_you_want_to_logout".tr()),
//   //       const SizedBox(height: 16),
//   //       Row(
//   //         children: [
//   //           Expanded(
//   //             child: OutlinedButton(
//   //               onPressed: () => Navigator.of(SideNavigationService.navigatorKey.currentContext!).pop(),
//   //               child: Text("cancel".tr()),
//   //             ),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           Expanded(
//   //             child: ElevatedButton(
//   //               onPressed: () {
//   //                 Navigator.of(SideNavigationService.navigatorKey.currentContext!).pop();
//   //                 onConfirm();
//   //               },
//   //               style: ElevatedButton.styleFrom(
//   //                 backgroundColor: Colors.red,
//   //               ),
//   //               child: Text("logout".tr()),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }
// }
//
import 'package:flutter/material.dart';
import '../../Packages/features/navigation/overlays/app_rules_overlay.dart';
import '../../Packages/features/navigation/overlays/contact_us_overlay.dart';
import '../../Packages/features/navigation/overlays/feedback_overlay.dart';
import '../../Packages/features/navigation/overlays/invite_friends_overlay.dart';
import '../../Packages/features/navigation/overlays/logout_confirmation_overlay.dart';
import '../../Packages/features/navigation/overlays/privacy_policy_overlay.dart';
import '../../Packages/features/navigation/overlays/report_problem_overlay.dart';
import '../../Packages/features/navigation/overlays/report_salon_overlay.dart';
import '../../Packages/features/navigation/overlays/security_policy_overlay.dart';
import '../../Packages/features/navigation/overlays/user_reports_overlay.dart';
import 'sidebar_navigation_service.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();

  factory OverlayService() => _instance;

  OverlayService._internal();

  static void showPrivacyPolicy() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "privacy_policy".tr(),
      icon: 'assets/icons/lock.png',
      content: PrivacyPolicyOverlay(),
    );
  }

  static void showSecurityPolicy() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "security_policy".tr(),
      icon: 'assets/icons/secure.png',
      content: SecurityPolicyOverlay(),
    );
  }

  static void showAppRules() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "application_rules".tr(),
      icon: 'assets/icons/report.png',
      content: AppRulesOverlay(),
    );
  }

  static void showInviteFriends() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "invite_friends".tr(),
      icon: 'assets/icons/plus.png',
      content: InviteFriendsOverlay(),
    );
  }

  static void showContactUs() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "contact_us".tr(),
      icon: 'assets/icons/mail_view.png',
      content: ContactUsOverlay(),
      isForm: true,
    );
  }

  static void showReportSalon() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "report_salon".tr(),
      icon: 'assets/icons/report.png',
      content: ReportSalonOverlay(),
      isForm: true,
    );
  }

  static void showReportProblem() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "report_a_problem".tr(),
      icon: 'assets/icons/report.png',
      content: ReportProblemOverlay(),
      isForm: true,
    );
  }

  static void showFeedback() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "your_feedback_matters".tr(),
      icon: 'assets/icons/chat_text.png',
      content: FeedbackOverlay(),
      isForm: true,
    );
  }

  static void showUserReports() {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "user_reports".tr(),
      icon: 'assets/icons/file_star_view.png',
      content: UserReportsOverlay(),
    );
  }

  static void showLogoutConfirmation({required VoidCallback onConfirm}) {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "logout".tr(),
      icon: 'assets/icons/exit.png',
      content: LogoutConfirmationOverlay(onConfirm: onConfirm),
    );
  }

  // New method for appointment booking overlay
  static void showAppointmentBooking({
    required int salonId,
    required List<dynamic> services,
    VoidCallback? onBookingComplete,
  }) {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "book_appointment".tr(),
      icon: 'assets/icons/calendar.png',
      content: AppointmentBookingOverlay(
        salonId: salonId,
        services: services,
        onBookingComplete: onBookingComplete,
      ),
      isForm: true,
    );
  }

  // New method for payment overlay
  static void showPayment({
    required double amount,
    required String appointmentId,
    required Function(String) onPaymentSuccess,
    required Function(String) onPaymentFailure,
  }) {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "complete_payment".tr(),
      icon: 'assets/icons/payment.png',
      content: PaymentOverlay(
        amount: amount,
        appointmentId: appointmentId,
        onPaymentSuccess: onPaymentSuccess,
        onPaymentFailure: onPaymentFailure,
      ),
      isForm: true,
    );
  }

  // New method for loyalty points overlay
  static void showLoyaltyPoints({required int points, required String source}) {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    _showDialog(
      title: "loyalty_points_earned".tr(),
      icon: 'assets/icons/star.png',
      content: LoyaltyPointsOverlay(points: points, source: source),
    );
  }

  static void _showDialog({
    required String title,
    required String icon,
    required Widget content,
    bool isForm = false,
  }) {
    final context = SideNavigationService.navigatorKey.currentContext;
    if (context == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: !isForm,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Image.asset(icon, width: 30, height: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Divider(color: isDark ? Colors.white12 : Colors.black12),
                const SizedBox(height: 12),

                // Content
                isForm
                    ? Flexible(child: SingleChildScrollView(child: content))
                    : content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// New overlay widgets (you'll need to create these)
class AppointmentBookingOverlay extends StatelessWidget {
  final int salonId;
  final List<dynamic> services;
  final VoidCallback? onBookingComplete;

  const AppointmentBookingOverlay({
    super.key,
    required this.salonId,
    required this.services,
    this.onBookingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Book Appointment for Salon $salonId'),
          // Add your appointment booking form here
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onBookingComplete?.call();
            },
            child: Text("confirm_booking".tr()),
          ),
        ],
      ),
    );
  }
}

class PaymentOverlay extends StatelessWidget {
  final double amount;
  final String appointmentId;
  final Function(String) onPaymentSuccess;
  final Function(String) onPaymentFailure;

  const PaymentOverlay({
    super.key,
    required this.amount,
    required this.appointmentId,
    required this.onPaymentSuccess,
    required this.onPaymentFailure,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Payment Amount: \$${amount.toStringAsFixed(2)}'),
          Text('Appointment: $appointmentId'),
          // Add your payment form here
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPaymentFailure('Payment cancelled');
                  },
                  child: Text("cancel".tr()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onPaymentSuccess('payment_123');
                  },
                  child: Text("pay_now".tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoyaltyPointsOverlay extends StatelessWidget {
  final int points;
  final String source;

  const LoyaltyPointsOverlay({
    super.key,
    required this.points,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            '+$points Points!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text('Earned from: $source', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("awesome".tr()),
          ),
        ],
      ),
    );
  }
}
