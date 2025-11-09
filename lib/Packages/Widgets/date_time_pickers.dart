import 'package:flutter/material.dart';
import '../../Services/schedule_helper.dart';

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
            color: Color(0x66ffffff), // Background color
            borderRadius: BorderRadius.circular(12), // Rounded corners
            border: Border.all(
              color: Color(0xFFFFFFFF), // Border color
              width: 1.0, // Border width
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.headerColor ?? Color(0xff040000),
                  ),
                ),
                const SizedBox(height: 16),

                // Calendar container
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Color(0x33C25858),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xffffffff)),
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
                              color: widget.headerColor ?? Color(0xffc25858),
                            ),
                            onPressed: _navigateToPreviousMonth,
                          ),
                          Text(
                            '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.headerColor ?? Color(0xffc25858),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: widget.headerColor ?? Color(0xffc25858),
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
                                      color: widget.textColor ?? Colors.grey[700],
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
                          childAspectRatio: 1.0, // Changed to 1.0 for square cells
                          mainAxisSpacing: 4, // Reduced spacing
                          crossAxisSpacing: 4, // Reduced spacing
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
                            width: dayCellSize, // Dynamic width
                            height: dayCellSize, // Dynamic height for square cells
                            child: GestureDetector(
                              onTap: isAvailable ? () => _selectDate(currentDate) : null,
                              child: Container(
                                margin: const EdgeInsets.all(2), // Reduced margin
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (widget.selectedColor ?? Color(0xffc25858))
                                      : isToday
                                          ? (widget.availableColor ?? Color(0x26c25858))
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(dayCellSize / 2), // Circular based on size
                                  border: isToday
                                      ? Border.all(color: widget.availableColor ?? Color(0xffc25858))
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    currentDate.day.toString(),
                                    style: TextStyle(
                                      color: !isCurrentMonth
                                          ? (widget.unavailableColor ?? Color(0xffffffff))
                                          : !isAvailable
                                              ? (widget.unavailableColor ?? Color(0xffc25858))
                                              : isSelected
                                                  ? Colors.white
                                                  : (widget.textColor ?? Colors.black),
                                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                      fontSize: dayCellSize * 0.3, // Dynamic font size
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
        color: Color(0x4dffffff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFFFFFFFF),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Times',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.headerColor ?? Color(0xff040000),
              ),
            ),
            const SizedBox(height: 16),

            if (widget.selectedDate == null) ...[
              // Show message when no date is selected
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0x4dffffff),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xffffffff)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: widget.headerColor ?? Color(0xffc25858),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select a date first to see available times',
                      style: TextStyle(
                        color: widget.textColor ?? Colors.black87,
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
                  color: widget.backgroundColor ?? Color(0x33C25858),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xffffffff)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final itemWidth = (screenWidth * 0.95) / 3; // 95% width divided by 3 columns

                    return Wrap(
                      spacing: 8, // Horizontal spacing between items
                      runSpacing: 10, // Vertical spacing between lines
                      alignment: WrapAlignment.start,
                      children: availableTimes.map((time) {
                        final isSelected = widget.selectedTime != null &&
                            widget.selectedTime!.hour == time.hour &&
                            widget.selectedTime!.minute == time.minute;

                        return SizedBox(
                          width: itemWidth, // Dynamic width based on screen
                          child: GestureDetector(
                            onTap: () => widget.onTimeSelected(time),
                            child: Container(
                              height: 40, // Fixed height for each time slot
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (widget.selectedTimeColor ?? Color(0x40ffffff))
                                    : (widget.timeSlotColor ?? Color(0x26c25858)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xffffffff)
                                      : Color(0xffc25858),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  time.format(context),
                                  style: TextStyle(
                                    color: isSelected ? Color(0xffc25858) : Color(0xffffffff),
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