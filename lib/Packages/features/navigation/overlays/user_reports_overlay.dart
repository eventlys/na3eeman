import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// import '../../../../core/enums/app_enums.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/business_service.dart';
import '../../../../Services/enums/report_enums.dart';
// import 'package:easy_localization/easy_localization.dart';


class UserReportsOverlay extends StatefulWidget {
  const UserReportsOverlay({super.key});

  @override
  State<UserReportsOverlay> createState() => _UserReportsOverlayState();
}

class _UserReportsOverlayState extends State<UserReportsOverlay> {
  final ReportService _reportService = ReportService();
  final BusinessService _businessService = BusinessService();

  List<dynamic> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserReports();
  }

  Future<void> _loadUserReports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current user from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user == null || !authProvider.isAuthenticated) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final int currentUserId = authProvider.user!.id;

      // Fetch reports where current user is the subject (reported by others)
      final reports = await _fetchReportsAboutUser(currentUserId);

      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchReportsAboutUser(int userId) async {
    try {
      final response = await ApiService().get(
        '/reports/about-user/$userId',
        queryParams: {'include_resolved': 'false'},
      );

      if (response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderSection(authProvider),
          const SizedBox(height: 10),
          _buildStatsSection(),
          const SizedBox(height: 10),
          Expanded(
            child: _buildReportsList(authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports About You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Role: ${authProvider.user?.role.name ?? 'Customer'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _isLoading ? null : _loadUserReports,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    if (_isLoading) {
      return _buildLoadingStats();
    }

    if (_error != null) {
      return _buildErrorStats();
    }

    final totalCount = _reports.length;
    final resolvedCount = _reports.where((r) =>
      _getReportStatus(r) == 'resolved'
    ).length;
    final pendingCount = totalCount - resolvedCount;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x80F3E0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalCount.toString(), Colors.blue),
          _buildStatItem('Resolved', resolvedCount.toString(), Colors.green),
          _buildStatItem('Pending', pendingCount.toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x80F3E0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LoadingStatItem(),
          _LoadingStatItem(),
          _LoadingStatItem(),
        ],
      ),
    );
  }

  Widget _buildErrorStats() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'Error loading reports',
          style: TextStyle(
            color: Colors.red.shade300,
            fontSize: 14,
          ),
        ),
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

  Widget _buildReportsList(AuthProvider authProvider) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadUserReports,
              child: Text("retry".tr()),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'No reports found',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great! You have no reports against you.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (authProvider.isCustomer) ...[
              const SizedBox(height: 16),
              const Text(
                'Keep following the community guidelines',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportItem(report);
      },
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final reporterName = report['reporter_name'] ?? 'Unknown';
    final reporterRole = report['reporter_role'] ?? 'USER';
    final description = report['description'] ?? 'No description';
    final date = DateTime.tryParse(report['date'] ?? '') ?? DateTime.now();
    final type = _parseReportType(report['type'] ?? 'user');
    final status = _getReportStatus(report);

    return Card(
      color: const Color(0x4dffffff),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getReportIcon(type),
        title: Text(
          description,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Reported by: $reporterName ($reporterRole)',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${_formatDate(date)} • ${_getTypeText(type)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: _getStatusWidget(status),
        onTap: () => _showReportDetails(context, report),
      ),
    );
  }

  ReportType _parseReportType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'user':
        return ReportType.user;
      case 'salon':
        return ReportType.salon;
      case 'content':
        return ReportType.content;
      case 'staff':
        return ReportType.staff;
      case 'financial':
        return ReportType.financial;
      case 'inventory':
        return ReportType.inventory;
      default:
        return ReportType.user;
    }
  }

  String _getReportStatus(Map<String, dynamic> report) {
    return report['status'] ?? 'pending';
  }

  Widget _getReportIcon(ReportType type) {
    switch (type) {
      case ReportType.user:
        return const Icon(Icons.person, color: Colors.blue);
      case ReportType.salon:
        return const Icon(Icons.store, color: Colors.green);
      case ReportType.content:
        return const Icon(Icons.content_copy, color: Colors.orange);
      case ReportType.staff:
        return const Icon(Icons.people, color: Colors.purple);
      case ReportType.financial:
        return const Icon(Icons.attach_money, color: Colors.green);
      case ReportType.inventory:
        return const Icon(Icons.inventory, color: Colors.brown);
    }
  }

  Widget _getStatusWidget(String status) {
    final isResolved = status == 'resolved';
    final isNew = status == 'new';

    Color color;
    String text;

    if (isResolved) {
      color = Colors.green;
      text = 'Resolved';
    } else if (isNew) {
      color = Colors.blue;
      text = 'New';
    } else {
      color = Colors.orange;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
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
      case ReportType.salon:
        return 'Salon Report';
      case ReportType.content:
        return 'Content Report';
      case ReportType.staff:
        return 'Staff Report';
      case ReportType.financial:
        return 'Financial Report';
      case ReportType.inventory:
        return 'Inventory Report';
    }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    final reporterName = report['reporter_name'] ?? 'Unknown';
    final reporterRole = report['reporter_role'] ?? 'USER';
    final description = report['description'] ?? 'No description';
    final date = DateTime.tryParse(report['date'] ?? '') ?? DateTime.now();
    final type = _parseReportType(report['type'] ?? 'user');
    final status = _getReportStatus(report);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Details - ${_getTypeText(type)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reported by: $reporterName ($reporterRole)'),
              Text('Date: ${_formatDate(date)}'),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(description),
              const SizedBox(height: 16),
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                status == 'resolved'
                  ? 'Resolved - Issue has been addressed'
                  : status == 'new'
                    ? 'New - Under Review'
                    : 'Pending - Investigation in progress',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("close".tr()),
          ),
          if (status != 'resolved')
            ElevatedButton(
              onPressed: () {
                // In a real app, you would call an API to respond to the report
                _respondToReport(report['id']);
                Navigator.of(context).pop();
              },
              child: const Text('Respond'),
            ),
        ],
      ),
    );
  }

  void _respondToReport(String reportId) {
    // Implement response logic here
    // This would typically open a dialog or navigate to a response page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Response feature would be implemented here'),
      ),
    );
  }
}

class _LoadingStatItem extends StatelessWidget {
  const _LoadingStatItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
