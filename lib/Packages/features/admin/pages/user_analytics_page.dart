import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AdminUserAnalyticsPage extends StatelessWidget {
  const AdminUserAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'User Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'no_analytics_data'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.almostBlack300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
