import 'package:flutter/material.dart';
import 'package:na3eeman/Models/loyalty/gift_card_model.dart';
import 'package:na3eeman/Services/enums/gender.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:na3eeman/core/utils/gift_card_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class GiftCardPage extends StatefulWidget {
  const GiftCardPage({super.key});

  @override
  State<GiftCardPage> createState() => _GiftCardPageState();
}

class _GiftCardPageState extends State<GiftCardPage> {
  GiftCard? _selectedGiftCard;
  final _receiverPhoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  
  List<GiftCard> _availableCards = [];
  List<UserGiftCard> _myVouchers = [];
  bool _isLoading = true;
  bool _isBuying = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _receiverPhoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final cards = await api.getGiftCards();
      final myCards = await api.getUserGiftCards();
      
      setState(() {
        _availableCards = cards;
        _myVouchers = myCards;
        
        if (_availableCards.isNotEmpty) {
          _selectedGiftCard = _availableCards.first;
        }
      });
    } catch (e) {
      AppSnackBar.error(context, 'Failed to load gift cards');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseGiftCard() async {
    if (_selectedGiftCard == null) return;
    
    if (_receiverPhoneCtrl.text.isEmpty) {
      AppSnackBar.error(context, 'Please enter recipient phone number');
      return;
    }

    final method = await _showPaymentSelection();
    if (method == null) return;

    setState(() => _isBuying = true);
    try {
      final api = ApiService();
      final res = await api.purchaseGiftCard(
        _selectedGiftCard!.id,
        receiverPhone: _receiverPhoneCtrl.text,
        message: _messageCtrl.text,
      );
      final purchasedCard = UserGiftCard.fromJson(res);

      if (mounted) {
        AppSnackBar.success(context, 'Gift card purchased successfully!');
        
        // Launch WhatsApp
        final code = GiftCardUtils.formatCardCode(purchasedCard.code);
        final value = purchasedCard.balance.toStringAsFixed(2);
        final expiry = GiftCardUtils.formatDate(purchasedCard.expiresAt);
        
        final message = "Hi! I sent you a Na3eeman Gift Card! ✨\n\n"
            "Voucher Code: $code\n"
            "Service Value: $value JOD\n"
            "Expires on: $expiry\n"
            "${_messageCtrl.text.isNotEmpty ? '\nMessage: ${_messageCtrl.text}\n' : ''}\n"
            "Redeem it at any Na3eeman salon. Enjoy! 💇‍♂️💇‍♀️";
        
        final whatsappUrl = "https://wa.me/${_receiverPhoneCtrl.text.replaceAll(' ', '').replaceAll('+', '')}?text=${Uri.encodeComponent(message)}";
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
        }

        _receiverPhoneCtrl.clear();
        _messageCtrl.clear();
        _loadData();
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Purchase failed: $e');
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  Future<String?> _showPaymentSelection() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final primaryColor = authProvider.userGender == Gender.female ? AppColors.pink : AppColors.blue;
        
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('The value will be sent to the application account.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            _buildPaymentOption('Visa / Mastercard', Icons.credit_card_rounded, 'visa', primaryColor),
            const SizedBox(height: 12),
            _buildPaymentOption('Apple Pay', Icons.apple_rounded, 'apple_pay', primaryColor),
            const SizedBox(height: 12),
            _buildPaymentOption('Google Pay', Icons.payment_rounded, 'google_pay', primaryColor),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String value, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isLadies = authProvider.userGender == Gender.female;
    
    final primaryColor = isLadies ? AppColors.pink : AppColors.blue;
    final secondaryColor = isLadies ? AppColors.pinkBastil : AppColors.blueBastil;
    final shadowColor = primaryColor.withOpacity(0.4);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gift Cards')),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Gift Cards & Vouchers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(primaryColor, secondaryColor, shadowColor),
            const SizedBox(height: 28),
            Text('Select Amount', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            if (_availableCards.isEmpty)
              const Text('No gift cards currently available.', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _availableCards.map((card) {
                  final isSelected = _selectedGiftCard?.id == card.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGiftCard = card),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [primaryColor, secondaryColor],
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
                                  color: shadowColor,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '${card.price.toInt()} JOD',
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
              controller: _receiverPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Recipient Phone Number',
                prefixIcon: const Icon(Icons.phone_iphone_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                hintText: '+962 7X XXX XXXX',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                floatingLabelStyle: TextStyle(color: primaryColor),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                floatingLabelStyle: TextStyle(color: primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Purchase Price', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        '${_selectedGiftCard?.price.toInt() ?? 0} JOD',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Value (Price - 15%)', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${GiftCardUtils.calculateValue(_selectedGiftCard?.price ?? 0).toStringAsFixed(2)} JOD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: (_isBuying || _selectedGiftCard == null) ? null : _purchaseGiftCard,
                icon: _isBuying
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.card_giftcard_rounded),
                label: Text(_isBuying ? 'Sending...' : 'Send Gift Card'),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('My Vouchers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _myVouchers.isEmpty
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
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _VoucherTile(userGiftCard: _myVouchers[i], accentColor: primaryColor),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(Color primary, Color secondary, Color shadow) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadow,
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
  final UserGiftCard userGiftCard;
  final Color accentColor;
  const _VoucherTile({required this.userGiftCard, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = userGiftCard.code;
    final amount = userGiftCard.balance;
    final isActive = userGiftCard.isActive;
    final color = !isActive ? Colors.grey : accentColor;

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
                  !isActive ? 'Redeemed/Expired' : 'Active',
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
