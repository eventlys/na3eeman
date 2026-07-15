import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/customized/soonest_appointment_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
// import 'package:easy_localization/easy_localization.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSoonestAppointment();
      }
    });
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
      final appointment = await appointmentProvider.getSoonestAppointment(
        authProvider.user!.id,
      );

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

    final result = await showDialog<int>(
      context: context,
      builder: (context) =>
          _DelayAppointmentDialog(currentAppointment: _soonestAppointment!),
    );

    if (result != null && mounted) {
      _processDelay(result);
    }
  }

  void _processDelay(int minutes) async {
    if (_soonestAppointment == null) return;

    try {
      final appointmentProvider = context.read<AppointmentProvider>();
      final pointsProvider = context.read<PointsProvider>();

      await appointmentProvider.delayAppointment(
        _soonestAppointment!['id'].toString(),
        minutes,
      );

      // Refresh points as they were deducted
      await pointsProvider.loadBalance();
      await _loadSoonestAppointment();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment delayed by $minutes minutes'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('points')
                  ? 'Insufficient points for this delay'
                  : 'Error updating appointment',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleRepeatAppointment(String? recurrence) async {
    if (recurrence == null || recurrence == 'NONE') return;

    // Simulate updating recurrence or call API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Setting appointment to repeat: $recurrence')),
    );
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
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _soonestAppointment!['salonName'] ?? 'Expert Salon',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              Icons.access_time_filled,
              'Time',
              SoonestAppointmentHelpers.formatAppointmentDateTime(
                _soonestAppointment!['dateTime'],
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.person_rounded,
              'Expert',
              _soonestAppointment!['expertName'] ?? 'Any available Specialist',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.cut_rounded,
              'Service',
              _soonestAppointment!['serviceName'] ?? 'Haircut / Shave',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.payments_rounded,
              'Price',
              '${_soonestAppointment!['price'] ?? '25'} JOD',
            ),
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
                    child: const Text(
                      'Cancel Appointment',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    child: Text("close".tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_hasError || _soonestAppointment == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Upcoming appointments',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () => _showAppointmentDetails(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.almostBlack600 : AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.1)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NEXT APPOINTMENT',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _soonestAppointment!['salonName'] ?? 'Expert Salon',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      SoonestAppointmentHelpers.formatAppointmentDateTime(
                        _soonestAppointment!['dateTime'],
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isDense: true,
                          value: _soonestAppointment!['recurrence'] ?? 'NONE',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'NONE',
                              child: Text('No Repeat'),
                            ),
                            DropdownMenuItem(
                              value: 'WEEKLY',
                              child: Text('Weekly'),
                            ),
                            DropdownMenuItem(
                              value: 'BIWEEKLY',
                              child: Text('Bi-Weekly'),
                            ),
                            DropdownMenuItem(
                              value: 'MONTHLY',
                              child: Text('Monthly'),
                            ),
                          ],
                          onChanged: _handleRepeatAppointment,
                        ),
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
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
          ),
        ),
      ],
    );
  }
}

class _DelayAppointmentDialog extends StatefulWidget {
  final Map<String, dynamic> currentAppointment;

  const _DelayAppointmentDialog({required this.currentAppointment});

  @override
  State<_DelayAppointmentDialog> createState() =>
      _DelayAppointmentDialogState();
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your delay. Note: This will cost you loyalty points.',
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                _delayOption(5, 10, isDark),
                const SizedBox(height: 12),
                _delayOption(10, 20, isDark),
                const SizedBox(height: 12),
                _delayOption(15, 30, isDark),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Confirm Delay',
              onPressed: () => Navigator.pop(context, _selectedMinutes),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr(),
                style: TextStyle(
                  color: isDark ? AppColors.cream400 : AppColors.almostBlack400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _delayOption(int minutes, int points, bool isDark) {
    final isSelected = _selectedMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _selectedMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : (isDark
                    ? AppColors.almostBlack400
                    : Theme.of(context).primaryColor.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$minutes Minutes',
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : (isDark ? AppColors.white : Colors.black),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '-$points Points',
              style: TextStyle(
                color: isSelected
                    ? AppColors.white.withValues(alpha: 0.8)
                    : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
