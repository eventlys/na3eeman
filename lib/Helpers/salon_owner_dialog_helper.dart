import 'package:easy_localization/easy_localization.dart';
// Helpers/ui/dialog_helper.dart
import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';

class DialogHelper {
  static void showSubscriptionUpgradeDialog({
    required BuildContext context,
    required VoidCallback onEnterpriseUpgrade,
    required VoidCallback onPremiumUpgrade,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("upgrade_subscription".tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("enterprise_plan".tr()),
              subtitle: const Text('\$199.99/month'),
              trailing: ElevatedButton(
                onPressed: onEnterpriseUpgrade,
                child: Text("upgrade".tr()),
              ),
            ),
            ListTile(
              title: Text("premium_plan".tr()),
              subtitle: const Text('\$149.99/month'),
              trailing: ElevatedButton(
                onPressed: onPremiumUpgrade,
                child: Text("upgrade".tr()),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
        ],
      ),
    );
  }

  static void showCreateOfferDialog({
    required BuildContext context,
    required Function(Map<String, dynamic>) onCreateOffer,
  }) {
    // Implementation for create offer dialog
  }
}

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
