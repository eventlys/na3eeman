import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/main_providers.dart';
import '../../../Services/api/api_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/buttons/styled_buttons.dart';
import '../../../core/widgets/dashboard/dashboard_widgets.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final authProvider = context.read<AuthProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();

    if (!authProvider.isAuthenticated) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Please login to view appointment history';
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      await appointmentProvider.loadAppointments();

      if (mounted) {
        setState(() {
          // Filter to show only completed or cancelled for history
          _appointments = appointmentProvider.appointments.where((appt) {
            final apptCustomerId = _getAppointmentCustomerId(appt);
            return apptCustomerId == authProvider.user?.id;
          }).toList();
          
          // Sort by date descending
          _appointments.sort((a, b) => _getAppointmentStartTime(b).compareTo(_getAppointmentStartTime(a)));
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load appointments: $e';
        });
      }
    }
  }

  int _getAppointmentCustomerId(dynamic appointment) {
    if (appointment is Map) {
      return appointment['customer'] ?? appointment['customerId'] ?? 0;
    }
    return 0; // Simplified for robustness
  }

  DateTime _getAppointmentStartTime(dynamic appointment) {
    if (appointment is Map) {
      final dateTime = appointment['dateTime'] ?? appointment['startTime'];
      if (dateTime is DateTime) return dateTime;
      if (dateTime is String) return DateTime.tryParse(dateTime) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _getSalonName(dynamic appointment) {
    if (appointment is Map) return appointment['salonName'] ?? 'Na3eeman Salon';
    return 'Na3eeman Salon';
  }

  String _getExpertName(dynamic appointment) {
    if (appointment is Map) return appointment['expertName'] ?? 'Any Specialist';
    return 'Any Specialist';
  }

  String _getCost(dynamic appointment) {
    if (appointment is Map) return '${appointment['price'] ?? '0.00'} JOD';
    return '0.00 JOD';
  }

  List<String> _getServices(dynamic appointment) {
    if (appointment is Map) {
      final services = appointment['services'];
      if (services is List) {
        return services.map((s) => s is Map ? s['name'].toString() : s.toString()).toList();
      }
      if (appointment['serviceName'] != null) return [appointment['serviceName']];
    }
    return ['General Service'];
  }

  void _showDoItAgainPopup(dynamic appointment) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Do it again', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a new date and time for this appointment:'),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.calendar_today_rounded, color: Theme.of(context).primaryColor, size: 20),
                ),
                title: const Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
              ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.access_time_rounded, color: Theme.of(context).primaryColor, size: 20),
                ),
                title: const Text('Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) setState(() => selectedTime = time);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel".tr())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Proceed to payment / booking logic
                Navigator.pushNamed(context, '/category_selection', arguments: {
                  'rebookAppointment': appointment,
                  'selectedDate': selectedDate,
                  'selectedTime': selectedTime,
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSetRepeatAlarm(dynamic appointment, String frequency, String duration, DateTime startDate) async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final authProvider = context.read<AuthProvider>();
      
      // Map display labels to backend choices
      final frequencyMap = {
        'Twice a month': '2x_MONTH',
        'Once a week': '1x_WEEK',
        'Once a month': '1x_MONTH',
        'Once every 3 weeks': '3x_WEEK',
      };

      final durationMap = {
        '1 month': 1,
        '3 months': 3,
        '6 months': 6,
        '9 months': 9,
        '1 year': 12,
        '2 years': 24,
      };

      await api.createRecurringBooking({
        'customer': authProvider.user?.id,
        'salon': appointment['salon'] ?? 1,
        'expert': appointment['expert'] ?? 1,
        'service': appointment['service'] ?? 1,
        'frequency': frequencyMap[frequency] ?? '1x_WEEK',
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'duration_months': durationMap[duration] ?? 3,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recurring appointment set for $frequency for $duration'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set repeat: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRepeatPopup(dynamic appointment) {
    String selectedFrequency = 'Once a week';
    String selectedDuration = '3 months';
    DateTime startDate = DateTime.now().add(const Duration(days: 7));

    final frequencies = ['Twice a month', 'Once a week', 'Once a month', 'Once every 3 weeks'];
    final durations = ['1 month', '3 months', '6 months', '9 months', '1 year', '2 years'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Set Repeat Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Keep your routine consistent by setting a recurring appointment alarm.'),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: selectedFrequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.repeat_rounded),
                ),
                items: frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) => setState(() => selectedFrequency = val!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDuration,
                decoration: InputDecoration(
                  labelText: 'For how long?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.timer_rounded),
                ),
                items: durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => selectedDuration = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                tileColor: Theme.of(context).primaryColor.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: const Text('Starting Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(DateFormat('MMMM d, yyyy').format(startDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) setState(() => startDate = date);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel".tr())),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSetRepeatAlarm(appointment, selectedFrequency, selectedDuration, startDate);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Appointment History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _appointments.isEmpty
                  ? Center(child: _buildEmptyState(isDark))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appt = _appointments[index];
                        return _buildAppointmentHistoryCard(appt, isDark, primaryColor);
                      },
                    ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
        const SizedBox(height: 24),
        Text(
          'No history yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.almostBlack,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your past appointments will appear here.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAppointmentHistoryCard(dynamic appt, bool isDark, Color primaryColor) {
    final startTime = _getAppointmentStartTime(appt);
    final salonName = _getSalonName(appt);
    final expertName = _getExpertName(appt);
    final cost = _getCost(appt);
    final services = _getServices(appt);

    return DashboardCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salonName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEE, MMM d • hh:mm a').format(startTime),
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(cost, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _infoRow(Icons.person_rounded, 'Professional', expertName, isDark),
          const SizedBox(height: 12),
          _infoRow(Icons.cut_rounded, 'Services', services.join(', '), isDark),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Repeat',
                  onPressed: () => _showRepeatPopup(appt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Do it again',
                  onPressed: () => _showDoItAgainPopup(appt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
