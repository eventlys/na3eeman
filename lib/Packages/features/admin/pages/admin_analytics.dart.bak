import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../Providers/features/admin_analytics_provider.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchAllAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminAnalyticsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchAllAnalytics(),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader('User Growth (30d)'),
                  const SizedBox(height: 24),
                  _buildGrowthChart(provider.userStats?['growth_30d'] ?? []),
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(child: _buildDistributionChart('User Roles', provider.userStats?['distribution_by_role'] ?? [])),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDistributionChart('Genders', provider.userStats?['distribution_by_gender'] ?? [])),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Top Performing Salons'),
                  const SizedBox(height: 16),
                  _buildTopSalonsList(provider.usageStats?['top_salons'] ?? []),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader('Appointment Status'),
                  const SizedBox(height: 16),
                  _buildStatusDistribution(provider.usageStats?['appointment_status_distribution'] ?? []),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGrowthChart(List<dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No growth data available', style: TextStyle(color: AppColors.almostBlack300))),
      );
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['count'] ?? 0).toDouble());
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 16, right: 16, left: 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart(String title, List<dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (data.isEmpty) return const SizedBox();

    final colors = [
      Theme.of(context).primaryColor,
      AppColors.pink,
      AppColors.success,
      AppColors.warning,
      AppColors.blue,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.almostBlack300)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 20,
                sections: data.asMap().entries.map((e) {
                  return PieChartSectionData(
                    color: colors[e.key % colors.length],
                    value: (e.value['count'] ?? 0).toDouble(),
                    title: '',
                    radius: 12,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...data.take(3).map((item) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${item['role'] ?? item['gender'] ?? 'Other'}: ${item['count']}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopSalonsList(List<dynamic> salons) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: salons.map((salon) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
          ),
          child: Row(
            children: [
              CircleAvatar(
                 backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                 child: Text(salon['salon_name'][0], style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(salon['salon_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${salon['app_count']} appointments', style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.almostBlack100),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusDistribution(List<dynamic> stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.almostBlack50),
      ),
      child: Column(
        children: stats.map((s) {
          final status = s['status'].toString();
          final count = s['count'] as int;
          Color color = AppColors.almostBlack100;
          if (status == 'COMPLETED') color = AppColors.success;
          if (status == 'CANCELLED') color = AppColors.error;
          if (status == 'SCHEDULED') color = AppColors.blue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

