import 'package:flutter/material.dart';
import '../../../Core/constants/app_color.dart';


class AppointmentsList extends StatelessWidget {
  final List<dynamic> appointments;
  final bool isDarkMode;

  const AppointmentsList({
    super.key,
    required this.appointments,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColor.darkCard : AppColor.lightCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'No upcoming appointments',
              style: TextStyle(
                color: isDarkMode ? AppColor.darkTextHint : AppColor.lightTextHint,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final appointment = appointments[index];
          return Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColor.darkCard : AppColor.lightCard,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: isDarkMode ? AppColor.darkTextHint.withOpacity(0.2) : AppColor.lightTextHint.withOpacity(0.2)
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? AppColor.darkWithOpacity : AppColor.darkWithOpacity,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDarkMode ? AppColor.darkInfo.withOpacity(0.2) : AppColor.lightInfo.withOpacity(0.2),
                child: Icon(Icons.person, color: isDarkMode ? AppColor.darkInfo : AppColor.lightInfo),
              ),
              title: Text(
                appointment['customerName'] ?? 'Customer',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppColor.darkText : AppColor.lightText,
                ),
              ),
              subtitle: Text(
                '${appointment['service'] ?? 'Haircut'} • ${appointment['time'] ?? 'Unknown time'}',
                style: TextStyle(
                  color: isDarkMode ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,               ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  appointment['status'] ?? 'Scheduled',
                  style: TextStyle(
                    color: _getStatusColor(appointment['status']),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
        childCount: appointments.length,
      ),
    );
  }

   Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return isDarkMode ? AppColor.darkSuccess : AppColor.lightSuccess;
      case 'pending':
        return isDarkMode ? AppColor.darkWarning : AppColor.lightWarning;
      case 'cancelled':
        return isDarkMode ? AppColor.darkError : AppColor.lightError;
      default:
        return isDarkMode ? AppColor.darkInfo : AppColor.lightInfo;
    }
  }
}
