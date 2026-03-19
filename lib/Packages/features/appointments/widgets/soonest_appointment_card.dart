import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/customized/soonest_appointment_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class SoonestAppointmentCard extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAppointmentDelayed;
  final Function(Map<String, dynamic>)? onAppointmentRescheduleNeeded;

  const SoonestAppointmentCard({
    super.key,
    this.onAppointmentDelayed,
    this.onAppointmentRescheduleNeeded,
    // Unused params kept for compatibility
    bool isDarkMode = false,
    dynamic userGender,
  });

  @override
  State<SoonestAppointmentCard> createState() => _SoonestAppointmentCardState();
}

class _SoonestAppointmentCardState extends State<SoonestAppointmentCard> {
  Map<String, dynamic>? _soonestAppointment;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSoonestAppointment();
  }

  Future<void> _loadSoonestAppointment() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final appointmentProvider = context.read<AppointmentProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user?.id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final appointment =
          await appointmentProvider.getSoonestAppointment(authProvider.user!.id);

      if (mounted) {
        setState(() {
          _soonestAppointment = appointment;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
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

  void _processDelay(Duration delay) async {
    if (_soonestAppointment == null) return;

    try {
      if (SoonestAppointmentHelpers.canDelayAppointment(_soonestAppointment!, delay)) {
        final delayedAppointment = SoonestAppointmentHelpers.delayAppointment(
          _soonestAppointment!,
          delay,
        );

        final appointmentProvider = context.read<AppointmentProvider>();
        await appointmentProvider.rescheduleAppointment(
          delayedAppointment['id'] as String,
          DateTime.parse(delayedAppointment['dateTime'] as String),
          DateTime.parse(delayedAppointment['dateTime'] as String).add(const Duration(minutes: 30)),
        );

        widget.onAppointmentDelayed?.call(delayedAppointment);

        setState(() {
          _soonestAppointment = delayedAppointment;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment delayed by ${delay.inMinutes} minutes'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        widget.onAppointmentRescheduleNeeded?.call(_soonestAppointment!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cannot delay. Please reschedule.'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating appointment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAppointmentDetails(BuildContext context) {
    if (_soonestAppointment == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.almostBlack600 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _soonestAppointment!['shopName'] ?? 'Barber Shop',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, Icons.access_time_filled, 'Time', SoonestAppointmentHelpers.formatAppointmentDateTime(_soonestAppointment!['dateTime'])),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.person_rounded, 'Barber', _soonestAppointment!['barberName'] ?? 'Any available Specialist'),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.cut_rounded, 'Service', _soonestAppointment!['serviceName'] ?? 'Haircut / Shave'),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.payments_rounded, 'Price', '${_soonestAppointment!['price'] ?? '25'} JOD'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Cancel Appointment', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_hasError || _soonestAppointment == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NEXT APPOINTMENT',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Icon(Icons.calendar_month, color: Theme.of(context).primaryColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _soonestAppointment!['shopName'] ?? 'Barber Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time_filled, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                SoonestAppointmentHelpers.formatAppointmentDateTime(_soonestAppointment!['dateTime']),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleDelayAppointment,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Delay',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAppointmentDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DelayAppointmentDialog extends StatefulWidget {
  final Map<String, dynamic> currentAppointment;

  const _DelayAppointmentDialog({required this.currentAppointment});

  @override
  State<_DelayAppointmentDialog> createState() => _DelayAppointmentDialogState();
}

class _DelayAppointmentDialogState extends State<_DelayAppointmentDialog> {
  int _selectedMinutes = 5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      backgroundColor: isDark ? AppColors.almostBlack600 : AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Delay Appointment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('How many minutes would you like to delay your appointment by?'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [5, 10, 15].map((mins) {
                final isSelected = _selectedMinutes == mins;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMinutes = mins),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : (isDark ? AppColors.almostBlack400 : Theme.of(context).primaryColor.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$mins min',
                      style: TextStyle(
                        color: isSelected ? AppColors.white : (isDark ? AppColors.white : Theme.of(context).primaryColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Confirm Delay',
              onPressed: () => Navigator.pop(context, Duration(minutes: _selectedMinutes)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? AppColors.cream400 : AppColors.almostBlack400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
