import 'package:flutter/material.dart';
import '../../Models/salon/salon_schedule_model.dart';
// import '../Models/salon_service_model.dart';

class ScheduleHelper {
  // Mock data - replace with actual API calls
  static final List<DateTime> _unavailableDates = [
    DateTime.now().add(Duration(days: 1)),
    DateTime.now().add(Duration(days: 3)),
    DateTime.now().add(Duration(days: 5)),
  ];

  static final List<TimeOfDay> _availableTimeSlots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
  ];

  static final Map<DateTime, List<TimeOfDay>> _bookedSlots = {
    DateTime.now().add(Duration(days: 2)): [
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 14, minute: 0),
    ],
    DateTime.now().add(Duration(days: 4)): [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 15, minute: 0),
    ],
  };

  static List<DateTime> get unavailableDates => _unavailableDates;
  static List<TimeOfDay> get availableTimeSlots => _availableTimeSlots;

  static bool isDateAvailable(DateTime date) {
    if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return false;
    }

    for (DateTime unavailableDate in _unavailableDates) {
      if (date.year == unavailableDate.year &&
          date.month == unavailableDate.month &&
          date.day == unavailableDate.day) {
        return false;
      }
    }
    return true;
  }

  static bool isTimeAvailable(DateTime date, TimeOfDay time) {
    final bookedTimes = _bookedSlots[date];
    if (bookedTimes == null) return true;

    return !bookedTimes.any((bookedTime) =>
        bookedTime.hour == time.hour && bookedTime.minute == time.minute);
  }

  static List<TimeOfDay> getAvailableTimesForDate(DateTime date) {
    return _availableTimeSlots
        .where((time) => isTimeAvailable(date, time))
        .toList();
  }

  static Future<void> bookSchedule(SalonScheduleSlot scheduleSlot) async {
    // Implement actual booking logic here
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    print('Schedule booked: ${scheduleSlot.dateTime}');
  }

  static Future<List<SalonScheduleSlot>> getUserSchedules() async {
    // Implement actual fetch logic here
    await Future.delayed(Duration(seconds: 1));
    return [];
  }
}


