// helpers/expert_home_helper.dart

class ExpertHomeHelper {
  // Calculate total earnings from appointments
  static double calculateTotalEarnings(List<dynamic> appointments) {
    return appointments.fold(0.0, (sum, appt) {
      // Replace with your actual earnings calculation logic
      return sum + (appt.totalPrice ?? 0.0);
    });
  }

  // Filter appointments by status
  static List<dynamic> filterAppointmentsByStatus(
    List<dynamic> appointments,
    String status
  ) {
    return appointments.where((appt) => appt.status?.name == status).toList();
  }

  // Format appointment data for display
  static Map<String, dynamic> formatAppointmentForDisplay(dynamic appointment) {
    return {
      'id': appointment.id,
      'customerName': 'Customer ${appointment.customerId}',
      'service': 'Service', // Replace with actual service data
      'time': appointment.startTime?.toString() ?? 'Unknown',
      'price': appointment.totalPrice ?? 0.0,
    };
  }

  // Check if salon is currently open
  static bool isSalonOpen(Map<String, dynamic> workingHours) {
    if (workingHours['isOpen'] == false) return false;

    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute}';
    final opening = workingHours['openingTime'] ?? '09:00';
    final closing = workingHours['closingTime'] ?? '20:00';

    return _isTimeBetween(currentTime, opening, closing);
  }

  static bool _isTimeBetween(String current, String start, String end) {
    // Simple time comparison - implement proper time parsing as needed
    return true; // Replace with actual time comparison logic
  }
}
