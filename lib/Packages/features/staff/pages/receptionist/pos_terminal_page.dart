import 'package:flutter/material.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/points_provider.dart';

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
  final bool _isProcessing = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _voucherCtrl = TextEditingController();

  static const _paymentMethods = [
    {'value': 'CASH', 'label': 'Cash', 'icon': Icons.money_rounded},
    {'value': 'CLIQ', 'label': 'CliQ', 'icon': Icons.qr_code_rounded},
    {'value': 'VISA', 'label': 'Card', 'icon': Icons.credit_card_rounded},
    {'value': 'VOUCHER', 'label': 'Voucher', 'icon': Icons.card_giftcard_rounded},
    {'value': 'POINTS', 'label': 'Points', 'icon': Icons.stars_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Mocking data for now
      _services = [
        {'id': 's1', 'name': 'Classic Haircut', 'price': 8.0},
        {'id': 's2', 'name': 'Beard Trim', 'price': 5.0},
      ];
      _products = [
        {'id': 'p1', 'name': 'Hair Wax', 'price': 12.0},
        {'id': 'p2', 'name': 'Face Cream', 'price': 15.0},
      ];
      _offers = [
        {'id': 'o1', 'name': 'Summer Offer', 'price': 10.0},
      ];
      _packages = [
        {'id': 'pk1', 'name': 'Full Grooming', 'price': 25.0},
      ];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _subtotal => _cartItems.fold(0.0, (s, i) => s + i.total);

  void _addItem(String id, String name, double price, String type) {
    final existing = _cartItems.indexWhere((c) => c.id == id);
    setState(() {
      if (existing >= 0) {
        _cartItems[existing].quantity++;
      } else {
        _cartItems.add(_CartItem(id: id, name: name, price: price, quantity: 1, type: type));
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
      final res = await ApiService().verifyGiftCard(_voucherCtrl.text);
      if (mounted) {
        setModalState(() {
          _voucherCode = _voucherCtrl.text;
        });
        AppSnackBar.success(context, 'Voucher applied! Balance: ${res['balance']} JOD');
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Invalid voucher code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('POS Terminal', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(onPressed: _clearCart, icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error)),
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
          const Text('Customer Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField(_firstNameCtrl, 'First Name', Icons.person_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_lastNameCtrl, 'Last Name', Icons.person_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(_phoneCtrl, 'Phone Number', Icons.phone_rounded, keyboardType: TextInputType.phone)),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _lookupCustomer,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
          if (_customerBalance != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasCustomerPenalty ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _hasCustomerPenalty ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(_hasCustomerPenalty ? Icons.warning_amber_rounded : Icons.stars_rounded, 
                       color: _hasCustomerPenalty ? Colors.red : Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Loyalty Balance: $_customerBalance pts', 
                             style: TextStyle(fontWeight: FontWeight.bold, color: _hasCustomerPenalty ? Colors.red : Colors.green)),
                        if (_hasCustomerPenalty)
                          const Text('⚠️ Pending Penalty Detected (>24h delay)', 
                                     style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
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
      final res = await ApiService().get('/loyalty/balance-by-phone/', queryParams: {'phone': _phoneCtrl.text});
      setState(() {
        _customerBalance = res['points'];
        _hasCustomerPenalty = res['has_pending_penalty'] ?? false;
      });
      AppSnackBar.success(context, 'Customer found!');
    } catch (e) {
      AppSnackBar.error(context, 'Customer not found');
    }
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
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
          _buildCategorySection('Services', _services, Colors.blue, 'Service'),
          const SizedBox(height: 32),
          _buildCategorySection('Packages', _packages, Colors.purple, 'Package'),
          const SizedBox(height: 32),
          _buildCategorySection('Offers', _offers, Colors.orange, 'Offer'),
          const SizedBox(height: 32),
          _buildCategorySection('Products', _products, Colors.green, 'Product'),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items, Color color, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              onTap: () => _addItem(item['id'], item['name'], item['price'], type),
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
                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${item['price']} JOD', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.add_circle_outline_rounded, color: color, size: 20),
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
          const Text('Cart Summary', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._cartItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(child: Text('${item.name} (${item.type}) x${item.quantity}')),
                  Text('${item.total.toStringAsFixed(2)} JOD', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _removeItem(i),
                    child: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.error),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(color: AppColors.almostBlack300)),
                Text('${_subtotal.toStringAsFixed(2)} JOD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                text: 'Proceed to Checkout',
                onPressed: () => _showPaymentModal(theme, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal(ThemeData theme, bool isDark) {
    if (_cartItems.isEmpty) {
      AppSnackBar.error(context, 'Cart is empty');
      return;
    }
    if (_phoneCtrl.text.isEmpty) {
      AppSnackBar.error(context, 'Please enter customer phone');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(color: isDark ? AppColors.almostBlack600 : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12, runSpacing: 12,
                children: _paymentMethods.map((m) {
                  final isSelected = _selectedMethod == m['value'];
                  final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
                  final pointsNeeded = (_subtotal * 200).toInt();
                  final canPayWithPoints = pointsProvider.currentBalance >= pointsNeeded;

                  return GestureDetector(
                    onTap: () {
                      if (m['value'] == 'POINTS' && !canPayWithPoints) {
                        AppSnackBar.error(context, 'Insufficient points balance');
                        return;
                      }
                      setModalState(() => _selectedMethod = m['value'] as String);
                    },
                    child: Opacity(
                      opacity: (m['value'] == 'POINTS' && !canPayWithPoints) ? 0.5 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(m['icon'] as IconData, size: 18, color: isSelected ? Colors.white : null),
                            const SizedBox(width: 8),
                            Text(m['label'] as String, style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.bold)),
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
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Text('Required: ${(_subtotal * 200).toInt()} Points', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              if (_selectedMethod == 'VOUCHER') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _voucherCtrl,
                  decoration: InputDecoration(
                    labelText: 'Voucher Code',
                    suffixIcon: TextButton(onPressed: () => _verifyVoucher(setModalState), child: const Text('Verify')),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Complete Booking',
                onPressed: () {
                  Navigator.pop(context);
                  AppSnackBar.success(context, 'Booking completed for ${_firstNameCtrl.text}!');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItem {
  final String id;
  final String name;
  final double price;
  final String type;
  int quantity;

  _CartItem({required this.id, required this.name, required this.price, required this.quantity, required this.type});

  double get total => price * quantity;
}
