import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
// import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class InternDashboard extends StatefulWidget {
  const InternDashboard({super.key});

  @override
  State<InternDashboard> createState() => _InternDashboardState();
}

class _InternDashboardState extends State<InternDashboard> with SingleTickerProviderStateMixin {
  String? attachedBarber = 'Jafar';
  late SidebarController sidebarController;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    sidebarController.toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Intern Portal', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButtonStyled(
              icon: Icons.menu_rounded,
              onPressed: _toggleSidebar,
            ),
            actions: [
              IconButtonStyled(
                icon: Icons.notifications_none_rounded,
                onPressed: () => NotificationsBottomSheet.show(context),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 20),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mentorship Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.school_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Currently Learning From', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(attachedBarber ?? 'No Mentor Assigned', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (attachedBarber != null)
                    const Icon(Icons.verified_rounded, color: Colors.white, size: 24),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Performance Tracking
            _buildSectionHeader('Barber Activity Tracking', 'Detailed Logs'),
            const SizedBox(height: 16),
            _buildStatRow('Daily Tasks', '12 completed', Icons.today_rounded),
            _buildStatRow('Weekly Progress', '45 Appointments shadowed', Icons.date_range_rounded),
            _buildStatRow('Monthly Target', 'Learned 4/5 Styles', Icons.emoji_events_rounded),

            const SizedBox(height: 32),

            // Active Barbers List
            _buildSectionHeader('Active Barbers', 'Assign'),
            const SizedBox(height: 16),
            _buildMentorCard('Jafar', 'Master Barber', 'Available to shadow', true),
            _buildMentorCard('Yousif', 'Senior Barber', 'Busy (2 clients)', false),
            _buildMentorCard('Karim', 'Stylist', 'Available to shadow', false),

            const SizedBox(height: 48),
          ],
        ),
      ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        TextButton(onPressed: () {}, child: Text(action, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMentorCard(String name, String role, String status, bool isShadowing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isShadowing ? Theme.of(context).primaryColor.withOpacity(0.05) : (isDark ? AppColors.almostBlack600 : AppColors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isShadowing ? Theme.of(context).primaryColor.withOpacity(0.3) : (isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$role • $status', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          if (isShadowing)
            Chip(
              label: Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.zero,
            )
          else
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: Text('Attach', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor)),
            ),
        ],
      ),
    );
  }
}
