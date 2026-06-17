import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/staff_provider.dart';
import '../../../../Providers/features/appointment_provider.dart';

class StaffSchedulesPage extends StatefulWidget {
  const StaffSchedulesPage({super.key});

  @override
  State<StaffSchedulesPage> createState() => _StaffSchedulesPageState();
}

class _StaffSchedulesPageState extends State<StaffSchedulesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StaffProvider>(context, listen: false).loadStaffData();
      Provider.of<AppointmentProvider>(
        context,
        listen: false,
      ).loadAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'staff_schedules'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          tabs: [
            Tab(text: 'today'.tr()),
            Tab(text: 'tomorrow'.tr()),
            Tab(text: 'this_week'.tr()),
            Tab(text: 'this_month'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScheduleList('today'.tr()),
          _buildScheduleList('tomorrow'.tr()),
          _buildScheduleList('this_week'.tr()),
          _buildScheduleList('this_month'.tr()),
        ],
      ),
    );
  }

  Widget _buildScheduleList(String period) {
    return Consumer2<StaffProvider, AppointmentProvider>(
      builder: (context, staffProvider, appointmentProvider, child) {
        if (staffProvider.isLoading || appointmentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final staffList = staffProvider.staff;
        if (staffList.isEmpty) {
          return Center(child: Text('no_staff_found'.tr()));
        }

        final now = DateTime.now();
        final appointments = appointmentProvider.appointments.where((a) {
          if (period == 'Today') {
            return a.startTime.year == now.year &&
                a.startTime.month == now.month &&
                a.startTime.day == now.day;
          } else if (period == 'Tomorrow') {
            final tomorrow = now.add(const Duration(days: 1));
            return a.startTime.year == tomorrow.year &&
                a.startTime.month == tomorrow.month &&
                a.startTime.day == tomorrow.day;
          } else if (period == 'This Week') {
            final endOfWeek = now.add(Duration(days: 7 - now.weekday));
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            return a.startTime.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                a.startTime.isBefore(endOfWeek.add(const Duration(days: 1)));
          } else {
            return a.startTime.year == now.year &&
                a.startTime.month == now.month;
          }
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: staffList.length,
          itemBuilder: (context, index) {
            final staff = staffList[index];
            final staffAppointments =
                appointments.where((a) => a.expertId == staff.userId).toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));

            Color statusColor = AppColors.success;
            if (staff.status == 'BUSY') {
              statusColor = AppColors.error;
            } else if (staff.status == 'BREAK')
              statusColor = AppColors.warning;

            final isDark = Theme.of(context).brightness == Brightness.dark;

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
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        child: Text(
                          staff.name.isNotEmpty
                              ? staff.name[0].toUpperCase()
                              : 'S',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
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
                            border: Border.all(
                              color: isDark
                                  ? AppColors.almostBlack600
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    staff.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    staff.role.name,
                    style: const TextStyle(
                      color: AppColors.almostBlack300,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        staff.status ?? 'AVAILABLE'.tr(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${staffAppointments.length} tasks',
                        style: const TextStyle(
                          color: AppColors.almostBlack200,
                          fontSize: 10,
                        ),
                      ),
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
                          Text(
                            'Full Day Timeline'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (staffAppointments.isEmpty)
                            Text(
                              'No appointments'.tr(),
                              style: const TextStyle(
                                color: AppColors.almostBlack300,
                                fontSize: 12,
                              ),
                            ),
                          ...staffAppointments.asMap().entries.map((entry) {
                            final appt = entry.value;
                            final isLast =
                                entry.key == staffAppointments.length - 1;
                            final timeStr = DateFormat(
                              'hh:mm a',
                            ).format(appt.startTime);
                            return _buildTimelineItem(
                              timeStr,
                              'Appointment #${appt.id}',
                              entry.key == 0,
                              isOccupied: true,
                              isLast: isLast,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(
    String time,
    String detail,
    bool isFirst, {
    bool isOccupied = false,
    bool isBreak = false,
    bool isLast = false,
  }) {
    final Color indicatorColor = isOccupied
        ? AppColors.error
        : (isBreak ? AppColors.warning : AppColors.success);

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
                  BoxShadow(
                    color: indicatorColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
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
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 12,
                  color: isOccupied || isBreak
                      ? null
                      : AppColors.almostBlack300,
                  fontWeight: isOccupied || isBreak
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
