import 'package:flutter/material.dart';
import '../../../../Utils/constants.dart';

class BranchManagementPage extends StatelessWidget {
  const BranchManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Branch Management'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_mall_directory,
                size: 80,
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
              SizedBox(height: 20),
              Text(
                'Branch Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Manage all your branches, view performance metrics, and handle branch-specific settings from this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

