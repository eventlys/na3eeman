import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/admin_service_provider.dart';
import '../../../../core/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminServiceRequestsPage extends StatefulWidget {
  const AdminServiceRequestsPage({super.key});

  @override
  State<AdminServiceRequestsPage> createState() => _AdminServiceRequestsPageState();
}

class _AdminServiceRequestsPageState extends State<AdminServiceRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminServiceProvider>().fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminServiceProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("service_requests".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.requests.isEmpty
              ? const Center(child: Text('No service requests found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: provider.requests.length,
                  itemBuilder: (context, index) {
                    final request = provider.requests[index];
                    return _buildRequestCard(context, request, isDark);
                  },
                ),
    );
  }

  Widget _buildRequestCard(BuildContext context, dynamic request, bool isDark) {
    final status = request['status'] ?? 'pending';
    final user = request['user_name'] ?? 'Anonymous';
    final userType = request['user_type'] ?? 'Unknown';
    final text = request['text'] ?? '';
    final createdAt = request['created_at'] != null 
        ? DateTime.parse(request['created_at']).toLocal().toString().split('.')[0]
        : 'Unknown date';

    final statusColors = {
      'done': AppColors.success,
      'low_requests': AppColors.almostBlack300,
      'highly_required': AppColors.error,
      'canceled': AppColors.almostBlack200,
      'covered': AppColors.blue,
      'pending': AppColors.warning,
    };

    final color = statusColors[status] ?? AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
                    Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('$userType • $createdAt', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
                  ],
                ),
              ),
              _buildStatusDropdown(context, request['id'], status),
            ],
          ),
          const Divider(height: 32),
          Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, int id, String currentStatus) {
    final statusColors = {
      'done': AppColors.success,
      'low_requests': AppColors.almostBlack300,
      'highly_required': AppColors.error,
      'canceled': AppColors.almostBlack200,
      'covered': AppColors.blue,
      'pending': AppColors.warning,
    };

    final color = statusColors[currentStatus] ?? AppColors.warning;

    final statuses = [
      {'value': 'done', 'label': 'Done'},
      {'value': 'low_requests', 'label': 'Low Requests'},
      {'value': 'highly_required', 'label': 'Highly Required'},
      {'value': 'canceled', 'label': 'Canceled'},
      {'value': 'covered', 'label': 'Covered'},
    ];

    if (!statuses.any((s) => s['value'] == currentStatus)) {
        statuses.insert(0, {'value': currentStatus, 'label': currentStatus.replaceAll('_', ' ').toUpperCase()});
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          onChanged: (newValue) {
            if (newValue != null) {
              context.read<AdminServiceProvider>().updateRequestStatus(id, newValue);
            }
          },
          items: statuses.map((s) {
            final itemColor = statusColors[s['value']] ?? color;
            return DropdownMenuItem<String>(
              value: s['value'],
              child: Text(
                s['label']!,
                style: TextStyle(color: itemColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            );
          }).toList(),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 18),
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
