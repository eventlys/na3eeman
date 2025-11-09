import 'package:flutter/material.dart';

import '../../Models/pending_confirmation_model.dart';
import '../../Services/api_service.dart';

class PendingConfirmations extends StatefulWidget {
  final List<PendingConfirmation> pendingConfirmations;

  const PendingConfirmations({super.key, required this.pendingConfirmations});

  @override
  State<PendingConfirmations> createState() => _PendingConfirmationsState();
}

class _PendingConfirmationsState extends State<PendingConfirmations> {
  void _confirmPayment(int appointmentId) async {
    try {
      await ApiService.confirmCashPayment(appointmentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment confirmed successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming payment: $e')),
        );
      }
    }
  }

  void _showConfirmationDialog(PendingConfirmation confirmation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cash Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${confirmation.customerName}'),
            Text('Service: ${confirmation.service}'),
            Text('Amount: \$${confirmation.amount.toStringAsFixed(2)}'),
            if (confirmation.notes != null) Text('Notes: ${confirmation.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmPayment(confirmation.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pendingConfirmations.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Cash Confirmations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.pendingConfirmations.map(
            (confirmation) => _ConfirmationCard(
              confirmation: confirmation,
              onConfirm: () => _showConfirmationDialog(confirmation),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  final PendingConfirmation confirmation;
  final VoidCallback onConfirm;

  const _ConfirmationCard({
    required this.confirmation,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  confirmation.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  confirmation.service,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time: ${TimeOfDay.fromDateTime(confirmation.appointmentTime).format(context)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (confirmation.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Notes: ${confirmation.notes}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '\$${confirmation.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


