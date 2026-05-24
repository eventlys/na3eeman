import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:na3eeman/Packages/Core/utils/extensions.dart';

class DateTimeHelpers {
  const DateTimeHelpers._();

  static String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  static String formatTimeRange(DateTime start, DateTime end) {
    final startFormat = DateFormat.jm();
    final endFormat = DateFormat.jm();
    return '${startFormat.format(start)} - ${endFormat.format(end)}';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameWeek(DateTime a, DateTime b) {
    final startOfWeekA = a.subtract(Duration(days: a.weekday - 1));
    final startOfWeekB = b.subtract(Duration(days: b.weekday - 1));
    return isSameDay(startOfWeekA, startOfWeekB);
  }

  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = start.startOfDay;
    final endDate = end.startOfDay;

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    return getStartOfWeek(date).add(const Duration(days: 6));
  }

  static int getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final firstMonday = firstDay.add(
      Duration(days: (8 - firstDay.weekday) % 7),
    );
    if (date.isBefore(firstMonday)) {
      return 52;
    }
    final diff = date.difference(firstMonday).inDays;
    return (diff ~/ 7) + 1;
  }
}
