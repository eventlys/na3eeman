import 'package:flutter/material.dart';
import 'inventory_list_item.dart';
import 'low_stock_alert.dart';

class InventoryManager extends StatefulWidget {
  final User currentUser;

  const InventoryManager({super.key, required this.currentUser});

  @override
  InventoryManagerState createState() => InventoryManagerState();
}

class InventoryManagerState extends State<InventoryManager> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<InventoryItem>> _inventoryFuture;
  List<InventoryItem> _inventoryItems = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  void _loadInventory() {
    setState(() {
      _inventoryFuture = _inventoryService.getInventoryItems();
    });
  }

  Future<void> _increaseItemCount(InventoryItem item) async {
    try {
      final updatedItem = await _inventoryService.updateItemCount(
        item.id,
        item.count + 1
      );

      setState(() {
        final index = _inventoryItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _inventoryItems[index] = updatedItem;
        }
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Increased ${item.name} count to ${updatedItem.count}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update ${item.name}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addNewItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );

    if (result != null) {
      try {
        final newItem = await _inventoryService.addItem(
          result['name']!,
          initialCount: result['count'],
          description: result['description'],
        );

        setState(() {
          _inventoryItems.add(newItem);
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${newItem.name} to inventory'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _inventoryService.deleteItem(item.id);
        setState(() {
          _inventoryItems.removeWhere((i) => i.id == item.id);
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${item.name} from inventory'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ${item.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.currentUser.isCustomer) {
      return const Center(
        child: Text(
          'Inventory management is only available for owners',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }


    return Stack(
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.90,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x4dffffff),
              border: Border.all(color: const Color(0x80ffffff)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FutureBuilder<List<InventoryItem>>(
              future: _inventoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200, // Fixed height for loading state
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: 300, // Fixed height for error state
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/icons/error_icon.png', width: 64, height: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load inventory',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadInventory,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                _inventoryItems = snapshot.data ?? [];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title and refresh
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: const Color(0x80ffffff))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Inventory Management',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: Image.asset('assets/icons/moon.png', width: 24, height: 24),
                            onPressed: _loadInventory,
                            tooltip: 'Refresh Inventory',
                          ),
                        ],
                      ),
                    ),

                    LowStockAlert(items: _inventoryItems),

                    // Use Flexible instead of ConstrainedBox for better layout control
                    if (_inventoryItems.isNotEmpty)
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _inventoryItems.length,
                          itemBuilder: (context, index) {
                            final item = _inventoryItems[index];
                            return InventoryListItem(
                              item: item,
                              onIncreaseCount: () => _increaseItemCount(item),
                              onDelete: () => _deleteItem(item),
                            );
                          },
                        ),
                      )
                    else
                      SizedBox(
                        height: 200, // Fixed height for empty state
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/icons/inventory_icon.png', width: 64, height: 64),
                              const SizedBox(height: 16),
                              Text(
                                'No items in inventory',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: MediaQuery.of(context).size.width * 0.10, // Adjust based on your container width
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF806C99), Color(0x80DFA8A4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              // boxShadow: [
              //   BoxShadow(
              //     color: Color(0x80000000),
              //     blurRadius: 4,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            ),
            child: IconButton(
              onPressed: _addNewItem,
              icon: Image.asset('assets/icons/plus.png', width: 40, height: 40),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

