import 'package:flutter/material.dart';
import '../../../models/report_model.dart';

class UserReportsOverlay extends StatelessWidget {
  const UserReportsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReportModel> reports = [
      ReportModel(
        id: '1',
        reporterName: 'User A',
        description: 'Spam behavior in comments section',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: ReportType.user,
      ),
      ReportModel(
        id: '2',
        reporterName: 'Shop B',
        description: 'Inappropriate content in product review',
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: ReportType.content,
      ),
      ReportModel(
        id: '3',
        reporterName: 'User C',
        description: 'Suspicious activity detected',
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: ReportType.user,
      ),
    ];

    return Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatsSection(reports),
            const SizedBox(height: 20),
            Expanded(
              child: _buildReportsList(context, reports),
            ),
          ],
        ),
    );
  }

  Widget _buildStatsSection(List<ReportModel> reports) {
    final resolvedCount = reports.where((r) => r.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length;
    final pendingCount = reports.length - resolvedCount;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0x80F3E0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', reports.length.toString(), Colors.blue),
          _buildStatItem('Resolved', resolvedCount.toString(), Colors.green),
          _buildStatItem('Pending', pendingCount.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xffffffff)),
        ),
      ],
    );
  }

  Widget _buildReportsList(BuildContext context, List<ReportModel> reports) { // Accept context as parameter
    return ListView.builder(
      shrinkWrap: true,
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportItem(context, report); // Pass context to _buildReportItem
      },
    );
  }

  Widget _buildReportItem(BuildContext context, ReportModel report) { // Accept context as parameter
    return Card(
      color: Color(0x4dffffff),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getReportIcon(report.type),
        title: Text(
          report.description,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: ${report.reporterName}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${_formatDate(report.date)} • ${_getTypeText(report.type)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: _getStatusWidget(report.date),
        onTap: () => _showReportDetails(context, report), // Pass context to _showReportDetails
      ),
    );
  }

  Widget _getReportIcon(ReportType type) {
    switch (type) {
      case ReportType.user:
        return const Icon(Icons.person, color: Colors.blue);
      case ReportType.shop:
        return const Icon(Icons.store, color: Colors.green);
      case ReportType.content:
        return const Icon(Icons.content_copy, color: Colors.orange);
    }
  }

  Widget _getStatusWidget(DateTime date) {
    final isRecent = date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRecent ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isRecent ? 'New' : 'Pending',
        style: TextStyle(
          fontSize: 10,
          color: isRecent ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTypeText(ReportType type) {
    switch (type) {
      case ReportType.user:
        return 'User Report';
      case ReportType.shop:
        return 'Shop Report';
      case ReportType.content:
        return 'Content Report';
    }
  }

  void _showReportDetails(BuildContext context, ReportModel report) { // Accept context as parameter
    showDialog(
      context: context, // Now context is available
      builder: (context) => AlertDialog(
        title: Text('Report Details - ${_getTypeText(report.type)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reporter: ${report.reporterName}'),
              Text('Date: ${_formatDate(report.date)}'),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.description),
              const SizedBox(height: 16),
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))
                  ? 'New - Under Review'
                  : 'Pending - Investigation in progress'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement mark as resolved
              Navigator.of(context).pop();
            },
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }
}

