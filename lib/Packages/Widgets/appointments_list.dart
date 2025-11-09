import 'package:flutter/material.dart';

class AppointmentsList extends StatelessWidget {
  final List<dynamic> appointments;

  const AppointmentsList({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No upcoming appointments',
              style: TextStyle(
                color: Colors.grey,
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
              color: Color(0x66FFFFFF),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0x33FFFFFF)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33DFA8A4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            // decoration: BoxDecoration(
            //   color: Color(0x40ffffff),
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              title: Text(
                appointment['customerName'] ?? 'Customer',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${appointment['service'] ?? 'Haircut'} • ${appointment['time'] ?? 'Unknown time'}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
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
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
