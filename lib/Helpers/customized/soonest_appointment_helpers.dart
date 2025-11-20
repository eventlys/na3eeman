class SoonestAppointmentHelpers {
  static bool canDelayAppointment(Map<String, dynamic> appointment, Duration delay) {
    final DateTime appointmentDateTime = DateTime.parse(appointment['dateTime']);
    DateTime newDateTime = appointmentDateTime.add(delay);
    DateTime originalDate = appointmentDateTime;

    // Check if the delay would move the appointment to another day
    bool isSameDay = newDateTime.year == originalDate.year &&
        newDateTime.month == originalDate.month &&
        newDateTime.day == originalDate.day;

    // Allow delay only if it's within the same day and doesn't exceed business hours
    return isSameDay && delay.inMinutes <= 15;
  }

  static Map<String, dynamic> delayAppointment(Map<String, dynamic> appointment, Duration delay) {
    if (canDelayAppointment(appointment, delay)) {
      final DateTime newDateTime = DateTime.parse(appointment['dateTime']).add(delay);
      
      // Create a copy of the appointment with updated dateTime
      return Map<String, dynamic>.from(appointment)
        ..['dateTime'] = newDateTime.toIso8601String();
    } else {
      // For delays > 15 min or crossing days, we need to reschedule
      // This would typically involve showing a rescheduling dialog
      throw Exception('Cannot delay appointment. Please reschedule.');
    }
  }

  static String formatAppointmentDateTime(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  static String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (appointmentDate == today) {
      return 'Today';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
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
