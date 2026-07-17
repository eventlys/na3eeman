// ignore_for_file: unused_local_variable, use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../../Providers/features/salon_provider.dart';
import '../../../../../Providers/features/inventory_provider.dart';
import '../../../../../Providers/features/auth_provider.dart';
import 'package:provider/provider.dart';

class ReceptionistInventoryPage extends StatefulWidget {
  final bool? startWithTools;
  final bool? startWithProducts;
  final bool? startWithShared;
  const ReceptionistInventoryPage({
    super.key,
    this.startWithTools,
    this.startWithProducts,
    this.startWithShared,
  });

  @override
  State<ReceptionistInventoryPage> createState() =>
      _ReceptionistInventoryPageState();
}

class _ReceptionistInventoryPageState extends State<ReceptionistInventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _toolsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.startWithTools == true) {
      initialIndex = 0;
    } else if (widget.startWithShared == true) {
      initialIndex = 1;
    } else if (widget.startWithProducts == true) {
      initialIndex = 2;
    }
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventory();
    });
  }

  void _loadInventory() {
    final salonId = context.read<AuthProvider>().user?.salonId;
    if (salonId != null) {
      context.read<InventoryProvider>().loadInventoryItems(salonId: salonId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _toolsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "inventory_management".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'tools'.tr()),
            Tab(text: 'shared'.tr()),
            Tab(text: 'products'.tr()),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: AppColors.almostBlack300,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: inventoryProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryList(items: inventoryProvider.personalKitItems),
                _buildInventoryList(items: inventoryProvider.consumables),
                _buildProductsList(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemModal(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInventoryList({required List<dynamic> items}) {
    if (items.isEmpty) {
      return Center(child: Text('no_items_found'.tr()));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildInventoryCard(
          name: item['name'] ?? 'inventory_item'.tr(),
          price: '\$${item['price'] ?? '0.00'}',
          frequency: item['frequency'] ?? 'N/A'.tr(),
          assignedTo: item['assigned_tools_name'] ?? 'shared'.tr(),
          stock: item['current_stock'] ?? 0,
          id: item['id']?.toString() ?? '',
        );
      },
    );
  }

  Widget _buildProductsList() {
    final inventory = context.watch<SalonProvider>().inventory;
    if (inventory.isEmpty) {
      return Center(child: Text('no_products_available'.tr()));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        final item = inventory[index];
        return _buildInventoryCard(
          name: item.productName ?? 'product'.tr(),
          price: '\$${(item.productPrice ?? 0.0).toStringAsFixed(2)}',
          frequency: 'N/A'.tr(),
          assignedTo: 'sales'.tr(),
          stock: item.quantityInStock,
          id: item.id.toString(),
        );
      },
    );
  }

  Widget _buildInventoryCard({
    required String name,
    required String price,
    required String frequency,
    required String assignedTo,
    required int stock,
    required String id,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLow = stock < 5;

    return DashboardCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      border: Border.all(
        color: isLow
            ? AppColors.error.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isLow
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$stock ${'stock'.tr()}',
                  style: TextStyle(
                    color: isLow ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${'price'.tr()}: $price',
            style: const TextStyle(color: AppColors.almostBlack300),
          ),
          Text(
            '${'frequency'.tr()}: $frequency',
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 13,
            ),
          ),
          Text(
            '${'assigned'.tr()}: $assignedTo',
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 13,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: Text("edit".tr()),
                onPressed: () {},
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.delete,
                  size: 16,
                  color: AppColors.error,
                ),
                label: Text(
                  "delete".tr(),
                  style: const TextStyle(color: AppColors.error),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = [
      'tools'.tr(),
      'shared'.tr(),
      'product'.tr(),
    ][_tabController.index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'add_new'.tr()} $type${'item'.tr()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildInputField(
                    'name'.tr(),
                    Icons.inventory_2_rounded,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    'price'.tr(),
                    Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                    controller: _priceController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    'stock'.tr(),
                    Icons.storage_rounded,
                    keyboardType: TextInputType.number,
                    controller: _stockController,
                  ),
                  const SizedBox(height: 16),
                  if (type == 'Staff')
                    _buildInputField(
                      'assigned_tools'.tr(),
                      Icons.person_rounded,
                      controller: _toolsController,
                    ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    'description'.tr(),
                    Icons.description_rounded,
                    maxLines: 3,
                    controller: _notesController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: PrimaryButton(
                text: 'save_item'.tr(),
                onPressed: () async {
                  final salonId = context.read<AuthProvider>().user?.salonId;
                  if (salonId != null) {
                    try {
                      final String mappedCategory = type == 'Staff'
                          ? 'personal_kit'.tr()
                          : (type == 'Shared'
                                ? 'consumables'.tr()
                                : 'general'.tr());

                      await context.read<InventoryProvider>().addInventoryItem(
                        productName: _nameController.text.trim(),
                        productPrice:
                            double.tryParse(_priceController.text) ?? 0.0,
                        category: mappedCategory,
                        salonId: salonId,
                        initialQuantity:
                            int.tryParse(_stockController.text) ?? 0,
                        notes: _notesController.text,
                      );
                      Navigator.pop(context);
                      _nameController.clear();
                      _priceController.clear();
                      _stockController.clear();
                      _notesController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('item_added_successfully'.tr())),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${'error'.tr()}: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.almostBlack300,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.white.withValues(alpha: 0.05)
                : AppColors.almostBlack50.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
