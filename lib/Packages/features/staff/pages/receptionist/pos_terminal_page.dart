import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';

/// POS / Cash Register terminal view — WAJ + Fresha parity
/// Quick-checkout terminal for Receptionist and Owner roles.
class PosTerminalPage extends StatefulWidget {
  const PosTerminalPage({super.key});

  @override
  State<PosTerminalPage> createState() => _PosTerminalPageState();
}

class _PosTerminalPageState extends State<PosTerminalPage> {
  // Cart
  final List<_CartItem> _cartItems = [];

  // Quick service catalogue (loaded from API or used as static fallback)
  List<Map<String, dynamic>> _services = [];
  bool _loadingServices = true;

  // Payment
  String _selectedMethod = 'CASH';
  String? _voucherCode;
  bool _isProcessing = false;

  // Customer
  String? _customerEmail;

  final _voucherCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();

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
    _loadServices();
  }

  @override
  void dispose() {
    _voucherCtrl.dispose();
    _customerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _loadingServices = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final salonId = auth.user?.salonId ?? 1;
      final api = ApiService();
      final res = await api.get('/salons/$salonId/options/');
      if (res is List) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(
            res.map((e) => Map<String, dynamic>.from(e as Map)),
          );
        });
      } else if (res is Map && res['results'] is List) {
        setState(() {
          _services = List<Map<String, dynamic>>.from(
            (res['results'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
          );
        });
      }
    } catch (_) {
      // Use mock data if API not ready
      _services = [
        {'id': 1, 'option_name': 'Haircut', 'option_price': '8.00'},
        {'id': 2, 'option_name': 'Beard Trim', 'option_price': '5.00'},
        {'id': 3, 'option_name': 'Fade', 'option_price': '12.00'},
        {'id': 4, 'option_name': 'Full Package', 'option_price': '18.00'},
        {'id': 5, 'option_name': 'Kids Cut', 'option_price': '6.00'},
        {'id': 6, 'option_name': 'Hot Towel Shave', 'option_price': '10.00'},
      ];
    } finally {
      if (mounted) setState(() => _loadingServices = false);
    }
  }

  double get _subtotal => _cartItems.fold(0.0, (s, i) => s + i.total);

  void _addItem(Map<String, dynamic> service) {
    final name = service['option_name'] as String? ?? 'Service';
    final price = double.tryParse(service['option_price']?.toString() ?? '0') ?? 0.0;
    final id = service['id']?.toString() ?? name;

    final existing = _cartItems.indexWhere((c) => c.id == id);
    setState(() {
      if (existing >= 0) {
        _cartItems[existing].quantity++;
      } else {
        _cartItems.add(_CartItem(id: id, name: name, price: price, quantity: 1));
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

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) {
      AppSnackBar.error(context, 'Cart is empty');
      return;
    }
    setState(() => _isProcessing = true);
    try {
      // Build a quick JSON payload for a POS transaction
      final api = ApiService();
      await api.post('/salons/pos-checkout/', data: {
        'items': _cartItems.map((c) => {'name': c.name, 'price': c.price, 'quantity': c.quantity}).toList(),
        'total': _subtotal,
        'payment_method': _selectedMethod,
        'voucher_code': _voucherCode,
        'customer_email': _customerEmail,
      });
      if (mounted) {
        AppSnackBar.success(context, 'Checkout complete — ${_subtotal.toStringAsFixed(2)} JOD via $_selectedMethod');
        _clearCart();
        _customerCtrl.clear();
        _voucherCtrl.clear();
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Checkout failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('POS Terminal'),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                Expanded(flex: 3, child: _buildServiceGrid(theme)),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _buildCart(theme)),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildServiceGrid(theme)),
                const Divider(height: 1),
                SizedBox(height: 380, child: _buildCart(theme)),
              ],
            ),
    );
  }

  Widget _buildServiceGrid(ThemeData theme) {
    if (_loadingServices) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _services.length,
              itemBuilder: (_, i) {
                final s = _services[i];
                final name = s['option_name'] as String? ?? 'Service';
                final price = double.tryParse(s['option_price']?.toString() ?? '0') ?? 0.0;
                return GestureDetector(
                  onTap: () => _addItem(s),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${price.toStringAsFixed(1)} JOD', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
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
        ],
      ),
    );
  }

  Widget _buildCart(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cart (${_cartItems.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 46, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text('Tap a service to add', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final item = _cartItems[i];
                      return Row(
                        children: [
                          Expanded(
                            child: Text('${item.name} x${item.quantity}', style: theme.textTheme.bodyMedium),
                          ),
                          Text('${item.total.toStringAsFixed(2)} JOD', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeItem(i),
                            child: Icon(Icons.remove_circle_outline_rounded, size: 20, color: theme.colorScheme.error),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Divider(),
          // Customer lookup
          TextField(
            controller: _customerCtrl,
            onChanged: (v) => _customerEmail = v.isEmpty ? null : v,
            decoration: InputDecoration(
              labelText: 'Customer email (optional)',
              prefixIcon: const Icon(Icons.person_search_rounded),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          // Payment method row
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _paymentMethods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m = _paymentMethods[i];
                final isSelected = _selectedMethod == m['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMethod = m['value'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.transparent : theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(m['icon'] as IconData, size: 16, color: isSelected ? Colors.white : null),
                        const SizedBox(width: 6),
                        Text(m['label'] as String, style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedMethod == 'VOUCHER') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _voucherCtrl,
              onChanged: (v) => _voucherCode = v.isEmpty ? null : v,
              decoration: InputDecoration(
                labelText: 'Voucher code',
                prefixIcon: const Icon(Icons.card_giftcard_rounded),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Total + Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('${_subtotal.toStringAsFixed(2)} JOD',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ],
              ),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _checkout,
                  icon: _isProcessing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.point_of_sale_rounded),
                  label: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  _CartItem({required this.id, required this.name, required this.price, required this.quantity});

  double get total => price * quantity;
}
