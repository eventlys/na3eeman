import 'package:flutter/material.dart';

import '../../../../Helpers/barber_list_helper.dart';
import '../../../../Services/barber_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/loading_indicator.dart';
import '../widgets/barber_performance_chart.dart';

class BarberPerformancePage extends StatefulWidget {
  const BarberPerformancePage({super.key});

  @override
  State<BarberPerformancePage> createState() => _BarberPerformancePageState();
}

class _BarberPerformancePageState extends State<BarberPerformancePage> {
  late Future<List<BarberPerformanceData>> _performanceDataFuture;
  final BarberService _barberService = BarberService();
  final PerformanceHelper _performanceHelper = PerformanceHelper();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performanceDataFuture = _loadPerformanceData();
  }

  Future<List<BarberPerformanceData>> _loadPerformanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final barbers = await _barberService.getBarbers();
      return _performanceHelper.calculatePerformanceMetrics(barbers);
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load performance data: $error';
      });
      throw Exception('Failed to load performance data: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _retryLoading() {
    setState(() {
      _errorMessage = null;
      _performanceDataFuture = _loadPerformanceData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Performance',
      showBackButton: true,
      showLoading: _isLoading,
      errorMessage: _errorMessage,
      onErrorRetry: _retryLoading,
      user: null, // Replace with actual user object if needed
      child: FutureBuilder<List<BarberPerformanceData>>(
        future: _performanceDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
            return const LoadingIndicator(message: 'Loading performance data...');
          }

          if (snapshot.hasError || snapshot.data == null) {
            // Error is already handled by StandardPage, but we show a fallback
            return _buildErrorFallback(snapshot.error);
          }

          final performanceData = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                BarberPerformanceChart(performanceData: performanceData),
                _buildPerformanceList(performanceData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorFallback(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppImages.error,
              width: 64,
              height: 64,
              color: AppColor.lightError,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load performance data',
              style: TextStyle(
                fontSize: 18,
                color: AppColor.lightTextSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.lightPrimary,
              ),
              child: Text(
                'Retry',
                style: TextStyle(color: AppColor.light),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceList(List<BarberPerformanceData> performanceData) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColor.lightCard,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.lightText,
              ),
            ),
            const SizedBox(height: 16),
            ...performanceData.map((data) => _buildPerformanceItem(data)),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(BarberPerformanceData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.borderLight.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColor.lightPrimary.withValues(alpha: 0.1),
            child: Image.asset(
              AppImages.scissors,
              width: 20,
              height: 20,
              color: AppColor.lightPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.barberName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.totalAppointments} appointments • \$${data.totalEarnings.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12, 
                    color: AppColor.lightTextSecondary
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              data.rating.toStringAsFixed(1),
              style: TextStyle(
                color: AppColor.lightPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColor.lightPrimary.withValues(alpha: 0.1),
            side: BorderSide(color: AppColor.lightPrimary.withValues(alpha: 0.3)),
          ),
        ],
      ),
    );
  }
}
