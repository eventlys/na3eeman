import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Providers/features/auth_provider.dart';
import '../../../../Providers/features/schedule_provider.dart';
import '../../../../Models/staff/weekly_working_hours.dart';

class MyTimesPage extends StatefulWidget {
  const MyTimesPage({super.key});

  @override
  State<MyTimesPage> createState() => _MyTimesPageState();
}

class _MyTimesPageState extends State<MyTimesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      await context.read<ScheduleProvider>().fetchWorkingHours(
        expertId: auth.user!.id,
      );
      await context.read<ScheduleProvider>().fetchPTORequests();
    }
    if (mounted) setState(() => _isInitialLoad = false);
  }

  Future<void> _toggleDay(WeeklyWorkingHours hours) async {
    final provider = context.read<ScheduleProvider>();
    final success = await provider.updateWorkingHours(hours.id!, {
      'is_closed': !hours.isClosed,
    });

    if (success) {
      _fetchData();
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    WeeklyWorkingHours hours,
    bool isStart,
  ) async {
    final initialTime = isStart
        ? _parseTime(hours.openingTime)
        : _parseTime(hours.closingTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final success = await context.read<ScheduleProvider>().updateWorkingHours(
        hours.id!,
        {isStart ? 'opening_time' : 'closing_time': newTime},
      );

      if (success) {
        _fetchData();
      }
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 10, minute: 0);
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2024, 1, 1, hour, minute);
      return DateFormat.jm().format(dt);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'my_times'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
            Tab(text: 'weekly_schedule'.tr()),
            Tab(text: 'request_off_time'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWeeklySchedule(isDark), _buildPTORequest(isDark)],
      ),
    );
  }

  Widget _buildWeeklySchedule(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'weekly_availabile'.tr(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'hours_management_description'.tr(),
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),

          // Schedule List
          Consumer<ScheduleProvider>(
            builder: (context, schedule, _) {
              if (schedule.isLoading && _isInitialLoad) {
                return const Center(child: CircularProgressIndicator());
              }

              if (schedule.workingHours.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text('no_schedule_found'.tr()),
                  ),
                );
              }

              return Column(
                children: schedule.workingHours.map((hours) {
                  final isOn = !hours.isClosed;
                  final start = _formatTime(hours.openingTime);
                  final end = _formatTime(hours.closingTime);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.almostBlack600
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.05)
                            : AppColors.almostBlack50,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hours.dayName.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOn ? '$start - $end' : 'off_day'.tr(),
                                style: TextStyle(
                                  color: isOn
                                      ? Theme.of(context).primaryColor
                                      : AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: isOn
                              ? Row(
                                  children: [
                                    _timeChip(
                                      start,
                                      () => _selectTime(context, hours, true),
                                      isDark,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text('-'),
                                    ),
                                    _timeChip(
                                      end,
                                      () => _selectTime(context, hours, false),
                                      isDark,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: isOn,
                          onChanged: (val) => _toggleDay(hours),
                          activeThumbColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('schedule_updated_successfully'.tr()),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'save_changes'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeChip(String time, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack700 : AppColors.almostBlack50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPTORequest(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'paid_time_off_pto'.tr(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'request_time_off_description'.tr(),
            style: const TextStyle(
              color: AppColors.almostBlack300,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 32),

          _buildPTOCard(
            title: 'single_day_off'.tr(),
            subtitle: 'request_a_full_day_off_description'.tr(),
            icon: Icons.calendar_today_rounded,
            onTap: () => _showPTODialog(context, 1),
            isDark: isDark,
          ),
          _buildPTOCard(
            title: 'date_range'.tr(),
            subtitle: 'select_multiple_days_description'.tr(),
            icon: Icons.date_range_rounded,
            onTap: () => _showPTODialog(context, 2),
            isDark: isDark,
          ),
          _buildPTOCard(
            title: 'immediate_leave'.tr(),
            subtitle: 'leave_from_now_until_the_end_of_the_day'.tr(),
            icon: Icons.bolt_rounded,
            onTap: () => _showPTODialog(context, 3),
            isDark: isDark,
          ),
          _buildPTOCard(
            title: 'specific_time_range'.tr(),
            subtitle: 'request_a_few_hours_off_during_the_day'.tr(),
            icon: Icons.timer_rounded,
            onTap: () => _showPTODialog(context, 4),
            isDark: isDark,
          ),

          const SizedBox(height: 32),
          Text(
            'request_history'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          Consumer<ScheduleProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && _isInitialLoad) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = provider.ptoRequests;
              if (requests.isEmpty) {
                return Center(
                  child: Text(
                    'no_requests_found'.tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final req = requests[index];
                  final status = req['status'] ?? 'PENDING';
                  final Color statusColor = status == 'APPROVED'
                      ? AppColors.success
                      : (status == 'REJECTED'
                            ? AppColors.error
                            : AppColors.warning);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.almostBlack600
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.05)
                            : AppColors.almostBlack50,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getPTOHeaderFromScenario(req['scenario']).tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${req['start_date']} ${req['start_time'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.tr(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _getPTOHeaderFromScenario(String? scenario) {
    return switch (scenario) {
      'SINGLE_DAY' => 'Single Day Off',
      'DATE_RANGE' => 'Date Range',
      'IMMEDIATE' => 'Immediate Leave',
      'TIME_WINDOW' => 'Specific Time Range',
      _ => 'PTO Request',
    };
  }

  Widget _buildPTOCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.almostBlack50,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.almostBlack300),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  void _showPTODialog(BuildContext context, int scenario) {
    final reasonController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(_getPTOHeader(scenario).tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (scenario == 1 || scenario == 4)
                  ListTile(
                    title: Text(
                      startDate == null
                          ? 'select_date'.tr()
                          : DateFormat('MMM dd, yyyy').format(startDate!),
                    ),
                    leading: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => startDate = picked);
                      }
                    },
                  ),
                if (scenario == 2)
                  ListTile(
                    title: Text(
                      startDate == null
                          ? 'select_date_range'.tr()
                          : '${DateFormat('MMM dd').format(startDate!)} - ${DateFormat('MMM dd').format(endDate ?? startDate!)}',
                    ),
                    leading: const Icon(Icons.date_range_rounded),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          startDate = picked.start;
                          endDate = picked.end;
                        });
                      }
                    },
                  ),
                if (scenario == 4) ...[
                  ListTile(
                    title: Text(
                      startTime == null
                          ? 'start_time'.tr()
                          : startTime!.format(context),
                    ),
                    leading: const Icon(Icons.access_time_rounded),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => startTime = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      endTime == null
                          ? 'end_time'.tr()
                          : endTime!.format(context),
                    ),
                    leading: const Icon(Icons.access_time_rounded),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => endTime = picked);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'reason_for_time_off'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.almostBlack700
                        : AppColors.almostBlack50,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                final Map<String, dynamic> data = {
                  'scenario': switch (scenario) {
                    1 => 'SINGLE_DAY',
                    2 => 'DATE_RANGE',
                    3 => 'IMMEDIATE',
                    4 => 'TIME_WINDOW',
                    _ => 'SINGLE_DAY',
                  },
                  'start_date': startDate != null
                      ? DateFormat('yyyy-MM-dd').format(startDate!)
                      : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  'end_date': endDate != null
                      ? DateFormat('yyyy-MM-dd').format(endDate!)
                      : null,
                  'start_time': startTime != null
                      ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00'
                      : null,
                  'end_time': endTime != null
                      ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
                      : null,
                  'reason': reasonController.text,
                };

                final success = await context
                    .read<ScheduleProvider>()
                    .submitPTORequest(data);
                if (mounted) {
                  if (success) {
                    if (scenario == 3) {
                      await context
                          .read<ScheduleProvider>()
                          .updateStaffAvailability({'status': 'ON_PTO'});
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('pto_request_submitted'.tr()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.read<ScheduleProvider>().error ??
                              'failed_to_submit_request'.tr(),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                'submit'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPTOHeader(int scenario) {
    return switch (scenario) {
      1 => 'Single Day Off',
      2 => 'Date Range',
      3 => 'Immediate Leave',
      4 => 'Specific Time Range',
      _ => 'PTO Request',
    };
  }
}
