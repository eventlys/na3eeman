import 'package:easy_localization/easy_localization.dart';
// Add this simple dialog class before your ReportsPage class
import 'package:flutter/material.dart';

import '../../../Services/business_service.dart';
import '../../../Services/enums/report_enums.dart';
// import 'package:easy_localization/easy_localization.dart';

class SimpleReportDialog extends StatelessWidget {
  final StaffReportRequest initialRequest;

  const SimpleReportDialog({super.key, required this.initialRequest});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("report_options".tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report: ${initialRequest.reportType.toString().split('.').last}',
          ),
          const SizedBox(height: 8),
          Text('Period: ${_getTimeDisplayName(initialRequest.time)}'),
          const SizedBox(height: 8),
          Text(
            'Date Range: ${_formatDate(initialRequest.startDate)} - ${_formatDate(initialRequest.endDate)}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text("cancel".tr()),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(initialRequest),
          child: Text("generate".tr()),
        ),
      ],
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
