import 'package:flutter/material.dart';
import '../../Models/salon/salon_schedule_model.dart';
// import '../Models/salon_service_model.dart';

class ScheduleHelper {
  static final List<DateTime> _unavailableDates = [];
  static final List<TimeOfDay> _availableTimeSlots = [];
  static final Map<DateTime, List<TimeOfDay>> _bookedSlots = {};

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

    return !bookedTimes.any(
      (bookedTime) =>
          bookedTime.hour == time.hour && bookedTime.minute == time.minute,
    );
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
