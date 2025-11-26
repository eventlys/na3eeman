// Helpers/ui/dialog_helper.dart
import 'package:flutter/material.dart';

class DialogHelper {
  static void showSubscriptionUpgradeDialog({
    required BuildContext context,
    required VoidCallback onEnterpriseUpgrade,
    required VoidCallback onPremiumUpgrade,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Enterprise Plan'),
              subtitle: const Text('\$199.99/month'),
              trailing: ElevatedButton(
                onPressed: onEnterpriseUpgrade,
                child: const Text('Upgrade'),
              ),
            ),
            ListTile(
              title: const Text('Premium Plan'),
              subtitle: const Text('\$149.99/month'),
              trailing: ElevatedButton(
                onPressed: onPremiumUpgrade,
                child: const Text('Upgrade'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
