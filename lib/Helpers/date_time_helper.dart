import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  // Date formats
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _apiDateTimeFormat = DateFormat(
    "yyyy-MM-dd'T'HH:mm:ss'Z'",
  );
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('HH:mm');
  static final DateFormat _displayDateTimeFormat = DateFormat(
    'MMM dd, yyyy HH:mm',
  );
  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  // Get current timestamp in different formats
  static DateTime get now => DateTime.now();
  static DateTime get today => DateTime(now.year, now.month, now.day);
  static DateTime get tomorrow => today.add(const Duration(days: 1));
  static DateTime get yesterday => today.subtract(const Duration(days: 1));

  // Format dates for display
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }

  static String formatDisplayTime(DateTime date) {
    return _displayTimeFormat.format(date);
  }

  static String formatDisplayDateTime(DateTime date) {
    return _displayDateTimeFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  // Format dates for API
  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }

  static String formatApiDateTime(DateTime date) {
    return _apiDateTimeFormat.format(date.toUtc());
  }

  // Parse dates from API
  static DateTime parseApiDate(String dateString) {
    return _apiDateFormat.parse(dateString);
  }

  static DateTime parseApiDateTime(String dateTimeString) {
    return _apiDateTimeFormat.parse(dateTimeString, true).toLocal();
  }

  // Relative time formatting
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return formatDisplayDate(date);
    }
  }

  // Date comparison helpers
  static bool isToday(DateTime date) {
    return _isSameDay(date, now);
  }

  static bool isTomorrow(DateTime date) {
    return _isSameDay(date, tomorrow);
  }

  static bool isYesterday(DateTime date) {
    return _isSameDay(date, yesterday);
  }

  static bool isThisWeek(DateTime date) {
    final startOfWeek = _getStartOfWeek(now);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  static bool isThisMonth(DateTime date) {
    return date.year == now.year && date.month == now.month;
  }

  static bool isPast(DateTime date) {
    return date.isBefore(now);
  }

  static bool isFuture(DateTime date) {
    return date.isAfter(now);
  }

  // Date manipulation
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static DateTime addHours(DateTime date, int hours) {
    return date.add(Duration(hours: hours));
  }

  static DateTime subtractHours(DateTime date, int hours) {
    return date.subtract(Duration(hours: hours));
  }

  static DateTime addMinutes(DateTime date, int minutes) {
    return date.add(Duration(minutes: minutes));
  }

  static DateTime subtractMinutes(DateTime date, int minutes) {
    return date.subtract(Duration(minutes: minutes));
  }

  // Get start/end of periods
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime getStartOfWeek(DateTime date) {
    return _getStartOfWeek(date);
  }

  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = _getStartOfWeek(date);
    return startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Business hours and appointment helpers
  static bool isBusinessHours(
    DateTime date, {
    TimeOfDay? open,
    TimeOfDay? close,
  }) {
    final openTime = open ?? const TimeOfDay(hour: 9, minute: 0);
    final closeTime = close ?? const TimeOfDay(hour: 18, minute: 0);

    final currentTime = TimeOfDay.fromDateTime(date);

    return _isTimeAfterOrEqual(currentTime, openTime) &&
        _isTimeBeforeOrEqual(currentTime, closeTime);
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  // Duration helpers
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  static String formatDurationMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Age calculation
  static int calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Time slot generation for appointments
  static List<DateTime> generateTimeSlots({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int slotDurationMinutes,
  }) {
    final slots = <DateTime>[];
    var current = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    while (current.isBefore(endDateTime)) {
      slots.add(current);
      current = current.add(Duration(minutes: slotDurationMinutes));
    }

    return slots;
  }

  // Private helper methods
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime _getStartOfWeek(DateTime date) {
    // Start week on Monday
    final difference = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: difference));
  }

  static bool _isTimeAfterOrEqual(TimeOfDay time, TimeOfDay other) {
    if (time.hour > other.hour) return true;
    if (time.hour == other.hour && time.minute >= other.minute) return true;
    return false;
  }

  static bool _isTimeBeforeOrEqual(TimeOfDay time, TimeOfDay other) {
    if (time.hour < other.hour) return true;
    if (time.hour == other.hour && time.minute <= other.minute) return true;
    return false;
  }

  // Timezone helpers
  static DateTime toLocalTime(DateTime utcTime) {
    return utcTime.toLocal();
  }

  static DateTime toUtcTime(DateTime localTime) {
    return localTime.toUtc();
  }

  // Date difference in business days
  static int getBusinessDaysDifference(DateTime start, DateTime end) {
    int businessDays = 0;
    DateTime current = getStartOfDay(start);
    final endDate = getStartOfDay(end);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (isWeekday(current)) {
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return businessDays;
  }
}
