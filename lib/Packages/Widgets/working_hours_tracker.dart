import 'package:flutter/material.dart';

import '../../Models/working_hours_model.dart';
import '../../Services/api_service.dart';

class WorkingHoursTracker extends StatefulWidget {
  final WorkingHours workingHours;

  const WorkingHoursTracker({super.key, required this.workingHours});

  @override
  State<WorkingHoursTracker> createState() => _WorkingHoursTrackerState();
}

class _WorkingHoursTrackerState extends State<WorkingHoursTracker> {
  late WorkingHours _workingHours;

  @override
  void initState() {
    super.initState();
    _workingHours = widget.workingHours;
  }

  void _startWorking() async {
    try {
      await ApiService.startWorkingHours();
      setState(() {
        _workingHours = WorkingHours(
          date: _workingHours.date,
          scheduledStart: _workingHours.scheduledStart,
          scheduledEnd: _workingHours.scheduledEnd,
          actualStart: DateTime.now(),
          actualEnd: null,
          isWorking: true,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting work: $e')),
      );
    }
  }

  void _endWorking() async {
    try {
      await ApiService.endWorkingHours();
      setState(() {
        _workingHours = WorkingHours(
          date: _workingHours.date,
          scheduledStart: _workingHours.scheduledStart,
          scheduledEnd: _workingHours.scheduledEnd,
          actualStart: _workingHours.actualStart,
          actualEnd: DateTime.now(),
          isWorking: false,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending work: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Working Hours",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WorkingHoursItem(
                      label: 'Scheduled',
                      value: _formatDuration(_workingHours.scheduledDuration),
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _WorkingHoursItem(
                      label: 'Worked',
                      value: _formatDuration(_workingHours.workedDuration),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _WorkingHoursItem(
                      label: 'Remaining',
                      value: _workingHours.isWorking
                          ? _formatDuration(_workingHours.remainingTime)
                          : 'Completed',
                      color: _workingHours.isWorking ? Colors.orange : Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _workingHours.isWorking ? Colors.green : Colors.grey[300],
                    ),
                    child: Icon(
                      _workingHours.isWorking ? Icons.work : Icons.work_off,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_workingHours.isWorking && _workingHours.actualStart == null)
                    ElevatedButton(
                      onPressed: _startWorking,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Start Work'),
                    )
                  else if (_workingHours.isWorking)
                    ElevatedButton(
                      onPressed: _endWorking,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('End Work'),
                    )
                  else
                    Text(
                      'Work Completed',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_workingHours.actualStart != null) ...[
            const SizedBox(height: 12),
            Text(
              'Started: ${TimeOfDay.fromDateTime(_workingHours.actualStart!).format(context)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
          if (_workingHours.actualEnd != null)
            Text(
              'Ended: ${TimeOfDay.fromDateTime(_workingHours.actualEnd!).format(context)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}

class _WorkingHoursItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _WorkingHoursItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

