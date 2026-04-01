import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CliqPaymentPage extends StatelessWidget {
  final String scheduleType;
  final VoidCallback onPaymentComplete;

  const CliqPaymentPage({
    Key? key,
    required this.scheduleType,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CliQ Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'CliQ ID')),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'PIN'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPaymentComplete,
              child: Text('complete_payment'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

