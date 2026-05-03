import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/intern_provider.dart';
import '../../../../core/theme/colors.dart';

class InternActivityPage extends StatefulWidget {
  const InternActivityPage({super.key});

  @override
  State<InternActivityPage> createState() => _InternActivityPageState();
}

class _InternActivityPageState extends State<InternActivityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InternProvider>().fetchInternActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InternProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("intern_activity".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchInternActivity(),
        child: provider.isLoading && provider.activityData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, provider, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, InternProvider provider, bool isDark) {
    final tasks = provider.activityData['tasks'] as List? ?? [];
    final feedbacks = provider.activityData['feedbacks'] as List? ?? [];
    final attendance = provider.activityData['attendance'] as List? ?? [];

    if (tasks.isEmpty && feedbacks.isEmpty && attendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: AppColors.almostBlack200),
            const SizedBox(height: 16),
            Text('No recent activity', style: TextStyle(color: AppColors.almostBlack300)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (attendance.isNotEmpty) ...[
          _SectionHeader(title: 'Attendance'.tr().toUpperCase(), color: Colors.green),
          const SizedBox(height: 12),
          ...attendance.map((item) => _buildActivityItem(context, item, 'attendance', Colors.green, isDark)),
          const SizedBox(height: 24),
        ],
        if (tasks.isNotEmpty) ...[
          _SectionHeader(title: 'Tasks'.tr().toUpperCase(), color: AppColors.blue),
          const SizedBox(height: 12),
          ...tasks.map((item) => _buildActivityItem(context, item, 'task', AppColors.blue, isDark)),
          const SizedBox(height: 24),
        ],
        if (feedbacks.isNotEmpty) ...[
          _SectionHeader(title: 'feedback'.tr().toUpperCase(), color: AppColors.success),
          const SizedBox(height: 12),
          ...feedbacks.map((item) => _buildActivityItem(context, item, 'feedback', AppColors.success, isDark)),
        ],
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> item, String type, Color color, bool isDark) {
    String title = '';
    String date = '';
    String status = '';
    IconData icon;

    switch (type) {
      case 'attendance':
        title = 'Shift: ${DateFormat.jm().format(DateTime.parse(item['clock_in']))}';
        if (item['clock_out'] != null) {
          title += ' - ${DateFormat.jm().format(DateTime.parse(item['clock_out']))}';
        }
        date = DateFormat('MMM dd, yyyy').format(DateTime.parse(item['clock_in']));
        status = item['status'] ?? '';
        icon = Icons.access_time_filled_rounded;
        break;
      case 'task':
        title = item['title'] ?? 'Task';
        date = item['created_at'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(item['created_at'])) : '';
        status = item['is_completed'] == true ? 'Completed' : 'Pending';
        icon = Icons.assignment_rounded;
        break;
      case 'feedback':
        title = item['feedback_text'] ?? 'Feedback';
        date = item['created_at'] != null ? DateFormat('MMM dd, yyyy').format(DateTime.parse(item['created_at'])) : '';
        icon = Icons.chat_bubble_rounded;
        break;
      default:
        icon = Icons.notifications_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(type.tr().toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    Text(date, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          if (status.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (status == 'Completed' || status == 'COMPLETED' ? AppColors.success : AppColors.almostBlack50).withOpacity(0.1), 
                borderRadius: BorderRadius.circular(6)
              ),
              child: Text(
                status.replaceAll('_', ' '), 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w600, 
                  color: (status == 'Completed' || status == 'COMPLETED') ? AppColors.success : AppColors.almostBlack400
                )
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.almostBlack300, letterSpacing: 1.2)),
      ],
    );
  }
}
