import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import 'package:easy_localization/easy_localization.dart';

class BranchCard extends StatelessWidget {
  final VoidCallback onViewAll;

  const BranchCard({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final salonProvider = Provider.of<SalonProvider>(context);
    final branches = salonProvider.branches;

    return Card(
      elevation: 4,
      color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.branchManagement,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                  ),
                ),
                Chip(
                  label: Text(
                    '${branches.length} Branches',
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
                    ),
                  ),
                  backgroundColor: (isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary)
                      .withValues(alpha: 0.1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...branches.take(2).map((branch) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: branch.isOpen
                    ? (isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess).withValues(alpha: 0.2)
                    : (isDarkTheme ? AppColor.darkError : AppColor.lightError).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  isDarkTheme ? AppImages.store_view : AppImages.store,
                  width: 20,
                  height: 20,
                  color: branch.isOpen
                    ? isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess
                    : isDarkTheme ? AppColor.darkError : AppColor.lightError,
                ),
              ),
              title: Text(
                branch.name,
                style: TextStyle(
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.address,
                    style: TextStyle(
                      color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: branch.isOpen
                          ? isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess
                          : isDarkTheme ? AppColor.darkError : AppColor.lightError,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        branch.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: branch.isOpen
                            ? isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess
                            : isDarkTheme ? AppColor.darkError : AppColor.lightError,
                        ),
                      ),
                      if (branch.hasLowStockAlerts) ...[
                        const SizedBox(width: 8),
                        Image.asset(
                          isDarkTheme ? AppImages.warning_view : AppImages.warning,
                          width: 14,
                          height: 14,
                          color: isDarkTheme ? AppColor.darkWarning : AppColor.lightWarning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${branch.lowStockItems} low stock',
                          style: TextStyle(
                            color: isDarkTheme ? AppColor.darkWarning : AppColor.lightWarning,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatCurrency(branch.getMonthlyRevenue),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess,
                    ),
                  ),
                  Text(
                    '${branch.getTotalSales} sales',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )).toList(),
            if (branches.length > 2)
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View all ${branches.length} branches',
                  style: TextStyle(
                    color: isDarkTheme ? AppColor.darkPrimary : AppColor.lightPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Simple currency formatter - you can replace this with your Formatters.formatCurrency
    return '\$${amount.toStringAsFixed(2)}';
  }
}
