import 'package:easy_localization/easy_localization.dart';
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
      AppSnackBar.error(context, 'failed_load_gift_cards'.tr());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseGiftCard() async {
    if (_selectedGiftCard == null) return;

    if (_receiverPhoneCtrl.text.isEmpty) {
      AppSnackBar.error(context, 'enter_recipient_phone'.tr());
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
        AppSnackBar.success(context, 'gift_card_purchased_success'.tr());

        // Launch WhatsApp
        final code = GiftCardUtils.formatCardCode(purchasedCard.code);
        final value = purchasedCard.balance.toStringAsFixed(2);
        final expiry = GiftCardUtils.formatDate(purchasedCard.expiresAt);

        final message =
            "${'whatsapp_msg_intro'.tr()}"
            "${'whatsapp_msg_code'.tr(args: [code])}"
            "${'whatsapp_msg_value'.tr(args: [value])}"
            "${'whatsapp_msg_expiry'.tr(args: [expiry])}"
            "${_messageCtrl.text.isNotEmpty ? 'whatsapp_msg_message'.tr(args: [_messageCtrl.text]) : ''}"
            "${'whatsapp_msg_redeem'.tr()}";

        final whatsappUrl =
            "https://wa.me/${_receiverPhoneCtrl.text.replaceAll(' ', '').replaceAll('+', '')}?text=${Uri.encodeComponent(message)}";
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(
            Uri.parse(whatsappUrl),
            mode: LaunchMode.externalApplication,
          );
        }

        _receiverPhoneCtrl.clear();
        _messageCtrl.clear();
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'purchase_failed'.tr(args: [e.toString()]));
      }
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  Future<String?> _showPaymentSelection() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final primaryColor = authProvider.userGender == Gender.female
        ? AppColors.pink
        : AppColors.blue;

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
            Text(
              'select_payment_method'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'payment_desc'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildPaymentOption(
            //   'visa_mastercard'.tr(),
            //   Icons.credit_card_rounded,
            //   'visa',
            //   primaryColor,
            // ),
            // const SizedBox(height: 12),
            // _buildPaymentOption(
            //   'apple_pay'.tr(),
            //   Icons.apple_rounded,
            //   'apple_pay',
            //   primaryColor,
            // ),
            // const SizedBox(height: 12),
            // _buildPaymentOption(
            //   'google_pay'.tr(),
            //   Icons.payment_rounded,
            //   'google_pay',
            //   primaryColor,
            'CliQ'.tr(),
              Icons.qr_code_rounded,
              'cliq',
              primaryColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    String value,
    Color color,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
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
    final secondaryColor = isLadies
        ? AppColors.pinkBastil
        : AppColors.blueBastil;
    final shadowColor = primaryColor.withValues(alpha:0.4);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('gift_cards_title'.tr())),
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text('gift_cards_vouchers'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(primaryColor, secondaryColor, shadowColor),
            const SizedBox(height: 28),
            Text(
              'select_amount'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            if (_availableCards.isEmpty)
              Text(
                'no_cards_available'.tr(),
                style: const TextStyle(color: Colors.grey),
              )
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              )
                            : null,
                        color: isSelected ? null : theme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : theme.dividerColor,
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
            Text(
              'recipient_details'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _receiverPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'recipient_phone'.tr(),
                prefixIcon: const Icon(Icons.phone_iphone_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                labelText: 'personal_message'.tr(),
                prefixIcon: const Icon(Icons.message_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                hintText: 'hint_gift_txt'.tr(),
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
                color: primaryColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'purchase_price'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${_selectedGiftCard?.price.toInt() ?? 0} JOD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
                      Text(
                        'service_value'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                onPressed: (_isBuying || _selectedGiftCard == null)
                    ? null
                    : _purchaseGiftCard,
                icon: _isBuying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.card_giftcard_rounded),
                label: Text(
                  _isBuying ? 'sending_status'.tr() : 'send_gift_card'.tr(),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'my_vouchers'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _myVouchers.isEmpty
                ? Center(
                    child: Text(
                      'no_vouchers_yet'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _myVouchers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _VoucherTile(
                      userGiftCard: _myVouchers[i],
                      accentColor: primaryColor,
                    ),
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
          BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'give_grooming_gift'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'give_grooming_desc'.tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 40,
              color: Colors.white,
            ),
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
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.card_giftcard_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  !isActive ? 'redeemed_expired'.tr() : 'active'.tr(),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} JOD',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
