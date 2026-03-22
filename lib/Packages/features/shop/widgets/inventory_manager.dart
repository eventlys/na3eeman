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

  int? _lastLoadedShopId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final shopId = authProvider.user?.shopId;

    if (shopId != null && shopId != _lastLoadedShopId) {
      _lastLoadedShopId = shopId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadItems();
      });
    }
  }

  Future<void> _loadItems({String? category}) async {
    if (!mounted) return;
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    int? shopId = widget.currentUser['shop'] as int?;
    if (shopId == null) {
      shopId = authProvider.user?.shopId;
    }

    if (shopId == null) {
      print('InventoryManager: Skipping load items because shopId is null');
      return;
    }

    await inventoryProvider.loadInventoryItems(
      shopId: shopId,
      category: category ?? widget.category,
    );
  }

  Future<void> _increaseItemCount(Map<String, dynamic> item, BuildContext context) async {
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final inventoryService = Provider.of<InventoryService>(context, listen: false);

    try {
      final currentCount = item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
      final itemId = item['id']?.toString() ?? item['_id']?.toString();

      if (itemId == null) {
        throw Exception('Item ID not found');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final shopId = authProvider.user?.shopId;

      await inventoryService.updateItemQuantity(
        itemId: itemId,
        shopId: shopId ?? 1, // Fallback if needed, but it should be available
        newQuantity: currentCount + 1,
        reason: 'Manual count increase',
      );

      // Refresh the inventory
      await _loadItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Increased ${item['name']} count to ${currentCount + 1}'),
            backgroundColor: AppColor.lightSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update ${item['name']}: ${e.toString()}'),
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
        final shopId = result['shopId'] ?? (widget.currentUser['shop'] as int?);
        if (shopId == null) {
          throw Exception('Shop ID is missing. Cannot add inventory item.');
        }
        
        await inventoryService.addInventoryItem(
          productId: result['productId'] ?? 0,
          shopId: shopId,
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
        title: Text(
          'Delete Item',
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
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
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
    final shopId = authProvider.user?.shopId ?? widget.currentUser['shop'] as int?;

    if (isCustomer) {
      return Center(
        child: Text(
          'Inventory management is only available for owners',
          style: TextStyle(
            fontSize: 16,
            color: AppColor.lightTextSecondary
          ),
        ),
      );
    }

    if (shopId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColor.lightPrimary),
              const SizedBox(height: 16),
              Text(
                'Initializing shop details...',
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
                          Text(
                            'Inventory Management',
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
                              Text(
                                'Failed to load inventory',
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
                                child: Text(
                                  'Retry',
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
                                Text(
                                  'No items in inventory',
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
