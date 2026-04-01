import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../../../Providers/features/shop_provider.dart';
import '../../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../../Models/inventory/inventory_item.dart';
import 'package:easy_localization/easy_localization.dart';

class ReceptionistProductsPage extends StatefulWidget {
  const ReceptionistProductsPage({super.key});

  @override
  State<ReceptionistProductsPage> createState() => _ReceptionistProductsPageState();
}

class _ReceptionistProductsPageState extends State<ReceptionistProductsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ShopProvider>().loadInventory();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inventory = context.watch<ShopProvider>().inventory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Management', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics Quick Stat Row
                const Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DashboardSummaryCard(
                        title: 'Total items',
                        value: '${inventory.length}',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardSummaryCard(
                        title: 'Low Stock',
                        value: '${inventory.where((e) => e.quantityInStock < 10).length}',
                        icon: Icons.trending_down_rounded,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('All Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => _showCreateProductModal(context),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('New Product'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (inventory.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No products available.', style: TextStyle(color: AppColors.almostBlack300))))
                else
                  ...inventory.map((item) => _buildProductItem(item)),
              ],
            ),
          ),
    );
  }

  Widget _buildProductItem(InventoryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stock = item.quantityInStock;

    return GestureDetector(
      onTap: () => _showProductDetailsModal(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.inventory_2_rounded, color: AppColors.almostBlack300),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Price: \$${(item.productPrice ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: stock < 10 ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$stock left',
                    style: TextStyle(color: stock < 10 ? AppColors.error : AppColors.success, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // Actual increment
                    context.read<ShopProvider>().adjustStockOnBackend(item.id, 1);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incrementing stock for ${item.productName}')));
                  },
                  child: Text(
                    '+ Add Stock',
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetailsModal(BuildContext context, InventoryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: isDark ? AppColors.almostBlack600 : AppColors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.productName ?? 'Product Details', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item.productDescription ?? 'No description available.', style: const TextStyle(color: AppColors.almostBlack300)),
            const Divider(height: 32),
            _buildDetailRow('Price', '\$${(item.productPrice ?? 0.0).toStringAsFixed(2)}'),
            _buildDetailRow('Current Stock', '${item.quantityInStock} left'),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Edit Product Info',
              onPressed: () {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit UI details setup triggers...')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.almostBlack300)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCreateProductModal(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Product Name', controller: nameController),
              const SizedBox(height: 12),
              _buildDialogField('Price', controller: priceController, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              _buildDialogField('Description', controller: descController, maxLines: 3),
              const SizedBox(height: 12),
              _buildDialogField('Stock Count', controller: stockController, keyboard: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              final desc = descController.text.trim();
              final stock = int.tryParse(stockController.text) ?? 0;

              if (name.isNotEmpty && price > 0) {
                context.read<ShopProvider>().createProductOnBackend(
                  name: name,
                  price: price,
                  description: desc,
                  stock: stock,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Creating $name...')));
              }
            },
            child: Text('create'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, {required TextEditingController controller, TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}
