import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/colors.dart';
import '../../../../Providers/features/admin_analytics_provider.dart';

class AdminFinancialReportsPage extends StatefulWidget {
  const AdminFinancialReportsPage({super.key});

  @override
  State<AdminFinancialReportsPage> createState() =>
      _AdminFinancialReportsPageState();
}

class _AdminFinancialReportsPageState extends State<AdminFinancialReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchFinancialAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminAnalyticsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = provider.financialStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financial Intelligence',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchFinancialAnalytics(),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader('Revenue Trends (30d)'),
                  const SizedBox(height: 24),
                  _buildRevenueChart(stats?['daily_revenue_30d'] ?? []),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Payment Methods'),
                  const SizedBox(height: 16),
                  _buildMethodBreakdown(
                    stats?['payment_method_distribution'] ?? [],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader('Recent Payouts'),
                  const SizedBox(height: 16),
                  _buildPayoutList(),

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

  Widget _buildRevenueChart(List<dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data.isEmpty)
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No financial data')),
      );

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['revenue'] ?? 0).toDouble());
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.05)
              : AppColors.almostBlack50,
        ),
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
              color: AppColors.success,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.success.withOpacity(0.1),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBreakdown(List<dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.white.withOpacity(0.05)
              : AppColors.almostBlack50,
        ),
      ),
      child: Column(
        children: data.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  item['method'] == 'CASH'
                      ? Icons.money_rounded
                      : Icons.credit_card_rounded,
                  color: AppColors.almostBlack200,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  item['method'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '${item['count']} Tx',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPayoutList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Mocking payouts for now as backend doesn't have a payout model yet
    final payouts = [
      {'salon': 'Golden Scissors', 'amount': '420.00', 'status': 'Pending'},
      {'salon': 'Elite Experts', 'amount': '1,250.00', 'status': 'Processed'},
    ];

    return Column(
      children: payouts.map((p) {
        final isPending = p['status'] == 'Pending';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.white.withOpacity(0.05)
                  : AppColors.almostBlack50,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['salon']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${p['amount']}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isPending ? AppColors.warning : AppColors.success)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p['status']!,
                  style: TextStyle(
                    color: isPending ? AppColors.warning : AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
