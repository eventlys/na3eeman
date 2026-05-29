import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Providers/features/staff_provider.dart';

class InternAttendanceReportPage extends StatefulWidget {
  const InternAttendanceReportPage({super.key});

  @override
  State<InternAttendanceReportPage> createState() =>
      _InternAttendanceReportPageState();
}

class _InternAttendanceReportPageState
    extends State<InternAttendanceReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchInternAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Intern Attendance'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButtonStyled(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => staffProvider.fetchInternAttendance(),
        child: staffProvider.isLoading && staffProvider.attendanceLogs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : staffProvider.attendanceLogs.isEmpty
            ? _buildEmptyState(isDark)
            : _buildAttendanceList(staffProvider, isDark),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.almostBlack300.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance records found'.tr(),
            style: TextStyle(color: AppColors.almostBlack300, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(StaffProvider provider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.attendanceLogs.length,
      itemBuilder: (context, index) {
        final log = provider.attendanceLogs[index];
        final duration = log.clockOut != null
            ? log.clockOut!.difference(log.clockIn)
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack700 : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.almostBlack100.withValues(alpha:0.1)
                  : AppColors.almostBlack50,
            ),
          ),
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
                          log.userName ?? 'Intern',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMM dd').format(log.clockIn),
                          style: const TextStyle(
                            color: AppColors.almostBlack300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(log.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  _buildTimeInfo(
                    'In'.tr(),
                    DateFormat.jm().format(log.clockIn),
                    Icons.login_rounded,
                    Colors.green,
                  ),
                  const SizedBox(width: 32),
                  _buildTimeInfo(
                    'Out'.tr(),
                    log.clockOut != null
                        ? DateFormat.jm().format(log.clockOut!)
                        : '--:--',
                    Icons.logout_rounded,
                    log.clockOut != null ? Colors.orange : Colors.grey,
                  ),
                  const Spacer(),
                  if (duration != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Duration'.tr(),
                          style: const TextStyle(
                            color: AppColors.almostBlack300,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (log.location != null && log.location!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.almostBlack300,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      log.location!,
                      style: const TextStyle(
                        color: AppColors.almostBlack300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'ON_SHIFT':
        color = Colors.green;
        break;
      case 'COMPLETED':
        color = Colors.blue;
        break;
      case 'LATE':
        color = Colors.orange;
        break;
      case 'ABSENT':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(
    String label,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.almostBlack300,
                fontSize: 10,
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
