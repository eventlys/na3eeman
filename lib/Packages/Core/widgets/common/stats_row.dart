import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../../Services/enums/appointment_status.dart';
import '../../constants/app_color.dart';

class AppointmentStatsRow extends StatelessWidget {
  final bool? isDarkMode;

  const AppointmentStatsRow({
    super.key,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = context.watch<AppointmentProvider>();
    final bool darkMode = isDarkMode ?? Theme.of(context).brightness == Brightness.dark;
    
    // Calculate counts based on appointment status
    final completedCount = appointmentProvider.appointments
        .where((appt) => appt.status == AppointmentStatus.completed)
        .length;
    
    final pendingCount = appointmentProvider.appointments
        .where((appt) => appt.status == AppointmentStatus.pending || 
                         appt.status == AppointmentStatus.scheduled)
        .length;

    return _buildStatsRow(
      completedCount: completedCount,
      pendingCount: pendingCount,
      darkMode: darkMode,
      context: context,
    );
  }

  Widget _buildStatsRow({
    required int completedCount,
    required int pendingCount,
    required bool darkMode,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: "completed".tr(),
              count: completedCount,
              color: darkMode ? AppColor.darkSuccess : AppColor.lightSuccess,
              icon: Icons.check_circle,
              darkMode: darkMode,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: "pending".tr(),
              count: pendingCount,
              color: darkMode ? AppColor.darkWarning : AppColor.lightWarning,
              icon: Icons.pending_actions,
              darkMode: darkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool darkMode,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMode ? AppColor.darkCard : AppColor.lightCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: darkMode 
            ? AppColor.darkTextHint.withValues(alpha: 0.3)
            : AppColor.lightTextHint.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: darkMode 
              ? AppColor.darkWithOpacity
              : AppColor.lightTextHint.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkMode ? AppColor.darkText : AppColor.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: darkMode ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
