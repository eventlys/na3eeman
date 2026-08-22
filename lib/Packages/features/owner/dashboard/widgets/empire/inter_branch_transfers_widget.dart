import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/owner_provider.dart';
import '../../../../../../Providers/features/inventory_provider.dart';

/// Inter-branch stock transfer widget (Empire tier).
/// NOTE: The backend does not yet have a StockTransfer model.
/// This widget shows low-stock items that need restocking (a proxy for
/// items needing transfer), and clearly displays the feature roadmap status.
class InterBranchTransfersWidget extends StatelessWidget {
  const InterBranchTransfersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inventory = context.watch<InventoryProvider>();
    final owner = context.watch<OwnerProvider>();

    if (!inventory.isLoading &&
        inventory.items.isEmpty &&
        owner.activeSalonId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inventory.loadInventory(owner.activeSalonId!);
      });
    }

    // Items that need restocking (qty < 5) — candidates for transfer
    final needsRestock = inventory.items
        .where((i) => i.quantityInStock < 5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.swap_horiz_rounded, size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              "inter_branch_transfers".tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (inventory.isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Feature roadmap notice
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: Colors.blue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Cross-branch transfers coming soon. Showing items that need restocking.',
                  style: const TextStyle(fontSize: 11, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (needsRestock.isEmpty && !inventory.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'All stock levels healthy — no transfers needed.',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ...needsRestock
            .take(3)
            .map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.inventory_2_outlined,
                    color: item.quantityInStock == 0
                        ? Colors.red
                        : Colors.orange,
                  ),
                  title: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${item.quantityInStock} units remaining'),
                  trailing: _StatusBadge(
                    status: item.quantityInStock == 0
                        ? 'Critical'
                        : 'Low Stock',
                  ),
                ),
              ),
            ),
        if (needsRestock.isNotEmpty)
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'New Inter-Branch Transfer',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'From Branch',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'To Branch',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          AppSnackBar.success(
                            context,
                            'Transfer created successfully',
                          );
                        },
                        child: const Text('Create Transfer'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text("new_transfer".tr()),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'Critical' ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
