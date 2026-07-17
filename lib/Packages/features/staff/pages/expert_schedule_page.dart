// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Providers/features/auth_provider.dart';
import '../../../../Providers/features/schedule_provider.dart';
import '../../../../Models/staff/weekly_working_hours.dart';

class ExpertSchedulePage extends StatefulWidget {
  const ExpertSchedulePage({super.key});

  @override
  State<ExpertSchedulePage> createState() => _ExpertSchedulePageState();
}

class _ExpertSchedulePageState extends State<ExpertSchedulePage> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      await context.read<ScheduleProvider>().fetchWorkingHours(
        expertId: auth.user!.id,
      );
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
          'My Schedule'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButtonStyled(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Your Weekly availability'.tr(),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your working hours and off days. Customers can only book you during these hours.'
                  .tr(),
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
                      child: Text('No schedule found'.tr()),
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
                                  isOn ? '$start - $end' : 'Off Day'.tr(),
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
                                        () =>
                                            _selectTime(context, hours, false),
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
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Schedule updated successfully'.tr()),
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
                  'Save Changes'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
}
