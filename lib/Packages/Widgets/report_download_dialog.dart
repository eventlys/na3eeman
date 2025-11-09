import 'package:flutter/material.dart';
import '../../Models/report_model.dart';
import '../../Models/staff_models.dart';
import '../../Utils/constants.dart';

class ReportDownloadDialog extends StatefulWidget {
  final StaffReportRequest initialRequest;

  const ReportDownloadDialog({super.key, required this.initialRequest});

  @override
  State<ReportDownloadDialog> createState() => _ReportDownloadDialogState();
}

class _ReportDownloadDialogState extends State<ReportDownloadDialog> {
  late StaffReportRequest _request;
  final _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _request = widget.initialRequest;
    _fileNameController.text = _request.fileName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download Report'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('File Format: PDF', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                hintText: 'Enter file name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _request = _copyWith(fileName: value);
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Report Period: ${_getTimeDisplayName(_request.time)}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Date Range: ${_formatDate(_request.startDate)} - ${_formatDate(_request.endDate)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_request),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
          ),
          child: const Text('Download', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  StaffReportRequest _copyWith({String? fileName}) {
    return StaffReportRequest(
      time: _request.time,
      startDate: _request.startDate,
      endDate: _request.endDate,
      branchId: _request.branchId,
      staffId: _request.staffId,
      fileName: fileName ?? _request.fileName,
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
