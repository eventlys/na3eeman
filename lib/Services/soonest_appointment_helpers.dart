

import '../Models/soonest_appointment_model.dart';

class SoonestAppointmentHelpers {
  static bool canDelayAppointment(SoonestAppointment appointment, Duration delay) {
    DateTime newDateTime = appointment.dateTime.add(delay);
    DateTime originalDate = appointment.dateTime;

    // Check if the delay would move the appointment to another day
    bool isSameDay = newDateTime.year == originalDate.year &&
        newDateTime.month == originalDate.month &&
        newDateTime.day == originalDate.day;

    // Allow delay only if it's within the same day and doesn't exceed business hours
    return isSameDay && delay.inMinutes <= 15;
  }

  static SoonestAppointment delayAppointment(SoonestAppointment appointment, Duration delay) {
    if (canDelayAppointment(appointment, delay)) {
      return appointment.copyWith(
        dateTime: appointment.dateTime.add(delay),
      );
    } else {
      // For delays > 15 min or crossing days, we need to reschedule
      // This would typically involve showing a rescheduling dialog
      throw Exception('Cannot delay appointment. Please reschedule.');
    }
  }

  static String formatAppointmentDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  static String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (appointmentDate == today) {
      return 'Today';
    } else if (appointmentDate == today.add(Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
}

