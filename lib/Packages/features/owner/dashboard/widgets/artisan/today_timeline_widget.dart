// ignore_for_file: dead_null_aware_expression
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../Providers/features/appointment_provider.dart';

/// Shows a live timeline of today's appointments in a scrollable list.
/// Reads real data from AppointmentProvider.
class TodayTimelineWidget extends StatelessWidget {
  const TodayTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final appointmentProvider = context.watch<AppointmentProvider>();

    // Load appointments if not loaded yet
    if (appointmentProvider.appointments.isEmpty &&
        !appointmentProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appointmentProvider.loadAppointments();
      });
    }

    // Filter appointments for today
    final todayAppointments = appointmentProvider.appointments.where((appt) {
      return appt.startTime.year == now.year &&
          appt.startTime.month == now.month &&
          appt.startTime.day == now.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.today_rounded, size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Today — ${DateFormat('EEE, MMM d').format(now)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (appointmentProvider.isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (todayAppointments.isEmpty && !appointmentProvider.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "no_appointments_scheduled".tr(),
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
            ),
          ),
        ...todayAppointments.map((appt) {
          final timeStr = DateFormat('HH:mm').format(appt.startTime);
          // The API might be sending customer logic differently depending on who is requesting.
          // Fallback to "Client" if ID is not available
          final client = 'Client #${appt.customerId ?? 0}';
          // Status drives color
          final isCompleted = appt.status.name.toUpperCase() == 'COMPLETED';
          final isCurrent =
              appt.status.name.toUpperCase() == 'CHECKED_IN' ||
              (now.isAfter(appt.startTime) && now.isBefore(appt.endTime));

          return _SlotTile(
            time: timeStr,
            client: client,
            service: 'Service Booking',
            isCompleted: isCompleted,
            isCurrent: isCurrent,
          );
        }),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  final String time;
  final String client;
  final String service;
  final bool isCompleted;
  final bool isCurrent;

  const _SlotTile({
    required this.time,
    required this.client,
    required this.service,
    this.isCompleted = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = isCurrent
        ? theme.primaryColor
        : isCompleted
        ? Colors.grey
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              time,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 3,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  service,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "now".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
