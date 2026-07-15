import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import '../../../../../Services/api/api_service.dart';
import '../../../../../Services/api/endpoints.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import 'package:na3eeman/Helpers/logger.dart';
// import '../../../../../Providers/main_providers.dart';

class TodayAppointmentsOverview extends StatefulWidget {
  final Function(int)? onCountLoaded;
  final double? todayEarnings;
  final int? completedToday;

  const TodayAppointmentsOverview({
    super.key,
    this.onCountLoaded,
    this.todayEarnings,
    this.completedToday,
  });

  @override
  State<TodayAppointmentsOverview> createState() =>
      _TodayAppointmentsOverviewState();
}

class _TodayAppointmentsOverviewState extends State<TodayAppointmentsOverview> {
  String _selectedFilter = 'all_filter'.tr();
  final List<String> _filters = ['all_filter', 'waiting', 'pending_payment'];
  List<Map<String, dynamic>> _todayAppointments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final response = await apiService.get(Endpoints.appointments);
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      final today = DateTime.now();
      final todayAppts = data.where((appt) {
        final start = DateTime.parse(appt['start_time']);
        return start.year == today.year &&
            start.month == today.month &&
            start.day == today.day;
      }).toList();

      if (!mounted) return;
      setState(() {
        _todayAppointments = todayAppts.map((appt) {
          final customer = appt['customer'] as Map<String, dynamic>?;
          return {
            'id': appt['id']?.toString() ?? '',
            'customerName': customer != null
                ? '${customer['first_name']} ${customer['last_name']}'
                : 'anonymous'.tr(),
            'time': DateFormat(
              'time_format_upper'.tr(),
            ).format(DateTime.parse(appt['start_time'])),
            'startTime': DateTime.parse(appt['start_time']),
            'endTime': DateTime.parse(appt['end_time']),
            'service': appt['service_name'] ?? 'Service',
            'status': appt['payment_status'] == 'PENDING'
                ? 'pending_payment'.tr()
                : appt['status'] == 'CHECKED_IN'
                ? 'waiting'.tr()
                : appt['status'] == 'COMPLETED'
                ? 'completed_status'.tr()
                : 'scheduled_status'.tr(),
            'statusColor': _getStatusColor(
              appt['status'] ?? 'scheduled_status',
            ),
            'customerId': customer != null ? customer['id'] : 0,
            'raw': appt, // Storing raw data for details popup
          };
        }).toList();
      });
      if (widget.onCountLoaded != null) {
        widget.onCountLoaded!(_todayAppointments.length);
      }
    } catch (e) {
      AppLogger.error('error loading today appointments grid', error: e);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return AppColors.warning;
      case 'CHECKED_IN':
        return AppColors.pink;
      case 'COMPLETED':
        return AppColors.success;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _handleCompleteAppointment(String id) async {
    setState(() {
      final appt = _todayAppointments.firstWhere((appt) => appt['id'] == id);
      appt['status'] = 'done_status'.tr();
      appt['statusColor'] = AppColors.success;
    });
    // Optional: Call API to complete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('appointment_completed_successfully'.tr()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _handlePenaltyAppointment(
    String id,
    int customerId,
    String reason,
  ) async {
    setState(() {
      final appt = _todayAppointments.firstWhere((appt) => appt['id'] == id);
      appt['status'] = reason;
      appt['statusColor'] = AppColors.error;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('points_reduced_msg'.tr(args: [reason])),
        backgroundColor: AppColors.error,
      ),
    );
  }

  bool _isAppointmentActive(Map<String, dynamic> appt) {
    final now = DateTime.now();
    final startTime = appt['startTime'] as DateTime;
    final endTime = appt['endTime'] as DateTime;
    final status = appt['status'] as String;
    return status != 'done_status'.tr() &&
        status != 'canceled_status'.tr() &&
        status != 'too_late_status'.tr() &&
        now.isAfter(startTime) &&
        now.isBefore(endTime);
  }

  void _showAppointmentDetails(Map<String, dynamic> appt) {
    final raw = appt['raw'] as Map<String, dynamic>;
    final customer = raw['customer'] as Map<String, dynamic>?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'appointment_details'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('customer_label'.tr(), appt['customerName']),
            _buildDetailRow(
              'time'.tr(),
              '${appt['time']} (${DateFormat('MMM d').format(appt['startTime'])})',
            ),
            _buildDetailRow('services'.tr(), appt['service']),
            _buildDetailRow('status_label'.tr(), appt['status']),
            _buildDetailRow(
              'customer_phone_label'.tr(),
              customer?['phone'] ?? 'n_a'.tr(),
            ),
            _buildDetailRow(
              'amount_label'.tr(),
              raw['price']?.toString() ?? '15.00',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.almostBlack300)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _todayAppointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeNowAppts = _todayAppointments
        .where(_isAppointmentActive)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Appointment Banner
        if (activeNowAppts.isNotEmpty) ...[
          Builder(
            builder: (context) {
              final activeAppointment = activeNowAppts.first;
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'active_now'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activeAppointment['customerName'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${activeAppointment['time']} • ${activeAppointment['service']}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleCompleteAppointment(
                              activeAppointment['id'] as String,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              'complete'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handlePenaltyAppointment(
                              activeAppointment['id'] as String,
                              activeAppointment['customerId'] as int,
                              'canceled_status'.tr(),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                            ),
                            child: Text("cancel".tr()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handlePenaltyAppointment(
                              activeAppointment['id'] as String,
                              activeAppointment['customerId'] as int,
                              'too_late_status'.tr(),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('too_late_status'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        // Stats Row (Integrated if helpful for unification)
        Row(
          children: [
            Expanded(
              child: DashboardSummaryCard(
                title: 'today_s_earnings'.tr(),
                value:
                    '\$${widget.todayEarnings?.toStringAsFixed(2) ?? "0.00"}',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DashboardSummaryCard(
                title: "completed".tr(),
                value:
                    '${widget.completedToday ?? _todayAppointments.where((a) => a['status'] == 'done_status'.tr() || a['status'] == 'completed_status'.tr()).length}',
                icon: Icons.check_circle_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Section Header
        DashboardSectionHeader(title: 'today_s_appointments'.tr()),
        const SizedBox(height: 16),
        _buildAppointmentStatesFilter(),
        const SizedBox(height: 12),

        ..._todayAppointments
            .where(
              (appt) => _selectedFilter == 'all_filter'.tr()
                  ? appt['status'] != 'done_status'.tr()
                  : appt['status'] == _selectedFilter,
            )
            .map((appt) {
              final isActive = _isAppointmentActive(appt);

              if (isActive) {
                // Swipe Actions for Active Appointments
                return Dismissible(
                  key: Key(appt['id'] as String),
                  background: _buildSwipeBackground(
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                    label: 'mark_done'.tr(),
                    alignment: Alignment.centerLeft,
                  ),
                  secondaryBackground: _buildSwipeBackground(
                    color: AppColors.error,
                    icon: Icons.cancel_rounded,
                    label: 'mark_late'.tr(),
                    alignment: Alignment.centerRight,
                  ),
                  child: _buildAppointmentItemWrapper(appt),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Swipe Right -> Mark Done
                      _handleCompleteAppointment(appt['id'] as String);
                    } else if (direction == DismissDirection.endToStart) {
                      // Swipe Left -> Mark Late
                      _handlePenaltyAppointment(
                        appt['id'] as String,
                        appt['customerId'] as int,
                        'too_late_status'.tr(),
                      );
                    }
                    return false; // Prevents removal from view hierarchy directly without setstate update
                  },
                  // child: _buildAppointmentItemWrapper(appt),
                );
              }
              return _buildAppointmentItemWrapper(appt);
            }),
      ],
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft)
            Icon(icon, color: Colors.white),
          if (alignment == Alignment.centerLeft) const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (alignment == Alignment.centerRight) const SizedBox(width: 8),
          if (alignment == Alignment.centerRight)
            Icon(icon, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildAppointmentItemWrapper(Map<String, dynamic> appt) {
    return GestureDetector(
      onTap: () => _showAppointmentDetails(appt),
      child: _buildAppointmentItem(
        appt['customerName'] as String,
        appt['time'] as String,
        appt['service'] as String,
        appt['status'] as String,
        appt['statusColor'] as Color,
      ),
    );
  }

  Widget _buildAppointmentStatesFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters
            .map(
              (filter) => _buildFilterChip(
                filter.tr(),
                _selectedFilter == filter.tr(),
                originalKey: filter,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected, {
    required String originalKey,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.white
                : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(
    String name,
    String time,
    String service,
    String status,
    Color statusColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.1)
              : AppColors.almostBlack50,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '$time • $service',
                  style: const TextStyle(
                    color: AppColors.almostBlack300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
