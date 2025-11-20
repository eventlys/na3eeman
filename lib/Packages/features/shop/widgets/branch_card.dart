import 'package:flutter/material.dart';

import '../../Models/branch_model.dart';
import '../../Utils/constants.dart';
import '../../Utils/formatters.dart';

class BranchCard extends StatelessWidget {
  final List<Branch> branches;
  final VoidCallback onViewAll;

  const BranchCard({
    super.key,
    required this.branches,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Branch Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                Chip(
                  label: Text('${branches.length} Branches'),
                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...branches.take(2).map((branch) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: branch.isOpen 
                    ? AppColors.successColor.withValues(alpha: 0.2)
                    : AppColors.errorColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.store,
                  color: branch.isOpen 
                    ? AppColors.successColor
                    : AppColors.errorColor,
                ),
              ),
              title: Text(branch.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(branch.address),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: branch.isOpen 
                          ? AppColors.successColor
                          : AppColors.errorColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        branch.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: branch.isOpen 
                            ? AppColors.successColor
                            : AppColors.errorColor,
                        ),
                      ),
                      if (branch.hasLowStockAlerts) ...[
                        SizedBox(width: 8),
                        Icon(Icons.warning, size: 14, color: AppColors.warningColor),
                        SizedBox(width: 4),
                        Text('${branch.lowStockItems} low stock'),
                      ],
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Formatters.formatCurrency(branch.getMonthlyRevenue),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.successColor,
                    ),
                  ),
                  Text(
                    '${branch.getTotalSales} sales',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )),
            if (branches.length > 2)
              TextButton(
                onPressed: onViewAll,
                child: Text('View all ${branches.length} branches'),
              ),
          ],
        ),
      ),
    );
  }
}

