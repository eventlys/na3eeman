import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../../../Providers/features/appointment_provider.dart';
import '../../../../../Models/appointments/salon_appointments_model.dart';
import 'package:easy_localization/easy_localization.dart';

class AppointmentSearchPage extends StatefulWidget {
  const AppointmentSearchPage({super.key});

  @override
  State<AppointmentSearchPage> createState() => _AppointmentSearchPageState();
}

class _AppointmentSearchPageState extends State<AppointmentSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _triggerSearch() {
    if (!mounted) return;
    context.read<AppointmentProvider>().loadAppointments(
      query: _searchQuery,
      date: _selectedDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentProvider = context.watch<AppointmentProvider>();
    final filteredAppointments = appointmentProvider.appointments;

    return Scaffold(
      appBar: AppBar(title: Text("search_appointments".tr())),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildDateFilter(context, isDark),
          Expanded(
            child: appointmentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAppointments.isEmpty
                ? const Center(
                    child: Text('No appointments found matching criteria'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = filteredAppointments[index];
                      return _buildAppointmentCard(context, appt, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), _triggerSearch);
        },
        decoration: InputDecoration(
          hintText: 'Search by Customer, ID, or Expert...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: isDark
              ? AppColors.almostBlack600
              : AppColors.almostBlack50.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ActionChip(
            avatar: const Icon(Icons.calendar_today_rounded, size: 16),
            label: Text(
              _selectedDate == null
                  ? 'All Dates'
                  : _selectedDate!.toString().split(' ')[0],
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _triggerSearch();
              }
            },
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: () {
                setState(() => _selectedDate = null);
                _triggerSearch();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    SalonAppointment appt,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _showAppointmentDetails(context, appt),
      child: DashboardCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${appt.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.almostBlack300,
                      fontSize: 12,
                    ),
                  ),
                  _buildStatusBadge(appt.status.value),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                appt.customerName ?? 'Customer #${appt.customerId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 14,
                    color: AppColors.almostBlack300,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appt.expertName ?? 'Expert #${appt.expertId ?? "N/A"}',
                    style: const TextStyle(
                      color: AppColors.almostBlack300,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.pink,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appt.startTime.toString().split('.')[0],
                    style: const TextStyle(
                      color: AppColors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${appt.totalAmount ?? 0.0} JOD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'SCHEDULED':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      case 'NO_SHOW':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, SalonAppointment appt) {
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
            const Text(
              'Appointment Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Appointment ID', appt.id.toString()),
            _buildDetailRow('Customer ID', appt.customerId.toString()),
            _buildDetailRow('Expert ID', appt.expertId?.toString() ?? 'N/A'),
            _buildDetailRow('Status', appt.status.value),
            _buildDetailRow('Start Time', appt.startTime.toString()),
            _buildDetailRow('End Time', appt.endTime.toString()),
            _buildDetailRow('Total Amount', '${appt.totalAmount} JOD'),
            _buildDetailRow('Deposit', '${appt.depositAmount} JOD'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.almostBlack300)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
