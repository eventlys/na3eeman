import 'package:flutter/material.dart';

class VisaPaymentPage extends StatelessWidget {
  final String scheduleType;
  final VoidCallback onPaymentComplete;

  const VisaPaymentPage({
    Key? key,
    required this.scheduleType,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visa Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Card Number')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Expiry Date')),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'CVV'),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPaymentComplete,
              child: const Text('Complete Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

