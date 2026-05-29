import 'package:flutter/material.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';

/// Staff Time Clock widget — Clock In / Clock Out.
/// Shown on Expert Dashboard.  (Fresha / Bodrah / WAJ parity)
class TimeClockWidget extends StatefulWidget {
  const TimeClockWidget({super.key});

  @override
  State<TimeClockWidget> createState() => _TimeClockWidgetState();
}

class _TimeClockWidgetState extends State<TimeClockWidget>
    with SingleTickerProviderStateMixin {
  bool _isClockedIn = false;
  DateTime? _clockInTime;
  bool _isLoading = true;
  bool _isProcessing = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadStatus();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final res = await api.get('/salons/timeclock/current_status/');
      if (res is Map) {
        setState(() {
          _isClockedIn = res['is_clocked_in'] as bool? ?? false;
          final rawTime = res['clock_in'];
          if (rawTime != null) {
            _clockInTime = DateTime.tryParse(rawTime.toString());
          }
        });
      }
    } catch (_) {
      // Silently ignore — widget degrades gracefully
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clockIn() async {
    setState(() => _isProcessing = true);
    try {
      final api = ApiService();
      final res = await api.post('/salons/timeclock/clock_in/', data: {});
      if (res != null) {
        setState(() {
          _isClockedIn = true;
          _clockInTime =
              DateTime.tryParse((res as Map)['clock_in']?.toString() ?? '') ??
              DateTime.now();
        });
        if (mounted)
          AppSnackBar.success(context, 'clocked_in_successfully'.tr());
      }
    } catch (e) {
      if (mounted)
        AppSnackBar.error(context, 'clock_in_failed'.tr(args: [e.toString()]));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _clockOut() async {
    setState(() => _isProcessing = true);
    try {
      final api = ApiService();
      final res = await api.post('/salons/timeclock/clock_out/', data: {});
      if (res != null) {
        final mins = (res as Map)['shift_duration_minutes'] as int? ?? 0;
        setState(() {
          _isClockedIn = false;
          _clockInTime = null;
        });
        if (mounted) {
          final h = mins ~/ 60;
          final m = mins % 60;
          AppSnackBar.success(
            context,
            'clocked_out_msg'.tr(args: [h.toString(), m.toString()]),
          );
        }
      }
    } catch (e) {
      if (mounted)
        AppSnackBar.error(context, 'clock_out_failed'.tr(args: [e.toString()]));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  String _elapsed() {
    if (_clockInTime == null) return 'zero_time'.tr();
    final diff = DateTime.now().difference(_clockInTime!);
    return 'duration_hm'.tr(
      args: [diff.inHours.toString(), diff.inMinutes.remainder(60).toString()],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isClockedIn
              ? [Colors.green.shade700, Colors.green.shade500]
              : [theme.cardColor, theme.cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isClockedIn
              ? Colors.green.withValues(alpha:0.6)
              : theme.dividerColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isClockedIn
                ? Colors.green.withValues(alpha:0.25)
                : Colors.black.withValues(alpha:0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Status indicator
                ScaleTransition(
                  scale: _isClockedIn
                      ? _pulseAnim
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isClockedIn
                          ? Colors.white.withValues(alpha:0.2)
                          : AppColors.primary.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isClockedIn
                          ? Icons.timer_rounded
                          : Icons.timer_off_rounded,
                      color: _isClockedIn ? Colors.white : AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isClockedIn ? 'on_shift'.tr() : 'not_clocked_in'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _isClockedIn
                              ? Colors.white
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      if (_isClockedIn) ...[
                        const SizedBox(height: 2),
                        Text(
                          'elapsed_time_msg'.tr(args: [_elapsed()]),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        Text(
                          'tap_to_start_your_shift'.tr(),
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Action button
                _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _isClockedIn ? _clockOut : _clockIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isClockedIn
                              ? Colors.white
                              : AppColors.primary,
                          foregroundColor: _isClockedIn
                              ? Colors.green
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isClockedIn ? 'clock_out'.tr() : 'clock_in'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
    );
  }
}
