import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../core/widgets/notifications/notifications_bottom_sheet.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../shop/widgets/inventory_manager.dart'; // Added
import 'package:intl/intl.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/api/endpoints.dart';
// import '../../appointments/widgets/appointments_list.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Waiting', 'Pending Payment'];
  List<Map<String, dynamic>> _todayAppointments = [];

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    sidebarController.toggleSidebar();
  }

  void _loadData() async {
    // Load Inventory items
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadInventoryItems(shopId: authProvider.user?.shopId);

    // Fetch appointments from Backend
    try {
      final apiService = ApiService();
      final response = await apiService.get(Endpoints.appointments);
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];
      
      final today = DateTime.now();
      final todayAppts = data.where((appt) {
        final start = DateTime.parse(appt['start_time']);
        return start.year == today.year && start.month == today.month && start.day == today.day;
      }).toList();

      setState(() {
        _todayAppointments = todayAppts.map((appt) {
          final customer = appt['customer'] as Map<String, dynamic>?;
          return {
            'id': appt['id']?.toString() ?? '',
            'customerName': customer != null ? '${customer['first_name']} ${customer['last_name']}' : 'Anonymous',
            'time': DateFormat('hh:mm A').format(DateTime.parse(appt['start_time'])),
            'startTime': DateTime.parse(appt['start_time']),
            'endTime': DateTime.parse(appt['end_time']),
            'service': 'Haircut',
            'status': appt['payment_status'] == 'PENDING' ? 'Pending Payment' :
                     appt['status'] == 'CHECKED_IN' ? 'Waiting' : 
                     appt['status'] == 'COMPLETED' ? 'Completed' : 'Scheduled',
            'statusColor': _getStatusColor(appt['status'] ?? 'Scheduled'),
            'customerId': customer != null ? customer['id'] : 0,
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading grid appointments: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED': return AppColors.warning;
      case 'CHECKED_IN': return AppColors.pink;
      case 'COMPLETED': return AppColors.success;
      default: return AppColors.warning;
    }
  }

  Future<void> _handleCompleteAppointment(String id) async {
    setState(() {
      _todayAppointments.firstWhere((appt) => appt['id'] == id)['status'] = 'Done';
      _todayAppointments.firstWhere((appt) => appt['id'] == id)['statusColor'] = AppColors.success;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment completed successfully'), backgroundColor: AppColors.success));
  }

  Future<void> _handlePenaltyAppointment(String id, int customerId, String reason) async {
    setState(() {
      _todayAppointments.firstWhere((appt) => appt['id'] == id)['status'] = reason;
      _todayAppointments.firstWhere((appt) => appt['id'] == id)['statusColor'] = AppColors.error;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$reason! Customer points reduced by 20 points'), backgroundColor: AppColors.error));
  }

  void _navigateInventory(String? category) {
    final authProvider = context.read<AuthProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: InventoryManager(
            currentUser: authProvider.user?.toJson() ?? {},
            category: category,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${user?.specialization ?? "Staff"} Dashboard', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButtonStyled(
          icon: Icons.menu_rounded,
          onPressed: _toggleSidebar,
        ),
        actions: [
          IconButtonStyled(
            icon: Icons.notifications_none_rounded,
            onPressed: () => NotificationsBottomSheet.show(context),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Hello, ${user?.firstName ?? "Member"}! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You have ${_todayAppointments.length} appointments scheduled for today.',
                style: TextStyle(color: isDark ? AppColors.cream600 : AppColors.almostBlack300),
              ),
              
              const SizedBox(height: 32),

              // Active Appointment Banner
              if (_todayAppointments.any((appt) => appt['status'] != 'Done' && appt['status'] != 'Canceled' && appt['status'] != 'Too Late' && DateTime.now().isAfter(appt['startTime']) && DateTime.now().isBefore(appt['endTime']))) ...[
                Builder(
                  builder: (context) {
                    final activeAppointment = _todayAppointments.firstWhere(
                      (appt) => appt['status'] != 'Done' && appt['status'] != 'Canceled' && appt['status'] != 'Too Late' && DateTime.now().isAfter(appt['startTime']) && DateTime.now().isBefore(appt['endTime'])
                    );
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Text('ACTIVE NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          Text(activeAppointment['customerName'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('${activeAppointment['time']} • ${activeAppointment['service']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _handleCompleteAppointment(activeAppointment['id'] as String),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).primaryColor),
                                  child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _handlePenaltyAppointment(activeAppointment['id'] as String, activeAppointment['customerId'] as int, 'Canceled'),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _handlePenaltyAppointment(activeAppointment['id'] as String, activeAppointment['customerId'] as int, 'Too late'),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                                  child: const Text('Too late'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ],

              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildSummaryCard('Today\'s Profit', '\$120.00', Icons.account_balance_wallet_rounded, AppColors.success)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard('Completed', '${_todayAppointments.where((a) => a['status'] == 'Done').length}', Icons.check_circle_rounded, Theme.of(context).primaryColor)),
                ],
              ),

              const SizedBox(height: 32),

              // Appointment States Section
              _buildSectionHeader('Today\'s Appointments', () {
                Navigator.pushNamed(context, '/appointments');
              }),
              const SizedBox(height: 16),
              _buildAppointmentStatesFilter(),
              const SizedBox(height: 12),
              
              ..._todayAppointments.where((appt) => _selectedFilter == 'All' ? appt['status'] != 'Done' : appt['status'] == _selectedFilter).map((appt) => _buildAppointmentItem(
                    appt['customerName'] as String,
                    appt['time'] as String,
                    appt['service'] as String,
                    appt['status'] as String,
                    appt['statusColor'] as Color,
                  )),

              const SizedBox(height: 32),

              // Inventory & Tools Section
              _buildSectionHeader('Tools & Inventory', () {}),
              const SizedBox(height: 16),
              Consumer<InventoryProvider>(
                builder: (context, inventoryProvider, child) {
                  final lowStockConsumables = inventoryProvider.inventoryItems.where((item) {
                    final category = item['category'] ?? (item['product'] is Map ? item['product']['category'] : null);
                    final stock = item['quantity_in_stock'] ?? 0;
                    return category == 'Consumables' && stock <= 2;
                  }).toList();

                  final kitItems = inventoryProvider.inventoryItems.where((item) {
                    final category = item['category'] ?? (item['product'] is Map ? item['product']['category'] : null);
                    return category == 'Personal Kit';
                  }).toList();

                  final consumablesAlert = lowStockConsumables.isNotEmpty
                      ? 'Low Stock: ${lowStockConsumables.first['product_name'] ?? (lowStockConsumables.first['product'] is Map ? lowStockConsumables.first['product']['product_name'] : 'Item')}'
                      : 'All items stocked';

                  final kitReady = kitItems.where((item) => (item['quantity_in_stock'] ?? 0) > 0).length;
                  final kitTotal = kitItems.length;
                  final kitSubtitle = kitTotal > 0 ? '$kitReady/$kitTotal Items Ready' : 'No items added';

                  return Column(
                    children: [
                      _buildToolCard(
                        'Personal Kit',
                        kitSubtitle,
                        Icons.handyman_rounded,
                        onTap: () => _navigateInventory('Personal Kit'),
                      ),
                      const SizedBox(height: 12),
                      _buildToolCard(
                        'Consumables',
                        consumablesAlert,
                        Icons.inventory_2_rounded,
                        isAlert: lowStockConsumables.isNotEmpty,
                        onTap: () => _navigateInventory('Consumables'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
        ),
        Sidebar(controller: sidebarController),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onSeeAll, child: Text('View List', style: TextStyle(color: Theme.of(context).primaryColor))),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAppointmentStatesFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) => _buildFilterChip(filter, _selectedFilter == filter)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? AppColors.white : Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(String name, String time, String service, String status, Color statusColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$time • $service', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(String title, String subtitle, IconData icon, {bool isAlert = false, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isAlert ? AppColors.error.withOpacity(0.3) : (isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isAlert ? AppColors.error : Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: isAlert ? AppColors.error : AppColors.almostBlack300, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.almostBlack200),
          ],
        ),
      ),
    );
  }
}
