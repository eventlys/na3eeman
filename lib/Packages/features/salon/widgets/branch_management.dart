import 'package:easy_localization/easy_localization.dart';
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
        title: Text("branch_management".tr()),
        backgroundColor: isDarkTheme
            ? AppColor.darkPrimary
            : AppColor.lightPrimary,
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
                color:
                    (isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary)
                        .withOpacity(0.5),
              ),
              SizedBox(height: 20),
              Text(
                "branch_management".tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "manage_all_your_branches_view_performance_metrics".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: (isDarkTheme ? AppColor.darkText : AppColor.lightText)
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
