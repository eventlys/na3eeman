// ignore_for_file: prefer_interpolation_to_compose_strings, unused_element, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/Providers/features/salon_provider.dart';
import 'package:na3eeman/Providers/features/gift_card_provider.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/points_provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Providers/features/appointment_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PosTerminalPage extends StatefulWidget {
  const PosTerminalPage({super.key});

  @override
  State<PosTerminalPage> createState() => _PosTerminalPageState();
}

class _PosTerminalPageState extends State<PosTerminalPage> {
  final List<_CartItem> _cartItems = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _offers = [];
  List<Map<String, dynamic>> _packages = [];
  bool _loading = true;

  String _selectedMethod = 'CASH';
  String? _voucherCode;
  bool _isProcessing = false;

  int? _selectedExpertId;
  DateTime? _selectedDateTime;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _voucherCtrl = TextEditingController();

  static const _paymentMethods = [
    {'value': 'CASH', 'label': 'cash', 'icon': Icons.money_rounded},
    {'value': 'CLIQ', 'label': 'cliq_label', 'icon': Icons.qr_code_rounded},
    // {'value': 'VISA', 'label': 'card', 'icon': Icons.credit_card_rounded},
    {
      'value': 'VOUCHER',
      'label': 'voucher_label',
      'icon': Icons.card_giftcard_rounded,
    },
    {'value': 'POINTS', 'label': 'points_label', 'icon': Icons.stars_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final salonId = authProvider.user?.salonId;

      if (salonId == null) {
        AppSnackBar.error(context, 'No salon associated with this account');
        return;
      }

      final results = await Future.wait([
        context.read<SalonProvider>().getSalonServicesRaw(salonId),
        context.read<SalonProvider>().getSalonPackagesRaw(salonId),
        context.read<SalonProvider>().getSalonOffersRaw(salonId),
        context.read<SalonProvider>().getSalonProductsRaw(salonId),
      ]);

      setState(() {
        _services = List<Map<String, dynamic>>.from(results[0]);
        _packages = List<Map<String, dynamic>>.from(results[1]);
        _offers = List<Map<String, dynamic>>.from(results[2]);
        _products = List<Map<String, dynamic>>.from(results[3]);
      });
    } catch (e) {
      AppSnackBar.error(context, 'Failed to load data: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _subtotal => _cartItems.fold(0.0, (s, i) => s + i.total);

  void _addItem(Map<String, dynamic> item, String type) {
    final id = item['id'].toString();
    final name = item['name'] ?? '';
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final duration = item['duration'] as int?;

    final existing = _cartItems.indexWhere((c) => c.id == id && c.type == type);
    setState(() {
      if (existing >= 0) {
        _cartItems[existing].quantity++;
      } else {
        _cartItems.add(
          _CartItem(
            id: id,
            name: name,
            price: price,
            quantity: 1,
            type: type,
            duration: duration,
          ),
        );
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  void _clearCart() => setState(() => _cartItems.clear());

  Future<void> _verifyVoucher(StateSetter setModalState) async {
    if (_voucherCtrl.text.isEmpty) return;
    try {
      final res = await context.read<GiftCardProvider>().verifyGiftCard(
        _voucherCtrl.text,
      );
      if (mounted) {
        setModalState(() {
          _voucherCode = _voucherCtrl.text;
        });
        AppSnackBar.success(
          context,
          'voucher_applied_balance_msg'.tr(args: [res['balance'].toString()]),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'invalid_voucher_code_error'.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'pos_terminal'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              onPressed: _clearCart,
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.error,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomerInfoSection(theme, isDark),
            const Divider(height: 1),
            _buildSelectionSection(theme, isDark),
            _buildCartSummary(theme, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme, isDark),
    );
  }

  Widget _buildCustomerInfoSection(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: isDark ? AppColors.almostBlack600 : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'customer_information'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _firstNameCtrl,
                  'first_name_label'.tr(),
                  Icons.person_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _lastNameCtrl,
                  'last_name_label'.tr(),
                  Icons.person_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _phoneCtrl,
                  'phone_number'.tr(),
                  Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _lookupCustomer,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text('verify_label'.tr()),
                ),
              ),
            ],
          ),
          if (_customerBalance != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasCustomerPenalty
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasCustomerPenalty
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasCustomerPenalty
                        ? Icons.warning_amber_rounded
                        : Icons.stars_rounded,
                    color: _hasCustomerPenalty ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'loyalty_balance_pts'.tr(
                            args: [_customerBalance.toString()],
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _hasCustomerPenalty
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        if (_hasCustomerPenalty)
                          Text(
                            'pending_penalty_detected'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  int? _customerBalance;
  bool _hasCustomerPenalty = false;

  Future<void> _lookupCustomer() async {
    if (_phoneCtrl.text.isEmpty) return;
    try {
      final res = await context.read<PointsProvider>().getLoyaltyBalanceByPhone(
        _phoneCtrl.text,
      );
      setState(() {
        _customerBalance = res['points'];
        _hasCustomerPenalty = res['has_pending_penalty'] ?? false;
        if (res['first_name'] != null) _firstNameCtrl.text = res['first_name'];
        if (res['last_name'] != null) _lastNameCtrl.text = res['last_name'];
      });
      AppSnackBar.success(context, 'customer_found_success'.tr());
    } catch (e) {
      AppSnackBar.error(context, 'customer_not_found_error'.tr());
    }
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        isDense: true,
      ),
    );
  }

  Widget _buildSelectionSection(ThemeData theme, bool isDark) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySection(
            'services'.tr(),
            _services,
            Colors.blue,
            'Service',
          ),
          const SizedBox(height: 32),
          _buildCategorySection(
            'packages'.tr(),
            _packages,
            Colors.purple,
            'Package',
          ),
          const SizedBox(height: 32),
          _buildCategorySection('offers'.tr(), _offers, Colors.orange, 'Offer'),
          const SizedBox(height: 32),
          _buildCategorySection(
            'products'.tr(),
            _products,
            Colors.green,
            'Product',
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Map<String, dynamic>> items,
    Color color,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return GestureDetector(
              onTap: () => _addItem(item, type),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${item['price']} JOD',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: color,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartSummary(ThemeData theme, bool isDark) {
    if (_cartItems.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cart_summary'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._cartItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} (${item.type}) x${item.quantity}',
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(2)} JOD',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _removeItem(i),
                    child: const Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'total_amount'.tr(),
                  style: const TextStyle(color: AppColors.almostBlack300),
                ),
                Text(
                  '${_subtotal.toStringAsFixed(2)} JOD',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                text: 'proceed_to_checkout'.tr(),
                onPressed: () => _showAppointmentDetailsModal(theme, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetailsModal(ThemeData theme, bool isDark) {
    if (_cartItems.isEmpty) {
      AppSnackBar.error(context, 'cart_is_empty_error'.tr());
      return;
    }
    if (_phoneCtrl.text.isEmpty) {
      AppSnackBar.error(context, 'please_enter_customer_phone'.tr());
      return;
    }

    final hasServiceOrPackage = _cartItems.any(
      (i) => i.type == 'Service' || i.type == 'Package' || i.type == 'Offer',
    );

    if (!hasServiceOrPackage) {
      // _showPaymentModal(theme, isDark);
      _handleCompleteBooking();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'select_expert_label'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildExpertSelector(setModalState),
              const SizedBox(height: 24),
              Text(
                'select_date_time_label'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDateTimePicker(setModalState),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'continue'.tr(),
                onPressed: () {
                  if (_selectedExpertId == null || _selectedDateTime == null) {
                    AppSnackBar.error(
                      context,
                      'please_select_both_date_and_time'.tr(),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  // _showPaymentModal(theme, isDark);
                  _handleCompleteBooking();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpertSelector(StateSetter setModalState) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return FutureBuilder<List<dynamic>>(
      future: context.read<SalonProvider>().getSalonExpertsRaw(
        authProvider.user!.salonId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        final experts = snapshot.data ?? [];
        return DropdownButtonFormField<int>(
          initialValue: _selectedExpertId,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            hintText: 'select_expert'.tr(),
          ),
          items: experts.map((e) {
            return DropdownMenuItem<int>(
              value: e['id'],
              child: Text(
                e['user']['first_name'] + ' ' + e['user']['last_name'],
              ),
            );
          }).toList(),
          onChanged: (val) => setModalState(() => _selectedExpertId = val),
        );
      },
    );
  }

  Widget _buildDateTimePicker(StateSetter setModalState) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            setModalState(() {
              _selectedDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded),
            const SizedBox(width: 12),
            Text(
              _selectedDateTime == null
                  ? 'select_date_time'.tr()
                  : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal(ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'payment_method'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _paymentMethods.map((m) {
                  final isSelected = _selectedMethod == m['value'];
                  final pointsProvider = Provider.of<PointsProvider>(
                    context,
                    listen: false,
                  );
                  final pointsNeeded = (_subtotal * 200).toInt();
                  final canPayWithPoints =
                      pointsProvider.currentBalance >= pointsNeeded;

                  return GestureDetector(
                    onTap: () {
                      if (m['value'] == 'POINTS' && !canPayWithPoints) {
                        AppSnackBar.error(
                          context,
                          'insufficient_points_balance'.tr(),
                        );
                        return;
                      }
                      setModalState(
                        () => _selectedMethod = m['value'] as String,
                      );
                    },
                    child: Opacity(
                      opacity: (m['value'] == 'POINTS' && !canPayWithPoints)
                          ? 0.5
                          : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              m['icon'] as IconData,
                              size: 18,
                              color: isSelected ? Colors.white : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (m['label'] as String).tr(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : null,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedMethod == 'POINTS') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Text(
                        'required_points_count'.tr(
                          args: [(_subtotal * 200).toInt().toString()],
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              if (_selectedMethod == 'VOUCHER') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _voucherCtrl,
                  decoration: InputDecoration(
                    labelText: 'voucher_code'.tr(),
                    suffixIcon: TextButton(
                      onPressed: () => _verifyVoucher(setModalState),
                      child: Text('verify_label'.tr()),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'complete_booking'.tr(),
                isLoading: _isProcessing,
                onPressed: () async {
                  await _handleCompleteBooking();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCompleteBooking() async {
    setState(() => _isProcessing = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      );

      final totalDuration = _cartItems.fold(0, (sum, item) {
        // Items might have duration from API, fallback to 30
        return sum + (item.duration ?? 30);
      });

      final startTime = _selectedDateTime ?? DateTime.now();
      final endTime = startTime.add(Duration(minutes: totalDuration));

      final appointmentData = {
        'salon': authProvider.user?.salonId,
        'expert': _selectedExpertId,
        'customer_phone': _phoneCtrl.text,
        'customer_first_name': _firstNameCtrl.text,
        'customer_last_name': _lastNameCtrl.text,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'services': _cartItems.map((i) {
          final type = i.type.toUpperCase();
          return {
            'service_type': type == 'SERVICE' ? 'OPTION' : type,
            if (type == 'SERVICE') 'option': int.tryParse(i.id),
            if (type == 'PACKAGE') 'package': int.tryParse(i.id),
            if (type == 'PRODUCT') 'product': int.tryParse(i.id),
            if (type == 'OFFER') 'offer': int.tryParse(i.id),
            'quantity': i.quantity,
          };
        }).toList(),
        'payment_method': _selectedMethod,
        if (_voucherCode != null) 'voucher_code': _voucherCode,
        'status': 'COMPLETED',
      };

      await appointmentProvider.bookAppointment(appointmentData);

      if (mounted) {
        Navigator.pop(context); // Close modal
        AppSnackBar.success(
          context,
          'booking_completed_for_user'.tr(args: [_firstNameCtrl.text]),
        );
        _clearCart();
        _firstNameCtrl.clear();
        _lastNameCtrl.clear();
        _phoneCtrl.clear();
        _selectedExpertId = null;
        _selectedDateTime = null;
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'booking_failed'.tr(args: [e.toString()]));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

class _CartItem {
  final String id;
  final String name;
  final double price;
  final String type;
  final int? duration;
  int quantity;

  _CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.type,
    this.duration,
  });

  double get total => price * quantity;
}
