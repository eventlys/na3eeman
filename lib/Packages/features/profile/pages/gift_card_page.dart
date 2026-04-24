import 'package:flutter/material.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';

/// Gift Card purchase page — WAJ + Fresha parity
/// Customers can buy fixed-value vouchers to give to friends.
class GiftCardPage extends StatefulWidget {
  const GiftCardPage({super.key});

  @override
  State<GiftCardPage> createState() => _GiftCardPageState();
}

class _GiftCardPageState extends State<GiftCardPage> {
  double _selectedAmount = 10.0;
  final _receiverEmailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final List<double> _amounts = [5, 10, 15, 20, 30, 50];
  bool _isBuying = false;

  // My vouchers I've received
  List<Map<String, dynamic>> _myVouchers = [];
  bool _loadingVouchers = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  @override
  void dispose() {
    _receiverEmailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() => _loadingVouchers = true);
    try {
      final api = ApiService();
      final res = await api.get('/salons/vouchers/');
      if (res is List) {
        setState(() {
          _myVouchers = List<Map<String, dynamic>>.from(
            res.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingVouchers = false);
    }
  }

  Future<void> _purchaseGiftCard() async {
    final email = _receiverEmailCtrl.text.trim();
    if (email.isEmpty) {
      AppSnackBar.error(context, 'Please enter the recipient email');
      return;
    }

    setState(() => _isBuying = true);
    try {
      final api = ApiService();
      await api.post('/salons/vouchers/', data: {
        'voucher_type': 'VALUE',
        'fixed_amount': _selectedAmount,
        'receiver_email': email,
      });
      if (mounted) {
        AppSnackBar.success(context, 'Gift card sent to $email!');
        _receiverEmailCtrl.clear();
        _messageCtrl.clear();
        _loadVouchers();
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Gift Cards & Vouchers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            _buildHeroBanner(),
            const SizedBox(height: 28),
            Text('Select Amount', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _amounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAmount = amount),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            )
                          : null,
                      color: isSelected ? null : theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : theme.dividerColor,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${amount.toInt()} JOD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Recipient Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextField(
              controller: _receiverEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Recipient Email',
                prefixIcon: const Icon(Icons.email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                hintText: 'friend@example.com',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Personal Message (optional)',
                prefixIcon: const Icon(Icons.message_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                hintText: 'Happy birthday! Enjoy your salon experience 🎉',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            // Total summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Gift Card Value', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${_selectedAmount.toInt()} JOD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isBuying ? null : _purchaseGiftCard,
                icon: _isBuying
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.card_giftcard_rounded),
                label: Text(_isBuying ? 'Sending...' : 'Send Gift Card'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // My received vouchers
            Text('My Vouchers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _loadingVouchers
                ? const Center(child: CircularProgressIndicator())
                : _myVouchers.isEmpty
                    ? Center(
                        child: Text(
                          'No vouchers yet',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myVouchers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _VoucherTile(voucher: _myVouchers[i]),
                      ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Give the gift of grooming',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Send a digital gift card to anyone. Redeemable at any Na3eeman salon.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.card_giftcard_rounded, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _VoucherTile extends StatelessWidget {
  final Map<String, dynamic> voucher;
  const _VoucherTile({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = voucher['code'] as String? ?? '—';
    final amount = (voucher['fixed_amount'] as num?)?.toDouble() ?? 0.0;
    final isRedeemed = voucher['is_redeemed'] as bool? ?? false;
    final color = isRedeemed ? Colors.grey : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.card_giftcard_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2)),
                Text(
                  isRedeemed ? 'Redeemed' : 'Active',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} JOD',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
