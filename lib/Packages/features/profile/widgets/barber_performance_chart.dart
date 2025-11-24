import 'package:flutter/material.dart';
import '../../../../Helpers/barber_list_helper.dart';
import '../../../Core/constants/app_color.dart';

class BarberPerformanceChart extends StatelessWidget {
  final List<BarberPerformanceData> performanceData;

  const BarberPerformanceChart({
    super.key, 
    required this.performanceData
  });

  @override
  Widget build(BuildContext context) {
    // Find max appointments for scaling
    final maxAppointments = performanceData.isNotEmpty 
        ? performanceData.map((data) => data.totalAppointments).reduce((a, b) => a > b ? a : b)
        : 1;

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
              'Appointments Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.lightText,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: performanceData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: performanceData.length,
                      itemBuilder: (context, index) {
                        final data = performanceData[index];
                        return _buildBarberBar(data, maxAppointments);
                      },
                    ),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarberBar(BarberPerformanceData data, int maxAppointments) {
    // Calculate bar height with minimum height for visibility
    final barHeight = (data.totalAppointments / maxAppointments * 150).clamp(20.0, 150.0);
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Appointments count
          Text(
            data.totalAppointments.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColor.lightText,
            ),
          ),
          const SizedBox(height: 4),
          
          // Bar chart
          Container(
            height: barHeight,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColor.lightPrimary,
                  AppColor.lightPrimary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColor.darkWithOpacity,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Rating badge on top of bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.light,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.darkWithOpacity,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    data.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColor.lightPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Barber name
          Text(
            _getShortName(data.barberName),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColor.lightText,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          
          // Earnings
          Text(
            '\$${data.totalEarnings.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 10,
              color: AppColor.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: AppColor.lightTextSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No performance data available',
            style: TextStyle(
              color: AppColor.lightTextSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Appointments', AppColor.lightPrimary),
        const SizedBox(width: 16),
        _buildLegendItem('Rating', AppColor.lightAccent),
        const SizedBox(width: 16),
        _buildLegendItem('Earnings', AppColor.lightSuccess),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColor.darkWithOpacity,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColor.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  String _getShortName(String fullName) {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0]}\n${names[1]}';
    }
    return fullName;
  }
}
