import 'package:flutter/material.dart';
import 'package:na3eeman/Packages/Navigations/reports_page.dart';

import '../../../Utils/constants.dart';
import '../../Widgets/custom_app_bar.dart';
import '../../profile/pages/barber_performance_page.dart';
import '../../Navigations/barbers_list_page.dart';
import 'branches_page.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: AppStrings.staffManagement),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            'Barbers',
            Icons.content_cut,
            AppColors.primaryColor,
            () => _navigateToPage(context, const BarbersListPage()),
          ),
          _buildFeatureCard(
            context,
            'Performance',
            Icons.assessment,
            AppColors.secondaryColor,
            () => _navigateToPage(context, const BarberPerformancePage()),
          ),
          _buildFeatureCard(
            context,
            'Reports',
            Icons.description,
            AppColors.accentColor,
            () => _navigateToPage(context, const ReportsPage()),
          ),
          _buildFeatureCard(
            context,
            'Branches',
            Icons.store,
            AppColors.warningColor,
            () => _navigateToPage(context, const BranchesPage()),
          ),
          _buildFeatureCard(
            context,
            'Schedule',
            Icons.calendar_today,
            Colors.blue,
            () => _showComingSoon(context),
          ),
          _buildFeatureCard(
            context,
            'Payroll',
            Icons.payment,
            Colors.green,
            () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon!')),
    );
  }
}

