import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class StaffSchedulesPage extends StatefulWidget {
  const StaffSchedulesPage({super.key});

  @override
  State<StaffSchedulesPage> createState() => _StaffSchedulesPageState();
}

class _StaffSchedulesPageState extends State<StaffSchedulesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Staff Schedules', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Tomorrow'),
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleList('Today'),
          _buildScheduleList('Tomorrow'),
          _buildScheduleList('This Week'),
          _buildScheduleList('This Month'),
        ],
      ),
    );
  }

  Widget _buildScheduleList(String period) {
    // Mocking staff for now, including availability states
    final List<Map<String, dynamic>> staff = [
      {'name': 'Karim', 'role': 'Master Expert', 'status': 'Busy', 'color': AppColors.error, 'tasks': '3 remain'},
      {'name': 'Jafar', 'role': 'Senior Expert', 'status': 'Available', 'color': AppColors.success, 'tasks': 'Next @ 2 PM'},
      {'name': 'Yousif', 'role': 'Expert', 'status': 'On Break', 'color': AppColors.warning, 'tasks': 'Back in 15m'},
      {'name': 'Ali', 'role': 'Intern', 'status': 'Available', 'color': AppColors.success, 'tasks': 'Ready to help'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: staff.length,
      itemBuilder: (context, index) {
        final s = staff[index];
        final Color statusColor = s['color'] as Color;
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    child: Text((s['name'] as String)[0], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.almostBlack600 : Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              subtitle: Text(s['role'] as String, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(s['status'] as String, style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 12)),
                  Text(s['tasks'] as String, style: const TextStyle(color: AppColors.almostBlack200, fontSize: 10)),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      const Text('Full Day Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 16),
                      _buildTimelineItem('09:00 AM', 'Opening Prep', true),
                      _buildTimelineItem('10:30 AM', 'Classic Haircut - Mike Johnson', false, isOccupied: true),
                      _buildTimelineItem('11:45 AM', 'Beard Trim - Sarah (Gift)', false, isOccupied: true),
                      _buildTimelineItem('01:00 PM', 'Lunch Break', false, isBreak: true),
                      _buildTimelineItem('02:15 PM', 'Available Slot', false),
                      _buildTimelineItem('03:30 PM', 'Spa Session - Karim Ali', false, isOccupied: true),
                      _buildTimelineItem('05:00 PM', 'Available Slot', false, isLast: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(String time, String detail, bool isFirst, {bool isOccupied = false, bool isBreak = false, bool isLast = false}) {
    final Color indicatorColor = isOccupied ? AppColors.error : (isBreak ? AppColors.warning : AppColors.success);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: indicatorColor.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: indicatorColor.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                detail, 
                style: TextStyle(
                  fontSize: 12, 
                  color: isOccupied || isBreak ? null : AppColors.almostBlack300,
                  fontWeight: isOccupied || isBreak ? FontWeight.w600 : FontWeight.normal,
                )
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
