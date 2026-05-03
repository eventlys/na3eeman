import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../salon/widgets/inventory_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class ToolsAndInventoryPage extends StatefulWidget {
  final String? initialCategory;
  const ToolsAndInventoryPage({super.key, this.initialCategory});

  @override
  State<ToolsAndInventoryPage> createState() => _ToolsAndInventoryPageState();
}

class _ToolsAndInventoryPageState extends State<ToolsAndInventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialCategory == 'CONSUMABLE') {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Tools & Inventory'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButtonStyled(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Personal Kit'.tr()),
            Tab(text: 'Consumables'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InventoryManager(
            currentUser: authProvider.user?.toJson() ?? {},
            category: 'EQUIPMENT',
          ),
          InventoryManager(
            currentUser: authProvider.user?.toJson() ?? {},
            category: 'CONSUMABLE',
          ),
        ],
      ),
    );
  }
}
