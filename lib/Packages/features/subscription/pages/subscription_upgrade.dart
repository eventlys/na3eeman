import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

/// Renders a receipt-like detail view for the selected subscription plan.
class SubscriptionUpgradePage extends StatelessWidget {
  const SubscriptionUpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Read passed arguments setup in settings modal
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    final title = args['title'] as String? ?? 'Growth Plan';
    final price = args['price'] as String? ?? '\$59/mo';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reviewPlan, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Receipt Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.almostBlack600 : AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 10))
                ]
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, size: 48, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.planConfirmedSelection, style: TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 32),

                  // Receipt rows
                  _buildReceiptRow('Billing Period', 'Monthly', isDark),
                  _buildReceiptRow('Amount Due', price, isDark, isBold: true),
                  _buildReceiptRow('Seat Limit', title == 'Basic Plan' ? '1 Seat' : (title == 'Enterprise' ? 'Unlimited' : 'Up to 5 seats'), isDark),
                  
                  const Divider(height: 48, thickness: 1.2),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.totalCharges, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Instructions Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment_rounded, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.paymentInstructions, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.pleaseProceedWithYourPrimaryLinkedAccountBa, style: TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (title == 'Enterprise')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.withOpacity(0.2))),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(child: Text(AppLocalizations.of(context)!.multiBranchSupportSetupRequiredAdminActionA, style: TextStyle(fontSize: 11))),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.processingPaymentMockStep)));
                },
                child: Text(AppLocalizations.of(context)!.proceedToPay, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            if (title == 'Enterprise')
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.adminAlertedRegardingMultiBranchAccess)));
                  },
                  icon: const Icon(Icons.support_agent_rounded, size: 20),
                  label: Text(AppLocalizations.of(context)!.contactAdmin),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }
}
