import 'package:flutter/material.dart';
import '../../Models/soonest_appointment_model.dart';
import '../../Services/soonest_appointment_helpers.dart';


class SoonestAppointmentCard extends StatefulWidget {
  final List<SoonestAppointment> appointments;
  final Function(SoonestAppointment)? onAppointmentDelayed;
  final Function(SoonestAppointment)? onAppointmentRescheduleNeeded;

  const SoonestAppointmentCard({
    super.key,
    required this.appointments,
    this.onAppointmentDelayed,
    this.onAppointmentRescheduleNeeded,
  });

  @override
  State<SoonestAppointmentCard> createState() => _SoonestAppointmentCardState();
}

class _SoonestAppointmentCardState extends State<SoonestAppointmentCard> {
  SoonestAppointment? _soonestAppointment;

  @override
  void initState() {
    super.initState();
    _updateSoonestAppointment();
  }

  @override
  void didUpdateWidget(SoonestAppointmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointments != widget.appointments) {
      _updateSoonestAppointment();
    }
  }

  void _updateSoonestAppointment() {
    setState(() {
      _soonestAppointment = SoonestAppointmentData.getSoonestAppointment(widget.appointments);
    });
  }

  void _handleDelayAppointment() async {
    if (_soonestAppointment == null) return;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => _DelayAppointmentDialog(
        currentAppointment: _soonestAppointment!,
      ),
    );

    if (result != null && mounted) {
      _processDelay(result);
    }
  }

  void _processDelay(Duration delay) {
    try {
      final delayedAppointment = SoonestAppointmentHelpers.delayAppointment(
        _soonestAppointment!,
        delay,
      );

      widget.onAppointmentDelayed?.call(delayedAppointment);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment delayed by ${delay.inMinutes} minutes'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _soonestAppointment = delayedAppointment;
      });

    } catch (e) {
      // Delay not possible, need to reschedule
      widget.onAppointmentRescheduleNeeded?.call(_soonestAppointment!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot delay. Please reschedule your appointment.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _callShop() {
    if (_soonestAppointment != null) {
      final phoneNumber = _soonestAppointment!.shopPhoneNumber;
      // You would typically use url_launcher here
      print('Calling: $phoneNumber');
      // Example: launch('tel:$phoneNumber');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_soonestAppointment == null) {
      return _buildNoAppointmentCard();
    }

    return _buildAppointmentCard(_soonestAppointment!);
  }

  Widget _buildNoAppointmentCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12),
            Text(
              'No Upcoming Appointments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Book an appointment to see it here',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(SoonestAppointment appointment) {
    return Card(
      color: Color(0x40ffffff),
      shadowColor: Colors.transparent,
      margin: EdgeInsets.all(16),
      // elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff000000),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Color(0xffc25858),
                ),
              ],
            ),

            SizedBox(height: 16),
            // Appointment Details
            _buildDetailRow(
              Icons.calendar_today,
              SoonestAppointmentHelpers.formatAppointmentDateTime(appointment.dateTime),
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              Icons.attach_money,
              'Total: ${SoonestAppointmentHelpers.formatPrice(appointment.totalPrice)}',
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              Icons.store,
              appointment.shopName,
            ),
            SizedBox(height: 12),
            GestureDetector(
              onTap: _callShop,
              child: _buildDetailRow(
                Icons.phone,
                appointment.shopPhoneNumber,
                isClickable: true,
              ),
            ),
            SizedBox(height: 16),

            // Services
            if (appointment.services.isNotEmpty) ...[
              Text(
                'Services:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff000000),
                ),
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: appointment.services
                    .map((service) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0x4dffffff), // Your background color
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0x4dc25858),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              color: Color(0xff000000),
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16),
            ],

            // Delay Button
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton.icon(
                  onPressed: _handleDelayAppointment,
                  icon: Icon(Icons.schedule, size: 18),
                  label: Text('Delay Appointment'),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Color(0x4dffffff),
                    foregroundColor: Color(0xffc25858),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Color(0x4dc25858),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isClickable = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Color(0xffc25858),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isClickable ? Color(0xff18458d) : Color(0xff000000),
              fontWeight: isClickable ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _DelayAppointmentDialog extends StatefulWidget {
  final SoonestAppointment currentAppointment;

  const _DelayAppointmentDialog({required this.currentAppointment});

  @override
  State<_DelayAppointmentDialog> createState() => _DelayAppointmentDialogState();
}

class _DelayAppointmentDialogState extends State<_DelayAppointmentDialog> {
  int _selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xffffffff),
      title: Text('Delay Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current time: ${SoonestAppointmentHelpers.formatAppointmentDateTime(widget.currentAppointment.dateTime)}'),
          SizedBox(height: 16),
          Text('Select delay duration:'),
          SizedBox(height: 12),
          DropdownButton<int>(
            value: _selectedMinutes,
            isExpanded: true,
            items: [5, 10, 15]
                .map((minutes) => DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes minutes'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMinutes = value!;
              });
            },
          ),
          SizedBox(height: 8),
          if (_selectedMinutes == 15)
            Text(
              'Note: Delays longer than 15 minutes require rescheduling',
              style: TextStyle(
                color: Color(0xfff57c00),
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, Duration(minutes: _selectedMinutes)),
          style: ElevatedButton.styleFrom(
            // backgroundColor: Color(0x4dffffff), // Background color
            foregroundColor: Color(0xffc25858),
            // elevation: 0, // Shadow intensity
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
              side: BorderSide(
                color: Color(0x4dc25858), // Border color
                width: 1, // Border width
              ),
            ),
          ),
          child: Text(
            'Delay Appointment',
            style: TextStyle(
              color: Color(0xffc25858),
            ),
          ),
        )
      ],
    );
  }
}
