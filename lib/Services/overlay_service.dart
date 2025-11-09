import 'package:flutter/material.dart';
import 'package:na3eeman/Services/sidebar_navigation_service.dart';

import '../features/sidebar/overlays/app_rules_overlay.dart';
import '../features/sidebar/overlays/contact_us_overlay.dart';
import '../features/sidebar/overlays/feedback_overlay.dart';
import '../features/sidebar/overlays/invite_friends_overlay.dart';
import '../features/sidebar/overlays/logout_confirmation_overlay.dart';
import '../features/sidebar/overlays/privacy_policy_overlay.dart';
import '../features/sidebar/overlays/report_problem_overlay.dart';
import '../features/sidebar/overlays/report_shop_overlay.dart';
import '../features/sidebar/overlays/security_policy_overlay.dart';
import '../features/sidebar/overlays/user_reports_overlay.dart';

class OverlayService {
  static void showPrivacyPolicy() {
    _showDialog(
      title: 'Privacy Policy',
      icon: 'assets/icons/lock.png',
      content: PrivacyPolicyOverlay(),
    );
  }

  static void showSecurityPolicy() {
    _showDialog(
      title: 'Security Policy',
      icon: 'assets/icons/secure.png',
      content: SecurityPolicyOverlay(),
    );
  }

  static void showAppRules() {
    _showDialog(
      title: 'Application Rules',
      icon: 'assets/icons/report.png',
      content: AppRulesOverlay(),
    );
  }

  static void showInviteFriends() {
    _showDialog(
      title: 'Invite Friends',
      icon: 'assets/icons/plus.png',
      content: InviteFriendsOverlay(),
    );
  }

  static void showContactUs() {
    _showDialog(
      title: 'Contact Us',
      icon: 'assets/icons/mail_view.png',
      content: ContactUsOverlay(),
      isForm: true,
    );
  }

  static void showReportShop() {
    _showDialog(
      title: 'Report Shop',
      icon: 'assets/icons/report.png',
      content: ReportShopOverlay(),
      isForm: true,
    );
  }

  static void showReportProblem() {
    _showDialog(
      title: 'Report A Problem',
      icon: 'assets/icons/report.png',
      content: ReportProblemOverlay(),
      isForm: true,
    );
  }

    static void showFeedback() {
    _showDialog(
      title: 'your Feedback matters',
      icon: 'assets/icons/chat_text.png',
      content: FeedbackOverlay(),
      isForm: true,
    );
  }

  static void showUserReports() {
    _showDialog(
      title: 'User Reports',
      icon: 'assets/icons/file_star_view.png',
      content: UserReportsOverlay(),
    );
  }

  static void showLogoutConfirmation({required VoidCallback onConfirm}) {
    _showDialog(
      title: 'Logout',
      icon: 'assets/icons/exit.png',
      content: LogoutConfirmationOverlay(onConfirm: onConfirm),
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

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x4dc25858),
                Color(0x80806C99),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Key property - hug content
              children: [
                // Header
                Row(
                  children: [
                    Image.asset(
                      icon,
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Added for better contrast
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black), // Added black color
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                const Divider(color: Colors.black54), // Added color for better visibility
                const SizedBox(height: 4),

                // Content - no fixed height constraints
                isForm ? SingleChildScrollView(child: content) : content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // static Widget _buildLogoutConfirmationContent({
  //   required VoidCallback onConfirm,
  // }) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       const Text('Are you sure you want to logout?'),
  //       const SizedBox(height: 16),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: OutlinedButton(
  //               onPressed: () => Navigator.of(SideNavigationService.navigatorKey.currentContext!).pop(),
  //               child: const Text('Cancel'),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: ElevatedButton(
  //               onPressed: () {
  //                 Navigator.of(SideNavigationService.navigatorKey.currentContext!).pop();
  //                 onConfirm();
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.red,
  //               ),
  //               child: const Text('Logout'),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
}

