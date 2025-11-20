import 'package:flutter/material.dart';
import '../../Models/branch_model.dart';
// import '../../Helpers/constants.dart';
import '../../Utils/constants.dart';
import '../../Utils/formatters.dart';

class BranchCard2 extends StatelessWidget {
  final Branch branch;
  final VoidCallback? onTap;
  final VoidCallback? onAssignManager;

  const BranchCard2({
    super.key,
    required this.branch,
    this.onTap,
    this.onAssignManager,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    branch.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: branch.isActive ? AppColors.successColor : AppColors.errorColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              branch.address,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(Icons.people, '${branch.totalStaff} staff'),
                const SizedBox(width: 16),
                _buildInfoItem(Icons.attach_money, Formatters.formatCurrency(branch.safeMonthlyRevenue)),
              ],
            ),
            const SizedBox(height: 12),
            if (onAssignManager != null)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onAssignManager,
                  child: const Text('Assign Manager'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

