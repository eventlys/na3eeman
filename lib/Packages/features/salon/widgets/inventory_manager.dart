import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/business_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../overlays/Inventory_add_item_dialog.dart';
import 'inventory_list_item.dart';
import 'inventory_low_stock_alert.dart';
// import 'low_stock_alert.dart';

class InventoryManager extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final String? category;

  const InventoryManager({super.key, required this.currentUser, this.category});

  @override
  InventoryManagerState createState() => InventoryManagerState();
}

class InventoryManagerState extends State<InventoryManager> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  int? _lastLoadedSalonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final salonId = authProvider.user?.salonId;

    if (salonId != null && salonId != _lastLoadedSalonId) {
      _lastLoadedSalonId = salonId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadItems();
      });
    }
  }

  Future<void> _loadItems({String? category}) async {
    if (!mounted) return;
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    int? salonId = widget.currentUser['salon'] as int?;
    salonId ??= authProvider.user?.salonId;

    if (salonId == null) {
      print('InventoryManager: Skipping load items because salonId is null');
      return;
    }

    await inventoryProvider.loadInventoryItems(
      salonId: salonId,
      category: category ?? widget.category,
    );
  }

  Future<void> _increaseItemCount(Map<String, dynamic> item, BuildContext context) async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final inventoryService = Provider.of<InventoryService>(context, listen: false);

    try {
      final currentCount = item['quantityInStock'] ?? item['quantity_in_stock'] ?? item['current_stock'] ?? 0;
      final itemId = item['id']?.toString() ?? item['_id']?.toString();
      final itemName = item['product_name'] ?? item['name'] ?? 'Item';

      if (itemId == null) {
        throw Exception('Item ID not found');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final salonId = authProvider.user?.salonId;

      await inventoryService.updateItemQuantity(
        itemId: itemId,
        salonId: salonId ?? 1, // Fallback if needed, but it should be available
        newQuantity: currentCount + 1,
        reason: 'Manual count increase',
      );

      // Refresh the inventory
      await _loadItems();

      if (mounted) {
        final itemName = item['product_name'] ?? item['name'] ?? 'Item';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Increased $itemName count to ${currentCount + 1}'),
            backgroundColor: AppColor.lightSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final itemName = item['product_name'] ?? item['name'] ?? 'Item';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $itemName: ${e.toString()}'),
            backgroundColor: AppColor.lightError,
          ),
        );
      }
    }
  }

  Future<void> _addNewItem(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );

    if (result != null) {
      final inventoryService = Provider.of<InventoryService>(context, listen: false);
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

      try {
        final salonId = result['salonId'] ?? (widget.currentUser['salon'] as int?);
        if (salonId == null) {
          throw Exception('Salon ID is missing. Cannot add inventory item.');
        }
        
        await inventoryService.addInventoryItem(
          productId: result['productId'] ?? 0,
          salonId: salonId,
          initialQuantity: result['count'] ?? 1,
          notes: result['description'],
        );

        // Refresh inventory
        await _loadItems();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${result['name']} to inventory'),
              backgroundColor: AppColor.lightSuccess,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add item: ${e.toString()}'),
              backgroundColor: AppColor.lightError,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteItem(Map<String, dynamic> item, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_item".tr(),
          style: TextStyle(color: AppColor.lightText),
        ),
        backgroundColor: AppColor.lightCard,
        content: Text(
          'Are you sure you want to delete ${item['name']}?',
          style: TextStyle(color: AppColor.lightTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("cancel".tr(),
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("delete".tr(),
              style: TextStyle(color: AppColor.lightError)
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);

      try {
        final itemId = item['id']?.toString() ?? item['_id']?.toString();

        if (itemId != null) {
          await inventoryProvider.removeItem(itemId);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deleted ${item['name']} from inventory'),
                backgroundColor: AppColor.lightSuccess,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${item['name']}: ${e.toString()}'),
              backgroundColor: AppColor.lightError,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    final isCustomer = currentUser['role'] == 'customer' || currentUser['isCustomer'] == true;

    final authProvider = Provider.of<AuthProvider>(context);
    final salonId = authProvider.user?.salonId ?? widget.currentUser['salon'] as int?;

    if (isCustomer) {
      return Center(
        child: Text("inventory_management_is_only_available_for_owners".tr(),
          style: TextStyle(
            fontSize: 16,
            color: AppColor.lightTextSecondary
          ),
        ),
      );
    }

    if (salonId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_mall_directory_outlined, size: 64, color: AppColor.lightTextSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                'No Salon Assigned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please ensure your salon is fully set up and linked to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColor.lightTextSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final inventoryItems = inventoryProvider.inventoryItems;

        return Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.buttonBackgroundLight,
                  border: Border.all(color: AppColor.borderLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title and refresh
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColor.borderLight)
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("inventory_management".tr(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.lightText,
                                ),
                          ),
                          IconButton(
                            icon: Image.asset(
                              AppImages.refresh,
                              width: 24,
                              height: 24,
                              color: AppColor.lightPrimary,
                            ),
                            onPressed: () => _loadItems(),
                            tooltip: 'Refresh Inventory',
                          ),
                        ],
                      ),
                    ),

                    if (inventoryProvider.isLoading)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColor.loadingPrimaryLight),
                          ),
                        ),
                      )
                    else if (inventoryProvider.error != null)
                      SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.error,
                                width: 64,
                                height: 64,
                                color: AppColor.lightError,
                              ),
                              const SizedBox(height: 16),
                              Text("failed_to_load_inventory".tr(),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColor.lightText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  inventoryProvider.error!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColor.lightTextSecondary,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadItems(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.lightPrimary,
                                ),
                                child: Text("retry".tr(),
                                  style: TextStyle(color: AppColor.light),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      LowStockSimpleAlert(items: inventoryItems),

                      // Inventory List
                      if (inventoryItems.isNotEmpty)
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: inventoryItems.length,
                            itemBuilder: (context, index) {
                              final item = inventoryItems[index];
                              return InventoryListItem(
                                item: item,
                                onIncreaseCount: () => _increaseItemCount(item, context),
                                onDelete: () => _deleteItem(item, context),
                              );
                            },
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.inventory,
                                  width: 64,
                                  height: 64,
                                  color: AppColor.lightTextSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text("no_items_in_inventory".tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColor.lightTextSecondary
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: MediaQuery.of(context).size.width * 0.10,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.gradientStartLight, AppColor.gradientSecondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _addNewItem(context),
                  icon: Image.asset(
                    AppImages.plus,
                    width: 40,
                    height: 40,
                    color: AppColor.light,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColor.light,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
