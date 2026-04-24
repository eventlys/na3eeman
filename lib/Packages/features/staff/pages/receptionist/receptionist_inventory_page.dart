import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class ReceptionistInventoryPage extends StatefulWidget {
  final bool startWithStaff;
  const ReceptionistInventoryPage({super.key, this.startWithStaff = true});

  @override
  State<ReceptionistInventoryPage> createState() => _ReceptionistInventoryPageState();
}

class _ReceptionistInventoryPageState extends State<ReceptionistInventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.startWithStaff ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventoryManagement, style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Staff Inventory'),
            Tab(text: 'Shared Inventory'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: AppColors.almostBlack300,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventoryList(isStaff: true),
          _buildInventoryList(isStaff: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInventoryItemModal(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addItem),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInventoryList({required bool isStaff}) {
    // Scaffold list placeholder with mock items matching requirements fields
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInventoryCard(
          name: isStaff ? 'Disposable Hair Cape' : 'Premium Towels',
          price: '\$5.00',
          frequency: 'Monthly',
          assignedTo: isStaff ? 'Jafar' : 'Shared',
          stock: 12,
        ),
        _buildInventoryCard(
          name: isStaff ? 'Moustache Wax' : 'Hair Cream Bulk',
          price: '\$15.00',
          frequency: 'Weekly',
          assignedTo: isStaff ? 'Karim' : 'Shared',
          stock: 4,
        ),
      ],
    );
  }

  Widget _buildInventoryCard({
    required String name,
    required String price,
    required String frequency,
    required String assignedTo,
    required int stock,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLow = stock < 5;

    return DashboardCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: isLow ? AppColors.error.withOpacity(0.3) : Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: isLow ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$stock in stock',
                  style: TextStyle(color: isLow ? AppColors.error : AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Price: $price', style: const TextStyle(color: AppColors.almostBlack300)),
          Text('Frequency: $frequency', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
          Text('Assigned: $assignedTo', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 13)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(icon: Icon(Icons.edit, size: 16), label: Text(AppLocalizations.of(context)!.edit), onPressed: () {}),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 16, color: AppColors.error), 
                label: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: AppColors.error)), 
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddInventoryItemModal(BuildContext context) {
    // Full form fields support implementation step
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Inventory Modal flow trigger...')));
  }
}
