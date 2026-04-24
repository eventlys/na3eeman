import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../Helpers/customized/schedule_helper.dart';
import '../../constants/app_color.dart';
// import 'package:easy_localization/easy_localization.dart';

class ScheduleDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? availableColor;
  final Color? unavailableColor;
  final Color? textColor;
  final Color? headerColor;

  const ScheduleDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.backgroundColor,
    this.selectedColor,
    this.availableColor,
    this.unavailableColor,
    this.textColor,
    this.headerColor,
  });

  @override
  State<ScheduleDatePicker> createState() => _ScheduleDatePickerState();
}

class _ScheduleDatePickerState extends State<ScheduleDatePicker> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _selectDate(DateTime date) {
    if (ScheduleHelper.isDateAvailable(date)) {
      widget.onDateSelected(date);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDay.weekday;
    final daysFromPreviousMonth = firstWeekday - 1;
    final totalDays = 42; // 6 weeks

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final calendarWidth = containerWidth * 0.95; // 95% of container width
        final dayCellSize = (calendarWidth - 32) / 7; // Subtract padding and divide by 7 days

        return Container(
          decoration: BoxDecoration(
            color: AppColor.lightCard.withValues(alpha: 0.4), // Updated to use AppColor
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColor.light, // Updated to use AppColor
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.selectDate,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.headerColor ?? AppColor.lightText, // Updated to use AppColor
                  ),
                ),
                const SizedBox(height: 16),

                // Calendar container
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? AppColor.secondary.withValues(alpha: 0.2), // Updated to use AppColor
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.light), // Updated to use AppColor
                  ),
                  child: Column(
                    children: [
                      // Month header and navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: widget.headerColor ?? AppColor.secondary, // Updated to use AppColor
                            ),
                            onPressed: _navigateToPreviousMonth,
                          ),
                          Text(
                            '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.headerColor ?? AppColor.secondary, // Updated to use AppColor
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: widget.headerColor ?? AppColor.secondary, // Updated to use AppColor
                            ),
                            onPressed: _navigateToNextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Weekday headers
                      Row(
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                            .map((day) => Expanded(
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.textColor ?? AppColor.lightTextSecondary, // Updated to use AppColor
                                      fontSize: 12,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),

                      // Calendar grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: totalDays,
                        itemBuilder: (context, index) {
                          final dayOffset = index - daysFromPreviousMonth;
                          final currentDate = DateTime(firstDay.year, firstDay.month, 1 + dayOffset);

                          final bool isCurrentMonth = currentDate.month == firstDay.month;
                          final bool isAvailable = isCurrentMonth && ScheduleHelper.isDateAvailable(currentDate);
                          final bool isSelected = widget.selectedDate != null &&
                              currentDate.year == widget.selectedDate!.year &&
                              currentDate.month == widget.selectedDate!.month &&
                              currentDate.day == widget.selectedDate!.day;
                          final bool isToday = currentDate.year == now.year &&
                              currentDate.month == now.month &&
                              currentDate.day == now.day;

                          return SizedBox(
                            width: dayCellSize,
                            height: dayCellSize,
                            child: GestureDetector(
                              onTap: isAvailable ? () => _selectDate(currentDate) : null,
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (widget.selectedColor ?? AppColor.secondary) // Updated to use AppColor
                                      : isToday
                                          ? (widget.availableColor ?? AppColor.secondary.withValues(alpha: 0.15)) // Updated to use AppColor
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(dayCellSize / 2),
                                  border: isToday
                                      ? Border.all(color: widget.availableColor ?? AppColor.secondary) // Updated to use AppColor
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    currentDate.day.toString(),
                                    style: TextStyle(
                                      color: !isCurrentMonth
                                          ? (widget.unavailableColor ?? AppColor.lightTextHint) // Updated to use AppColor
                                          : !isAvailable
                                              ? (widget.unavailableColor ?? AppColor.secondary) // Updated to use AppColor
                                              : isSelected
                                                  ? AppColor.light // Updated to use AppColor
                                                  : (widget.textColor ?? AppColor.lightText), // Updated to use AppColor
                                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                      fontSize: dayCellSize * 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
}

class ScheduleTimePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? headerColor;
  final Color? timeSlotColor;
  final Color? selectedTimeColor;
  final int totalDurationMinutes;

  const ScheduleTimePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeSelected,
    this.backgroundColor,
    this.textColor,
    this.headerColor,
    this.timeSlotColor,
    this.selectedTimeColor,
    this.totalDurationMinutes = 30,
  });

  @override
  State<ScheduleTimePicker> createState() => _ScheduleTimePickerState();
}

class _ScheduleTimePickerState extends State<ScheduleTimePicker> {
  @override
  Widget build(BuildContext context) {
    final availableTimes = widget.selectedDate != null
        ? ScheduleHelper.getAvailableTimesForDate(widget.selectedDate!)
        : [];

    return Container(
      decoration: BoxDecoration(
        color: AppColor.lightCard.withValues(alpha: 0.3), // Updated to use AppColor
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.light, // Updated to use AppColor
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.availableTimes,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.headerColor ?? AppColor.lightText, // Updated to use AppColor
              ),
            ),
            const SizedBox(height: 16),

            if (widget.selectedDate == null) ...[
              // Show message when no date is selected
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.lightCard.withValues(alpha: 0.3), // Updated to use AppColor
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.light), // Updated to use AppColor
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: widget.headerColor ?? AppColor.secondary, // Updated to use AppColor
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(AppLocalizations.of(context)!.selectADateFirstToSeeAvailableTimes,
                      style: TextStyle(
                        color: widget.textColor ?? AppColor.lightText, // Updated to use AppColor
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ]
            else ...[
              // Show available time slots in a dynamic grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColor.secondary.withValues(alpha: 0.2), // Updated to use AppColor
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.light), // Updated to use AppColor
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final itemWidth = (screenWidth * 0.95) / 3;

                    return Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      alignment: WrapAlignment.start,
                      children: availableTimes.map((time) {
                        final isSelected = widget.selectedTime != null &&
                            widget.selectedTime!.hour == time.hour &&
                            widget.selectedTime!.minute == time.minute;

                        return SizedBox(
                          width: itemWidth,
                          child: GestureDetector(
                            onTap: () => widget.onTimeSelected(time),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (widget.selectedTimeColor ?? AppColor.light.withValues(alpha: 0.25)) // Updated to use AppColor
                                    : (widget.timeSlotColor ?? AppColor.secondary.withValues(alpha: 0.15)), // Updated to use AppColor
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.light // Updated to use AppColor
                                      : AppColor.secondary, // Updated to use AppColor
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  time.format(context),
                                  style: TextStyle(
                                    color: isSelected ? AppColor.secondary : AppColor.light, // Updated to use AppColor
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
