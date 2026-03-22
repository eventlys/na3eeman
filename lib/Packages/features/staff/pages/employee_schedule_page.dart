import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class EmployeeSchedulePage extends StatefulWidget {
  const EmployeeSchedulePage({super.key});

  @override
  State<EmployeeSchedulePage> createState() => _EmployeeSchedulePageState();
}

class _EmployeeSchedulePageState extends State<EmployeeSchedulePage> {
  // Mock data for employee schedule
  final Map<String, Map<String, dynamic>> _schedule = {
    'Monday': {'isOn': true, 'start': '10:00 AM', 'end': '08:00 PM'},
    'Tuesday': {'isOn': true, 'start': '10:00 AM', 'end': '08:00 PM'},
    'Wednesday': {'isOn': true, 'start': '10:00 AM', 'end': '08:00 PM'},
    'Thursday': {'isOn': true, 'start': '10:00 AM', 'end': '10:00 PM'},
    'Friday': {'isOn': false, 'start': 'Off', 'end': 'Off'},
    'Saturday': {'isOn': true, 'start': '12:00 PM', 'end': '09:00 PM'},
    'Sunday': {'isOn': true, 'start': '10:00 AM', 'end': '08:00 PM'},
  };

  void _toggleDay(String day) {
    setState(() {
      _schedule[day]!['isOn'] = !_schedule[day]!['isOn'];
    });
  }

  Future<void> _selectTime(BuildContext context, String day, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _schedule[day]![isStart ? 'start' : 'end'] = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Schedule', style: TextStyle(fontWeight: FontWeight.bold)),
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
              'Set Your Weekly availability',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your working hours and off days. Customers can only book you during these hours.',
              style: TextStyle(color: AppColors.almostBlack300, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Schedule List
            ..._schedule.keys.map((day) {
              final isOn = _schedule[day]!['isOn'] as bool;
              final start = _schedule[day]!['start'] as String;
              final end = _schedule[day]!['end'] as String;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.almostBlack600 : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(isOn ? '$start - $end' : 'Off Day', style: TextStyle(color: isOn ? Theme.of(context).primaryColor : AppColors.error, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: isOn
                          ? Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectTime(context, day, true),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.almostBlack700 : AppColors.almostBlack50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(start, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('-')),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectTime(context, day, false),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.almostBlack700 : AppColors.almostBlack50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(end, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: isOn,
                      onChanged: (val) => _toggleDay(day),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Schedule updated successfully'), backgroundColor: AppColors.success),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
