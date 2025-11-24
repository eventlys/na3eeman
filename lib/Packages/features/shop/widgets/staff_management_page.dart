import 'package:flutter/material.dart';
import '../../../Core/constants/app_strings.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../Navigations/reports_list_page.dart';
import '../../profile/pages/barber_performance_page.dart';
import '../../Navigations/barbers_list_page.dart';
import '../pages/branches_page.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkTheme ? AppColor.darkBackground : AppColor.lightBackground,
      appBar: AppBar(
        title: Text(AppStrings.staffManagement),
        backgroundColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        foregroundColor: isDarkTheme ? AppColor.darkText : AppColor.lightText,
        elevation: 2,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            'Barbers',
            isDarkTheme ? AppImages.scissor_view : AppImages.scissor,
            isDarkTheme ? AppColor.darkBarber : AppColor.lightBarber,
            () => _navigateToPage(context, const BarbersListPage()),
          ),
          _buildFeatureCard(
            context,
            'Performance',
            isDarkTheme ? AppImages.file_star_view : AppImages.file_star,
            isDarkTheme ? AppColor.darkInfo : AppColor.lightInfo,
            () => _navigateToPage(context, const BarberPerformancePage()),
          ),
          _buildFeatureCard(
            context,
            'Reports',
            isDarkTheme ? AppImages.description_view : AppImages.description,
            isDarkTheme ? AppColor.darkAccent : AppColor.lightAccent,
            () => _navigateToPage(context, const ReportsPage()),
          ),
          _buildFeatureCard(
            context,
            'Branches',
            isDarkTheme ? AppImages.store_view : AppImages.store,
            isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess,
            () => _navigateToPage(context, const BranchesPage()),
          ),
          _buildFeatureCard(
            context,
            'Schedule',
            isDarkTheme ? AppImages.calender_view : AppImages.calender,
            isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
            () => _showComingSoon(context),
          ),
          _buildFeatureCard(
            context,
            'Payroll',
            isDarkTheme ? AppImages.money_view : AppImages.money,
            isDarkTheme ? AppColor.darkSecondary : AppColor.lightSecondary,
            () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String iconAsset,
    Color color,
    VoidCallback onTap,
  ) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  iconAsset,
                  width: 30,
                  height: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feature coming soon!',
          style: TextStyle(
            color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
          ),
        ),
        backgroundColor: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
