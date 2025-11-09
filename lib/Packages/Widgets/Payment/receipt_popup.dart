import 'package:flutter/material.dart';
import 'payment_methods.dart';

class ReceiptPopup {
  static void show({
    required BuildContext context,
    required String scheduleType,
    required String selectedDate,
    required String selectedTime,
    required double amount,
    required Function(String, String) onPaymentComplete,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule Type: ${_getScheduleTypeText(scheduleType)}'),
              const SizedBox(height: 8),
              Text('Date: $selectedDate'),
              const SizedBox(height: 8),
              Text('Time: $selectedTime'),
              const SizedBox(height: 16),
              Text('Total Amount: \$${amount.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final paymentMethod = await PaymentMethodService.showPaymentMethodDialog(context);

                if (paymentMethod != null) {
                  PaymentMethodService.handlePaymentSelection(
                    context: context,
                    method: paymentMethod,
                    scheduleType: scheduleType,
                    onPaymentComplete: onPaymentComplete,
                  );
                }
              },
              child: const Text('Confirm & Pay'),
            ),
          ],
        );
      },
    );
  }

  static String _getScheduleTypeText(String type) {
    switch (type) {
      case 'one_time':
        return 'One Time Only';
      case 'bi_weekly':
        return 'Bi-Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return 'One Time Only';
    }
  }
}

