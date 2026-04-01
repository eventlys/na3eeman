import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/main_providers.dart';
import '../../../Services/business_service.dart';
import '../../../Services/enums/report_enums.dart';
import '../../Core/constants/app_color.dart';
import '../../Core/constants/app_images.dart';
import '../../Core/themes/app_scaffold.dart';
import 'report_download_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportTime _selectedTime = ReportTime.monthly;
  final BusinessService _businessService = BusinessService();

  @override
  Widget build(BuildContext context) {
    return GlassPage(
      title: 'reports'.tr(),
      showBackButton: true,
      user: Provider.of<AuthProvider>(context, listen: false).user,
      glassExpandedHeight: 180,
      glassCollapsedHeight: 80,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildReportTypeSelector(),
          ),
          _buildReportList(),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Period',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.darkText
                    : AppColor.lightText,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReportTime>(
              value: _selectedTime,
              onChanged: (time) {
                setState(() {
                  _selectedTime = time!;
                });
              },
              items: ReportTime.values.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text(
                    _getTimeDisplayName(time),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColor.darkText
                          : AppColor.lightText,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColor.darkCard
                    : AppColor.lightCard,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reports = [
            _ReportItem(
              title: 'staff_performance_report'.tr(),
              description: 'Detailed analysis of barber performance',
              icon: AppImages.file_star,
              color: AppColor.lightInfo,
              darkColor: AppColor.darkInfo,
            ),
            _ReportItem(
              title: 'Financial Report',
              description: 'Revenue, expenses and profit analysis',
              icon: AppImages.money,
              color: AppColor.lightSuccess,
              darkColor: AppColor.darkSuccess,
            ),
            _ReportItem(
              title: 'Appointment Report',
              description: 'Booking and scheduling overview',
              icon: AppImages.calender,
              color: AppColor.lightWarning,
              darkColor: AppColor.darkWarning,
            ),
            _ReportItem(
              title: 'Inventory Report',
              description: 'Product usage and stock levels',
              icon: AppImages.inventory,
              color: AppColor.lightAccent,
              darkColor: AppColor.darkAccent,
            ),
          ];

          final report = reports[index];
          return _buildReportCard(
            report.title,
            report.description,
            report.icon,
            report.color,
            report.darkColor,
          );
        },
        childCount: 4,
      ),
    );
  }

  Widget _buildReportCard(String title, String description, String icon, Color lightColor, Color darkColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? darkColor : lightColor;
    final iconColor = isDark ? AppColor.darkText : AppColor.lightText;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColor.darkCard : AppColor.lightCard,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColor.darkText : AppColor.lightText,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary,
          ),
        ),
        trailing: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppImages.download,
              width: 20,
              height: 20,
              color: AppColor.primary,
            ),
          ),
          onPressed: () => _downloadReport(title),
        ),
      ),
    );
  }

  void _downloadReport(String reportName) async {
    try {
      // Determine report type based on the report name
      final StaffReportType reportType = _getReportTypeFromName(reportName);

      final request = StaffReportRequest(
        time: _selectedTime,
        startDate: _getStartDate(),
        endDate: DateTime.now(),
        fileName: '${reportName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
        reportType: reportType,
      );

      final updatedRequest = await showDialog<StaffReportRequest>(
        context: context,
        builder: (context) => SimpleReportDialog(initialRequest: request),
      );

      if (updatedRequest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('generating_report'.tr()),
            backgroundColor: AppColor.primary,
          ),
        );

        // Get shop ID from auth provider or context
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final shopId = authProvider.user?.shopId;
        if (shopId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shop associated with operations not found.'),
              backgroundColor: AppColor.lightError,
            ),
          );
          return;
        }

        // Use BusinessService to generate the report
        await _businessService.generateStaffReport(
          updatedRequest,
          shopId: shopId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('report_success'.tr()),
            backgroundColor: AppColor.lightSuccess,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: $e'),
          backgroundColor: AppColor.lightError,
        ),
      );
    }
  }

  // Helper method to determine report type from name
  StaffReportType _getReportTypeFromName(String reportName) {
    switch (reportName.toLowerCase()) {
      case 'staff performance report':
        return StaffReportType.performance;
      case 'financial report':
        return StaffReportType.payroll;
      case 'appointment report':
        return StaffReportType.attendance;
      case 'inventory report':
        return StaffReportType.monthly;
      default:
        return StaffReportType.monthly;
    }
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedTime) {
      case ReportTime.daily:
        return DateTime(now.year, now.month, now.day);
      case ReportTime.weekly:
        return now.subtract(const Duration(days: 7));
      case ReportTime.monthly:
        return DateTime(now.year, now.month, 1);
      case ReportTime.annually:
        return DateTime(now.year, 1, 1);
    }
  }

  String _getTimeDisplayName(ReportTime time) {
    switch (time) {
      case ReportTime.daily:
        return 'Daily';
      case ReportTime.weekly:
        return 'Weekly';
      case ReportTime.monthly:
        return 'Monthly';
      case ReportTime.annually:
        return 'Annually';
    }
  }
}

class _ReportItem {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final Color darkColor;

  _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.darkColor,
  });
}
