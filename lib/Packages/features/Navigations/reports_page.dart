import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportTime _selectedTime = ReportTime.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: 'Reports', showBackButton: true),
      body: Column(
        children: [
          _buildReportTypeSelector(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildReportCard(
                  'Staff Performance Report',
                  'Detailed analysis of barber performance',
                  Icons.assessment,
                  AppColors.primaryColor,
                ),
                _buildReportCard(
                  'Financial Report',
                  'Revenue, expenses and profit analysis',
                  Icons.attach_money,
                  AppColors.successColor,
                ),
                _buildReportCard(
                  'Appointment Report',
                  'Booking and scheduling overview',
                  Icons.calendar_today,
                  AppColors.secondaryColor,
                ),
                _buildReportCard(
                  'Inventory Report',
                  'Product usage and stock levels',
                  Icons.inventory,
                  AppColors.warningColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Period',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  child: Text(_getTimeDisplayName(time)),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadReport(title),
        ),
      ),
    );
  }

  void _downloadReport(String reportName) async {
    // Determine report type based on the report name
    final StaffReportType reportType = _getReportTypeFromName(reportName);

    final request = StaffReportRequest(
      time: _selectedTime,
      startDate: _getStartDate(),
      endDate: DateTime.now(),
      fileName: '${reportName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
      reportType: reportType, // Add the required parameter
    );

    final updatedRequest = await showDialog<StaffReportRequest>(
      context: context,
      builder: (context) => ReportDownloadDialog(initialRequest: request),
    );

    if (updatedRequest != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating report...')),
      );

      try {
        // Convert to Map and use instance access
        final requestMap = updatedRequest.toJson();
        final apiService = ApiService(); // Create instance
        final downloadUrl = await apiService.generateStaffReport(requestMap);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report downloaded: $downloadUrl')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
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
        return StaffReportType.monthly; // Default to monthly for inventory
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
