import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';

/// Low inventory stock alert (Studio tier).
class LowStockAlertWidget extends StatefulWidget {
  const LowStockAlertWidget({super.key});

  @override
  State<LowStockAlertWidget> createState() => _LowStockAlertWidgetState();
}

class _LowStockAlertWidgetState extends State<LowStockAlertWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<_Item> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    if (!mounted) return;
    final owner = context.read<OwnerProvider>();
    final shopId = owner.activeShopId;
    if (shopId == null) {
      if (mounted) setState(() { _isLoading = false; _error = 'No shop selected'; });
      return;
    }

    try {
      final response = await _apiService.get('/shops/shops/$shopId/inventory/');
      final data = response['results'] as List;
      
      final parsed = data.map((json) {
        final product = json['product'] ?? {};
        final name = product['product_name'] ?? 'Unknown Item';
        final qty = json['quantity_in_stock'] ?? 0;
        final id = json['id'];
        return _Item(id: id, name: name, qty: qty, threshold: 5); 
      }).where((el) => el.qty <= el.threshold).toList();

      if (mounted) {
        setState(() {
          _items = parsed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load stock data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showReorderDialog(_Item item) async {
    final qtyController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Reorder ${item.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current stock: ${item.qty}'),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity to add',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isSubmitting ? null : () async {
                  // Permanent remove action
                  final shopId = context.read<OwnerProvider>().activeShopId;
                  if (shopId == null) return;
                  
                  setModalState(() => isSubmitting = true);
                  try {
                    await _apiService.delete('/shops/shops/$shopId/inventory/${item.id}/');
                    if (mounted) {
                      Navigator.pop(ctx);
                      _fetchInventory();
                    }
                  } catch (e) {
                    setModalState(() => isSubmitting = false);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove Permanently'),
              ),
              ElevatedButton(
                onPressed: isSubmitting ? null : () async {
                  final val = int.tryParse(qtyController.text.trim());
                  if (val == null || val <= 0) return;
                  
                  final shopId = context.read<OwnerProvider>().activeShopId;
                  if (shopId == null) return;
                  
                  setModalState(() => isSubmitting = true);
                  
                  try {
                    await _apiService.post('/shops/shops/$shopId/inventory/${item.id}/add_stock/', data: {
                      'quantity': val
                    });
                    if (mounted) {
                      Navigator.pop(ctx);
                      _fetchInventory();
                    }
                  } catch (e) {
                    setModalState(() => isSubmitting = false);
                  }
                },
                child: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Stock'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text('low_stock_alerts'.tr(),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${_items.length} items',
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('All stock levels are nominal.'),
          ),
        ..._items.map((item) {
          final pct = item.qty / item.threshold;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Text('${item.qty} left',
                            style: TextStyle(
                                color: item.qty <= 2
                                    ? Colors.red
                                    : Colors.orange,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 24,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => _showReorderDialog(item),
                            child: const Text('Reorder', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(
                      item.qty <= 2 ? Colors.red : Colors.orange),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 7,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/inventory'),
          icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
          label: Text('Manage Inventory'.tr()),
        ),
      ],
    );
  }
}

class _Item {
  final int id;
  final String name;
  final int qty;
  final int threshold;
  _Item({required this.id, required this.name, required this.qty, required this.threshold});
}
