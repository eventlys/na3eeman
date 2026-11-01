import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/utils/formatters.dart';

class BranchCard2 extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onAssignManager;

  const BranchCard2({super.key, this.onTap, this.onAssignManager});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final salonProvider = Provider.of<SalonProvider>(context);
    final branches = salonProvider.branches;

    // If there are no branches, return an empty container or loading state
    if (branches.isEmpty) {
      return const SizedBox.shrink();
    }

    // For demonstration, using the first branch
    // In real usage, you might want to pass a specific branch or use a list
    final branch = branches.first;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    branch.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme
                          ? AppColor.darkText
                          : AppColor.lightText,
                    ),
                  ),
                  Chip(
                    label: Text(
                      branch.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: branch.isActive
                        ? (isDarkTheme
                              ? AppColor.darkSuccess
                              : AppColor.lightSuccess)
                        : (isDarkTheme
                              ? AppColor.darkError
                              : AppColor.lightError),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                branch.address,
                style: TextStyle(
                  color: isDarkTheme
                      ? AppColor.darkTextSecondary
                      : AppColor.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    Icons.people,
                    '${branch.totalStaff} staff',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    Icons.payments,
                    Formatters.formatCurrency(branch.safeMonthlyRevenue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (onAssignManager != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: onAssignManager,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDarkTheme
                          ? AppColor.darkPrimary
                          : AppColor.lightPrimary,
                      side: BorderSide(
                        color: isDarkTheme
                            ? AppColor.darkPrimary
                            : AppColor.lightPrimary,
                      ),
                    ),
                    child: Text(
                      "assign_manager".tr(),
                      style: TextStyle(
                        color: isDarkTheme
                            ? AppColor.darkPrimary
                            : AppColor.lightPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkTheme
              ? AppColor.darkTextSecondary
              : AppColor.lightTextSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
          ),
        ),
      ],
    );
  }
}
