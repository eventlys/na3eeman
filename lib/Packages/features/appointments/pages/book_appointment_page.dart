// ignore_for_file: deprecated_member_use, unused_element, unused_field, unused_local_variable, use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Services/api/api_service.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
// import '../../../../Services/ui/overlay_service.dart';
import '../../../../Packages/Core/constants/app_constants.dart';
import '../../../../Services/ui/navigation_service.dart';
import '../../../features/salon/widgets/services_section.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:na3eeman/Models/salon/payment_config_model.dart';
import 'package:na3eeman/Models/loyalty/gift_card_model.dart';
import 'package:na3eeman/Providers/features/gift_card_provider.dart';
import './per_service_selection_page.dart';

enum SelectionMode { individual, perService, noPreference }

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  Map<String, dynamic>? salonData;
  List<Map<String, dynamic>> _selectedServices = [];
  final Set<String> _selectedServiceNames = {};

  Map<String, dynamic>? _selectedExpert;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  bool _isGift = false;
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController =
      TextEditingController();
  final TextEditingController _giftMessageController = TextEditingController();
  String? _selectedRelation;
  String? _receiverGender;
  final TextEditingController _voucherController = TextEditingController();

  final List<String> _relations = [
    'Brother',
    'Sister',
    'Friend',
    'Husband',
    'Wife',
    'Father',
    'Mother',
    'Other',
  ];

  final String _selectedPaymentMethod = 'CASH';
  XFile? _paymentProof;
  bool _initialized = false;
  SalonPaymentConfig? _paymentConfig;
  SelectionMode _selectionMode = SelectionMode.individual;
  final Map<int, dynamic> _perServiceExperts = {}; // serviceId -> expertData

  final int _appliedPoints = 0;
  UserGiftCard? _selectedUserGiftCard;

  final bool _isFetchingConfig = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        salonData = args['salonData'];
        _selectedServices = List<Map<String, dynamic>>.from(
          args['selectedServices'] ?? [],
        );
        _selectedServiceNames.addAll(
          _selectedServices.map(
            (e) => (e['name'] ?? e['serviceName'] ?? '').toString(),
          ),
        );
        _isGift = args['giftMode'] ?? false;
        _receiverGender = args['giftGender'];
        if (salonData != null && salonData!['id'] != null) {
          // _fetchPaymentConfig(salonData!['id']);
          Provider.of<ExpertProvider>(
            context,
            listen: false,
          ).refreshExperts(salonId: salonData!['id']);
        }
      }
      _initialized = true;

      // Load points and gift cards
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PointsProvider>(context, listen: false).loadBalance();
        Provider.of<GiftCardProvider>(context, listen: false).loadMyCards();
      });
    }
  }

  // Future<void> _fetchPaymentConfig(int salonId) async {
  //   setState(() => _isFetchingConfig = true);
  //   try {
  //     final config = await ApiService().getSalonPaymentConfig(salonId);
  //     setState(() {
  //       _paymentConfig = config;
  //       // Default to first allowed method
  //       if (!config.allowCash) {
  //         _selectedPaymentMethod = config.allowCliq ? 'CLIQ' : 'POINTS';
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint('Error fetching payment config: $e');
  //   } finally {
  //     setState(() => _isFetchingConfig = false);
  //   }
  // }

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      final name = service['name'] ?? service['serviceName'] ?? 'Service';
      if (_selectedServiceNames.contains(name)) {
        _selectedServiceNames.remove(name);
        _selectedServices.removeWhere(
          (s) => (s['name'] ?? s['serviceName'] ?? 'Service') == name,
        );
      } else {
        _selectedServiceNames.add(name);
        _selectedServices.add(service);
      }
      _selectedTime = null; // Reset time if duration changes
    });
  }

  double _calculateTotalCost() {
    return _selectedServices.fold(0.0, (sum, service) {
      final priceStr = (service['price'] ?? '0').toString().replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      return sum + (double.tryParse(priceStr) ?? 0.0);
    });
  }

  int _calculateTotalDuration() {
    return _selectedServices.fold(0, (sum, service) {
      final durationStr = (service['duration'] ?? '30').toString().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      return sum + (int.tryParse(durationStr) ?? 30);
    });
  }

  List<String> _generateTimeSlots() {
    if (_selectedExpert == null &&
        _selectionMode != SelectionMode.noPreference) {
      return [];
    }

    final slots = <String>[];
    final startHour = 9;
    final endHour = 20;

    // Add 15 min buffer to total duration
    final totalDuration = _calculateTotalDuration() + 15;
    final interval = totalDuration > 0 ? totalDuration : 45;

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += interval) {
        if (minute >= 60) break;
        final timeString =
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

        if ((hour + minute) % 4 != 0) {
          slots.add(timeString);
        }
      }
    }
    return slots;
  }

  void _handleConfirmBooking() {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_at_least_one_service'.tr())),
      );
      return;
    }
    if (_selectedExpert == null &&
        _selectionMode != SelectionMode.noPreference) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_select_expert'.tr())));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_select_time'.tr())));
      return;
    }

    _showBookingSummary();
  }

  void _showBookingSummary() {
    final totalAmount = _calculateTotalCost();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    final giftCardProvider = Provider.of<GiftCardProvider>(
      context,
      listen: false,
    );

    final pointsCost = pointsProvider.calculatePointsValue(totalAmount);
    final hasEnoughPoints = pointsProvider.currentBalance >= pointsCost;

    final depositAmount = _paymentConfig?.depositType == DepositType.percent
        ? (totalAmount * (_paymentConfig?.depositValue ?? 0) / 100)
        : (_paymentConfig?.depositValue ?? 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'booking_summary'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 32),
                _buildSummaryRow(
                  'salon'.tr(),
                  salonData!['salonName'] ?? 'expert_salon'.tr(),
                ),
                _buildSummaryRow(
                  'expert'.tr(),
                  _selectionMode == SelectionMode.noPreference
                      ? 'any_expert'.tr()
                      : (_selectedExpert?['first_name'] ?? 'Professional'),
                ),
                _buildSummaryRow(
                  'date'.tr(),
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                ),
                _buildSummaryRow('time'.tr(), _selectedTime!),
                _buildSummaryRow(
                  'total'.tr(),
                  '${totalAmount.toStringAsFixed(2)} JOD',
                  isBold: true,
                ),

                if (depositAmount > 0)
                  _buildSummaryRow(
                    'prepayment_required'.tr(),
                    '${depositAmount.toStringAsFixed(2)} JOD',
                    isBold: true,
                    color: AppColors.error,
                  ),

                const Divider(height: 32),

                // Redemptions Section
                Text(
                  'apply_discounts'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                /*
                // Points Slider/Toggle
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.stars_rounded, color: Colors.amber),
                  title: Text('use_loyalty_points'.tr()),
                  subtitle: Text(
                    '${'balance'.tr()}: ${pointsProvider.currentBalance} pts',
                  ),
                  trailing: Switch(
                    value: _appliedPoints > 0,
                    activeThumbColor: Colors.amber,
                    onChanged: (val) {
                      setModalState(() {
                        if (val) {
                          // Apply up to the total cost or current balance
                          _appliedPoints = min(
                            pointsProvider.currentBalance,
                            pointsCost,
                          );
                        } else {
                          _appliedPoints = 0;
                        }
                      });
                    },
                  ),
                ),
                if (_appliedPoints > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 40, bottom: 8),
                    child: Text(
                      '- ${(_appliedPoints * 0.005).toStringAsFixed(2)} JOD',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Gift Card Selection
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.card_giftcard,
                    color: AppColors.pink,
                  ),
                  title: Text('use_gift_card'.tr()),
                  subtitle: Text(
                    _selectedUserGiftCard != null
                        ? '${_selectedUserGiftCard!.code} (${_selectedUserGiftCard!.balance} JOD)'
                        : 'select_gift_card'.tr(),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final selected = await _showGiftCardPicker(
                      giftCardProvider.activeCards,
                    );
                    if (selected != null) {
                      setModalState(() => _selectedUserGiftCard = selected);
                    }
                  },
                ),
                if (_selectedUserGiftCard != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 40, bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          '- ${min(_selectedUserGiftCard!.balance, totalAmount - (_appliedPoints * 0.005)).toStringAsFixed(2)} JOD',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setModalState(() => _selectedUserGiftCard = null),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                */
                const Divider(height: 32),

                // Final Total Calculation
                Builder(
                  builder: (context) {
                    final deduction =
                        (_appliedPoints * 0.005) +
                        (_selectedUserGiftCard?.balance ?? 0);
                    final finalTotal =
                        totalAmount; // max(0.0, totalAmount - deduction);
                    return _buildSummaryRow(
                      'final_total'.tr(),
                      '${finalTotal.toStringAsFixed(2)} JOD',
                      isBold: true,
                      color: Theme.of(context).primaryColor,
                    );
                  },
                ),

                /*
                const SizedBox(height: 16),
                Text(
                  'payment_method'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Payment Options dynamically from config
                if (_paymentConfig?.allowCash ?? true)
                  _buildPaymentOption(
                    id: 'CASH',
                    title: 'Cash (Pay at Salon)'.tr(),
                    icon: Icons.money,
                    color: Colors.green,
                    selected: _selectedPaymentMethod == 'CASH',
                    onTap: () =>
                        setModalState(() => _selectedPaymentMethod = 'CASH'),
                  ),

                if (_paymentConfig?.allowCliq ?? false)
                  _buildPaymentOption(
                    id: 'CLIQ',
                    title: 'CliQ'.tr(),
                    subtitle: 'quick_bank_transfer'.tr(),
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                    selected: _selectedPaymentMethod == 'CLIQ',
                    onTap: () =>
                        setModalState(() => _selectedPaymentMethod = 'CLIQ'),
                  ),
                if (_paymentConfig?.allowPoints ?? true)
                  _buildPaymentOption(
                    id: 'POINTS',
                    title: 'Na3eeman Points'.tr(),
                    subtitle: hasEnoughPoints
                        ? 'redeem_pts'.tr(args: [pointsCost.toString()])
                        : 'need_pts'.tr(args: [pointsCost.toString()]),
                    icon: Icons.stars_rounded,
                    color: Colors.amber,
                    enabled: hasEnoughPoints,
                    selected: _selectedPaymentMethod == 'POINTS',
                    onTap: () =>
                        setModalState(() => _selectedPaymentMethod = 'POINTS'),
                  ),
                if (_paymentConfig?.allowVouchers ?? true)
                  _buildPaymentOption(
                    id: 'VOUCHER',
                    title: 'Digital Voucher'.tr(),
                    subtitle: 'digital_voucher_subtitle'.tr(),
                    icon: Icons.confirmation_number,
                    color: Colors.deepOrange,
                    selected: _selectedPaymentMethod == 'VOUCHER',
                    onTap: () =>
                        setModalState(() => _selectedPaymentMethod = 'VOUCHER'),
                  ),

                const SizedBox(height: 16),

                // CliQ Info
                if (_selectedPaymentMethod == 'CLIQ') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'cliq_transfer_details'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${'alias'.tr()}: ${salonData!['cliq_alias'] ?? 'SalonAlias'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          '${'phone'.tr()}: ${salonData!['cliq_phone_num'] ?? '00962...'}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Voucher Input
                if (_selectedPaymentMethod == 'VOUCHER') ...[
                  TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      labelText: 'voucher_code'.tr(),
                      hintText: 'ABCD-1234',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Proof Upload for Cash/CliQ
                if (_selectedPaymentMethod == 'CASH' ||
                    _selectedPaymentMethod == 'CLIQ') ...[
                  InkWell(
                    onTap: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setModalState(() => _paymentProof = image);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _paymentProof == null
                              ? Colors.red.withValues(alpha:0.5)
                              : Colors.grey.withValues(alpha:0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _paymentProof == null
                            ? Colors.red.withValues(alpha:0.02)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: _paymentProof == null
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _paymentProof == null
                                  ? 'upload_proof_required'.tr()
                                  : 'proof_uploaded'.tr(
                                      args: [_paymentProof!.name],
                                    ),
                              style: TextStyle(
                                color: _paymentProof == null
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_paymentProof != null)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                */
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'confirm_appointment'.tr(),
                  onPressed: () {
                    Navigator.pop(context);
                    _processStandardPayment(totalAmount);
                  },
                ),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'cancel'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    bool enabled = true,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Colors.grey.withValues(alpha: 0.2),
              width: selected ? 2 : 1,
            ),
            color: selected
                ? color.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? color : Colors.grey),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? color : null,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              const Spacer(),
              if (selected) Icon(Icons.check_circle, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _processStandardPayment(double amountJod) async {
    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );

    final appointmentData = {
      'salon': salonData!['id'],
      if (_selectedExpert != null) 'expert': _selectedExpert!['id'],
      'start_time':
          "${DateFormat('yyyy-MM-dd').format(_selectedDate)}T$_selectedTime:00Z",
      'end_time':
          "${DateFormat('yyyy-MM-dd').format(_selectedDate)}T${_calculateEndTime()}:00Z",
      'services': _selectedServices.map((s) {
        final type =
            s['type'] ?? (s['category'] == 'Product' ? 'PRODUCT' : 'OPTION');
        return {
          'service_type': type,
          if (type == 'OPTION') 'option': s['id'],
          if (type == 'PACKAGE') 'package': s['id'],
          if (type == 'PRODUCT') 'product': s['id'],
          'quantity': 1,
        };
      }).toList(),
      'payment_method': 'CASH', // _selectedPaymentMethod,
      /*
      if (_selectedPaymentMethod == 'VOUCHER')
        'voucher_code': _voucherController.text,
      'points_to_redeem': _appliedPoints,
      if (_selectedUserGiftCard != null)
        'gift_card_code': _selectedUserGiftCard!.code,
      */
      'is_gift': _isGift,
      if (_isGift) ...{
        'gift_receiver_name': _receiverNameController.text,
        'gift_receiver_phone': _receiverPhoneController.text,
        'gift_receiver_gender': _receiverGender,
        'gift_relation': _selectedRelation,
        'gift_message': _giftMessageController.text,
      },
    };

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await appointmentProvider.bookAppointment(appointmentData);
      final appointmentId = result['id'];
      final cliqData = result['cliq_data'];

      // Upload proof if applicable
      if (_paymentProof != null && appointmentId != null) {
        await Provider.of<ApiService>(
          context,
          listen: false,
        ).uploadPaymentProof(
          appointmentId: appointmentId,
          proof: File(_paymentProof!.path),
        );
      }

      if (mounted) Navigator.pop(context); // Close loading dialog

      if (cliqData != null &&
          cliqData['type'] == 'QR' &&
          cliqData['qr_image_base64'] != null) {
        if (!mounted) return;
        await _showCliqQRDialog(cliqData['qr_image_base64']);
      }

      if (_isGift) {
        _showGiftSuccessDialog();
      } else {
        _completeBooking(method: _selectedPaymentMethod);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('booking_failed'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  String _calculateEndTime() {
    // Basic end time calculation: start + duration
    final parts = _selectedTime!.split(':');
    final start = DateTime(
      2024,
      1,
      1,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final end = start.add(Duration(minutes: _calculateTotalDuration()));
    return DateFormat('HH:mm').format(end);
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount) {
    // Deprecated in favor of _processStandardPayment
  }

  void _showGiftSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('gift_booked_success'.tr()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, size: 80, color: Colors.pink),
            const SizedBox(height: 24),
            Text('gift_scheduled_paid'.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'sharing_link_allows'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final link =
                    "${AppConstants.webAppUrl}/appointment/${DateTime.now().millisecondsSinceEpoch}";
                final message =
                    "I have a gift for you! 🎁 Booked an appointment at Na3eeman. Show this link to the salon: $link";
                Share.share(message);
              },
              icon: const Icon(Icons.share),
              label: Text(
                'share_gift_link'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                NavigationService.navigateToHomeBasedOnRole(
                  context,
                  'CUSTOMER',
                );
              },
              child: Text(
                "back_to_home".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeBooking({String? method}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('appointment_confirmed'.tr(), textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text('booking_success_msg'.tr(), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                NavigationService.navigateToHomeBasedOnRole(
                  context,
                  'CUSTOMER',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'done'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<UserGiftCard?> _showGiftCardPicker(List<UserGiftCard> cards) {
    return showModalBottomSheet<UserGiftCard>(
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
          children: [
            Text(
              'select_gift_card'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (cards.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'no_active_gift_cards'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.card_giftcard,
                      color: AppColors.pink,
                    ),
                    title: Text(card.code),
                    subtitle: Text('${'balance'.tr()}: ${card.balance} JOD'),
                    onTap: () => Navigator.pop(context, card),
                  );
                },
              ),
            const SizedBox(height: 16),
            SecondaryButton(
              text: 'cancel'.tr(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expertProvider = context.watch<ExpertProvider>();
    final experts = expertProvider.experts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("book_appointment".tr()), centerTitle: true),
      body: salonData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Services Review
                Text(
                  'select_services_step'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<PointsProvider>(
                  builder: (context, points, child) {
                    if (!points.hasPendingPenalty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'payment_overdue_warning'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'payment_overdue_description'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ServicesSection(
                  selectedServiceNames: _selectedServiceNames,
                  onToggleService: _toggleService,
                  services: salonData!['services'] != null
                      ? List<Map<String, dynamic>>.from(salonData!['services'])
                      : [
                          {
                            'name': 'Classic Haircut',
                            'price': '15.00',
                            'duration': '30 min',
                          },
                          {
                            'name': 'Beard Grooming',
                            'price': '10.00',
                            'duration': '20 min',
                          },
                          {
                            'name': 'Premium Shave',
                            'price': '20.00',
                            'duration': '40 min',
                          },
                        ],
                ),
                const SizedBox(height: 24),

                /*
                // Gift Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isGift
                        ? Colors.pink.withValues(alpha:0.05)
                        : (isDark
                              ? AppColors.almostBlack600
                              : Colors.grey.withValues(alpha:0.05)),
                    borderRadius: BorderRadius.circular(16),
                    border: _isGift
                        ? Border.all(color: Colors.pink.withValues(alpha:0.3))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isGift
                                ? Icons.card_giftcard
                                : Icons.person_outline,
                            color: _isGift ? Colors.pink : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'gift_this_service'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isGift,
                            activeThumbColor: Colors.pink,
                            onChanged: (val) {
                              setState(() {
                                _isGift = val;
                                if (val) {
                                  // Logic to allow opposite gender search would be here,
                                  // but on this screen we are already at the specific salon.
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isGift) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _receiverNameController,
                          decoration: InputDecoration(
                            labelText: 'receiver_name'.tr(),
                            prefixIcon: const Icon(Icons.person),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _receiverPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'receiver_phone'.tr(),
                            prefixIcon: const Icon(Icons.phone),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedRelation,
                                decoration: InputDecoration(
                                  labelText: 'relation'.tr(),
                                  border: const OutlineInputBorder(),
                                ),
                                items: _relations
                                    .map(
                                      (r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(r.tr()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedRelation = val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _receiverGender,
                                decoration: InputDecoration(
                                  labelText: 'gender'.tr(),
                                  border: const OutlineInputBorder(),
                                ),
                                items: ['MALE', 'FEMALE']
                                    .map(
                                      (g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g.tr()),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _receiverGender = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _giftMessageController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'personal_message_optional'.tr(),
                            prefixIcon: const Icon(Icons.message),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                */

                // Totals
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.almostBlack600
                        : Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'total_duration'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'mins_suffix'.tr(
                              args: [_calculateTotalDuration().toString()],
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'total_cost'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '\$${_calculateTotalCost().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Staff Selection Mode Selection
                Text(
                  'professional_selection_step'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                _buildSelectionModeButtons(isDark),

                const SizedBox(height: 24),

                if (_selectionMode == SelectionMode.noPreference)
                  _buildNoPreferenceView(isDark)
                else if (_selectionMode == SelectionMode.perService)
                  _buildPerServiceSelectionView(isDark)
                else
                  _buildIndividualSelectionView(
                    isDark,
                    experts,
                    expertProvider.isLoading,
                  ),

                const SizedBox(height: 32),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(
            text: "confirm_appointment".tr(),
            onPressed: _handleConfirmBooking,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionModeButtons(bool isDark) {
    return Column(
      children: [
        _buildModeButton(
          label: "no_preferences".tr(),
          icon: Icons.shuffle_rounded,
          mode: SelectionMode.noPreference,
        ),
        /*
        const SizedBox(height: 12),
        _buildModeButton(
          label: "select_professional_per_service".tr(),
          icon: Icons.list_alt_rounded,
          mode: SelectionMode.perService,
        ),
        */
        const SizedBox(height: 12),
        _buildModeButton(
          label: "individual_selection".tr(),
          icon: Icons.person_search_rounded,
          mode: SelectionMode.individual,
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String label,
    required IconData icon,
    required SelectionMode mode,
  }) {
    final isSelected = _selectionMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectionMode = mode),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : (isDark ? AppColors.almostBlack600 : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPreferenceView(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'We will assign the best available professional for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildDatesAndHoursSection(isDark),
        ],
      ),
    );
  }

  Widget _buildPerServiceSelectionView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._selectedServices.map((service) {
          final serviceId = service['id'] ?? service['_id'];
          final selectedExpert = _perServiceExperts[serviceId];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.almostBlack600 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] ?? 'Service',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (selectedExpert != null)
                        Text(
                          'Assigned to: ${selectedExpert['first_name']}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _navigateToProfessionalSelection(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                  ),
                  child: Text(selectedExpert == null ? 'Select' : 'Change'),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        _buildDatesAndHoursSection(isDark),
      ],
    );
  }

  void _navigateToProfessionalSelection(Map<String, dynamic> service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerServiceSelectionPage(
          service: service,
          salonId: salonData!['id'],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _perServiceExperts[service['id']] = result;
      });
    }
  }

  Widget _buildIndividualSelectionView(
    bool isDark,
    List<dynamic> experts,
    bool isLoading,
  ) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: experts.length,
            itemBuilder: (context, index) {
              final expert = experts[index].toJson();
              final isSelected =
                  _selectedExpert != null &&
                  _selectedExpert!['id'] == expert['id'];
              final rating = (expert['rating'] ?? 5.0).toDouble();

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedExpert = expert;
                  _selectedTime = null;
                }),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : (isDark ? AppColors.almostBlack600 : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: isSelected
                                ? Colors.white24
                                : AppColors.almostBlack50,
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.check,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        expert['first_name'] ?? 'Expert',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildDatesAndHoursSection(isDark),
      ],
    );
  }

  Widget _buildDatesAndHoursSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "available_dates".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // Next 2 weeks
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = DateUtils.isSameDay(_selectedDate, date);

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                }),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : (isDark ? AppColors.almostBlack600 : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "available_hours".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildHoursGrid(isDark),
      ],
    );
  }

  Widget _buildHoursGrid(bool isDark) {
    final slots = _generateTimeSlots();
    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No availability on this day.',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = _selectedTime == slot;
        return InkWell(
          onTap: () => setState(() => _selectedTime = slot),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : (isDark ? AppColors.almostBlack600 : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(
                slot,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCliqQRDialog(String base64Image) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('cliq_payment'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('scan_cliq_qr'.tr(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.memory(
                  Uri.parse(base64Image).data!.contentAsBytes(),
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'amount_to_pay'.tr(
                  args: [_calculateTotalCost().toStringAsFixed(2)],
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('done'.tr()),
            ),
          ],
        );
      },
    );
  }
}
