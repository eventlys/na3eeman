import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Models/appointment_model.dart';

class AppointmentAccordion extends StatefulWidget {
  final ShopAppointment appointment;

  const AppointmentAccordion({super.key, required this.appointment});

  @override
  State<AppointmentAccordion> createState() => _AppointmentAccordionState();
}

class _AppointmentAccordionState extends State<AppointmentAccordion> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0x00ffffff),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0x33FFFFFF)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            cardColor: Colors.transparent,
          ),
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor:  Colors.transparent,
            key: Key(widget.appointment.id),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;

              });
            },
            leading: CircleAvatar(
              radius: 36,
              backgroundColor: Color(0x40ffffff),
              backgroundImage: CachedNetworkImageProvider(
                widget.appointment.imagePath,
              ),
            ),

            title: Text(
              widget.appointment.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            subtitle: _buildStatusChip(widget.appointment.status),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0x33ffffff),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.attach_money,
                      title: 'Total Price',
                      value: '\$${widget.appointment.totalPrice.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      title: 'Service Time',
                      value: widget.appointment.serviceTime,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      title: 'Date',
                      value: widget.appointment.date,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.person,
                      title: 'Barber',
                      value: widget.appointment.barberName,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: 'Barber Number',
                      value: widget.appointment.barberNumber,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.store,
                      title: 'Barber Shop',
                      value: widget.appointment.barberShopName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Color(0x80ffffff),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              color: Color(0xffffffff),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}


