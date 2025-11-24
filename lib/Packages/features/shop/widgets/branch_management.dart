import 'package:flutter/material.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';

class BranchManagementPage extends StatelessWidget {
  const BranchManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Branch Management'),
        backgroundColor: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
        foregroundColor: isDarkTheme ? AppColor.darkText : AppColor.lightText,
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isDarkTheme ? AppImages.store_view : AppImages.store,
                width: 80,
                height: 80,
                color: (isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary).withOpacity(0.5),
              ),
              SizedBox(height: 20),
              Text(
                'Branch Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Manage all your branches, view performance metrics, and handle branch-specific settings from this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: (isDarkTheme ? AppColor.darkText : AppColor.lightText).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
