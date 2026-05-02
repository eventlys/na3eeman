import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/utils/formatters.dart';

class BranchesOverview extends StatelessWidget {
  final List<dynamic> branches;
  final VoidCallback? onViewAllBranches;

  const BranchesOverview({
    super.key,
    required this.branches,
    this.onViewAllBranches,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final salonProvider = Provider.of<SalonProvider>(context);
    final branches = salonProvider.branches;

    // If no branches, show empty state
    if (branches.isEmpty) {
      return _buildEmptyState(context, isDarkTheme);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("salon_branches".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              if (onViewAllBranches != null)
                TextButton(
                  onPressed: onViewAllBranches,
                  child: Text("view_all".tr(),
                    style: TextStyle(
                      color: AppColor.lightPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...branches.take(3).map((branch) => _BranchCard(branch: branch)),
          if (branches.length > 3 && onViewAllBranches != null) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onViewAllBranches,
                child: Text(
                  'View all ${branches.length} branches',
                  style: TextStyle(
                    color: AppColor.lightPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          Text("no_branches_available".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text("add_your_first_branch_to_get_started".tr(),
            style: TextStyle(
              color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to add branch screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lightPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text("add_first_branch".tr()),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final dynamic branch; // Using dynamic instead of Branch model

  const _BranchCard({required this.branch});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Extract data using helper methods to avoid direct model access
    final branchName = _getBranchName(branch);
    final branchAddress = _getBranchAddress(branch);
    final branchPhone = _getBranchPhone(branch);
    final isOpen = _getBranchStatus(branch);
    final todayAppointments = _getTodayAppointments(branch);
    final todayRevenue = _getTodayRevenue(branch);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkTheme ? AppColor.darkBackground : AppColor.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme ? AppColor.darkTextHint : AppColor.lightTextHint,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen
                ? (isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess)
                : (isDarkTheme ? AppColor.darkError : AppColor.lightError),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branchName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branchAddress,
                  style: TextStyle(
                    color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branchPhone,
                  style: TextStyle(
                    color: isDarkTheme ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$todayAppointments apps',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDarkTheme ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.formatCurrency(todayRevenue),
                style: TextStyle(
                  color: isDarkTheme ? AppColor.darkSuccess : AppColor.lightSuccess,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods to extract data without model dependency
  String _getBranchName(dynamic branch) {
    if (branch is Map<String, dynamic>) {
      return branch['name'] ?? branch['salon_name'] ?? 'Unknown Branch';
    }
    return branch?.name?.toString() ?? 'Unknown Branch';
  }

  String _getBranchAddress(dynamic branch) {
    if (branch is Map<String, dynamic>) {
      return branch['address'] ?? branch['location'] ?? 'No address provided';
    }
    return branch?.address?.toString() ?? branch?.location?.toString() ?? 'No address provided';
  }

  String _getBranchPhone(dynamic branch) {
    if (branch is Map<String, dynamic>) {
      return branch['phone'] ?? branch['salon_phon_num'] ?? 'No phone';
    }
    return branch?.phone?.toString() ?? branch?.salonPhonNum?.toString() ?? 'No phone';
  }

  bool _getBranchStatus(dynamic branch) {
    if (branch is Map<String, dynamic>) {
      return branch['is_open'] ?? branch['isOpen'] ?? false;
    }
    return branch?.isOpen?.toString() == 'true' || branch?.isOpen == true;
  }

  int _getTodayAppointments(dynamic branch) {
    if (branch is Map<String, dynamic>) {
      return branch['today_appointments'] ?? branch['todayAppointments'] ?? 0;
    }
    return branch?.todayAppointments?.toString() != null
        ? int.tryParse(branch.todayAppointments.toString()) ?? 0
        : 0;
  }

  double _getTodayRevenue(dynamic branch) {
    if (branch is Map<String, dynamic>) {
      final revenue = branch['today_revenue'] ?? branch['todayRevenue'] ?? 0;
      return revenue is double ? revenue : double.tryParse(revenue.toString()) ?? 0.0;
    }
    return branch?.todayRevenue?.toString() != null
        ? double.tryParse(branch.todayRevenue.toString()) ?? 0.0
        : 0.0;
  }
}
