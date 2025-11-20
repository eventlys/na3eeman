import 'package:flutter/material.dart';

import '../../../../Models/olds/barber.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Utils/constants.dart';
import '../../../Widgets/custom_app_bar.dart';
import '../../../../components/common/loading_indicator.dart';
import '../../../Widgets/barber_performance_chart.dart';

class BarberPerformancePage extends StatefulWidget {
  const BarberPerformancePage({super.key});

  @override
  State<BarberPerformancePage> createState() => _BarberPerformancePageState();
}

class _BarberPerformancePageState extends State<BarberPerformancePage> {
  late Future<List<Barber>> _barbersFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _barbersFuture = _apiService.getBarbersTyped();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: 'Performance', showBackButton: true),
      body: FutureBuilder<List<Barber>>(
        future: _barbersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading performance data...');
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Failed to load performance data'),
            );
          }

          final barbers = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                BarberPerformanceChart(barbers: barbers),
                _buildPerformanceList(barbers),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceList(List<Barber> barbers) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...barbers.map((barber) => _buildPerformanceItem(barber)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(Barber barber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            child: Text(barber.name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${barber.totalAppointments} appointments • \$${barber.totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(barber.rating.toString()),
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}
