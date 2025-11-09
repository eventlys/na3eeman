import 'package:flutter/material.dart';

class EarningsChart extends StatelessWidget {
  final dynamic earningsData;

  const EarningsChart({super.key, required this.earningsData});

  @override
  Widget build(BuildContext context) {
    // Handle List data (which is what your API returns)
    if (earningsData is List) {
      final List<dynamic> earningsList = earningsData as List;
      return _buildWeeklyChart(earningsList);
    } else {
      return _buildEmptyChart();
    }
  }

  Widget _buildWeeklyChart(List<dynamic> earningsList) {
    if (earningsList.isEmpty) {
      return _buildEmptyChart();
    }

    // Process the data
    final List<Map<String, dynamic>> chartData = [];
    double maxAmount = 0;

    for (var item in earningsList) {
      if (item is Map<String, dynamic>) {
        final amount = (item['amount'] ?? 0).toDouble();
        chartData.add(item);
        if (amount > maxAmount) maxAmount = amount;
      }
    }

    if (chartData.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Weekly Earnings Trend",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((day) {
                final amount = (day['amount'] ?? 0).toDouble();
                final date = DateTime.parse(day['date'] ?? DateTime.now().toIso8601String());

                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        '\$${amount.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          height: maxAmount > 0 ? (amount / maxAmount) * 150 : 0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDayAbbreviation(date),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildStats(chartData),
        ],
      ),
    );
  }

  Widget _buildStats(List<Map<String, dynamic>> chartData) {
    final totalEarnings = chartData.map((e) => (e['amount'] ?? 0).toDouble()).reduce((a, b) => a + b);
    final totalAppointments = chartData.map((e) => (e['appointments'] ?? 0) as int).reduce((a, b) => a + b);
    final averagePerAppointment = totalAppointments > 0 ? totalEarnings / totalAppointments : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: 'Total',
          value: '\$${totalEarnings.toStringAsFixed(0)}',
          color: Colors.green,
        ),
        _StatItem(
          label: 'Appointments',
          value: totalAppointments.toString(),
          color: Colors.blue,
        ),
        _StatItem(
          label: 'Average',
          value: '\$${averagePerAppointment.toStringAsFixed(0)}',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'No earnings data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  String _getDayAbbreviation(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

