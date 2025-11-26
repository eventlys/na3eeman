// widgets/profit_graph.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/utils/formatters.dart';

class ProfitGraph extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;

  const ProfitGraph({
    super.key,
    required this.startDate,
    required this.endDate,
    this.branchId,
  });

  @override
  ProfitGraphState createState() => ProfitGraphState();
}

class ProfitGraphState extends State<ProfitGraph> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final profitProvider = Provider.of<ProfitProvider>(context, listen: false);
    // You'll need to get authToken from your AuthProvider
    final authToken = ''; // Get from AuthProvider
    
    profitProvider.loadProfitData(
      startDate: widget.startDate,
      endDate: widget.endDate,
      branchId: widget.branchId,
      authToken: authToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfitProvider>(
      builder: (context, profitProvider, child) {
        if (profitProvider.isLoading && profitProvider.currentData.isEmpty) {
          return _buildLoadingState();
        }

        if (profitProvider.error != null) {
          return _buildErrorState(profitProvider.error!);
        }

        return _buildProfitGraph(profitProvider);
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 4,
      color: AppColor.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColor.lightPrimary),
            SizedBox(height: 16),
            Text(
              'Loading profit data...',
              style: TextStyle(
                color: AppColor.lightText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Card(
      elevation: 4,
      color: AppColor.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColor.lightError, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load profit data',
              style: TextStyle(
                color: AppColor.lightText,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: AppColor.lightTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
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

  Widget _buildProfitGraph(ProfitProvider profitProvider) {
    final currentData = profitProvider.currentData;

    return Card(
      elevation: 4,
      color: AppColor.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profit Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.lightText,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => profitProvider.toggleView(),
                      child: Text(
                        profitProvider.isMonthlyView ? 'Monthly' : 'Yearly',
                        style: TextStyle(
                          color: AppColor.lightPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _showDownloadDialog(context, value, profitProvider),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'pdf', 
                          child: Text(
                            'Download PDF',
                            style: TextStyle(color: AppColor.lightText),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'csv', 
                          child: Text(
                            'Download CSV',
                            style: TextStyle(color: AppColor.lightText),
                          ),
                        ),
                      ],
                      icon: Image.asset(
                        AppImages.download,
                        width: 24,
                        height: 24,
                        color: AppColor.lightPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: currentData.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          (e.value['profit'] as num).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColor.lightPrimary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColor.lightPrimary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Revenue', profitProvider.totalRevenue),
                _buildStatItem('Total Profit', profitProvider.totalProfit),
                _buildStatItem('Total Expenses', profitProvider.totalExpenses),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value) {
    return Column(
      children: [
        Text(
          Formatters.formatCurrency(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.lightPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColor.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  void _showDownloadDialog(BuildContext context, String format, ProfitProvider profitProvider) {
    TextEditingController fileNameController = TextEditingController(
      text: 'profit_report_${DateTime.now().millisecondsSinceEpoch}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Download Report',
          style: TextStyle(color: AppColor.lightText),
        ),
        backgroundColor: AppColor.lightCard,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose file name:',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
            SizedBox(height: 12),
            TextField(
              controller: fileNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.borderLight),
                ),
                labelText: 'File Name',
                labelStyle: TextStyle(color: AppColor.lightTextHint),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.lightPrimary),
                ),
              ),
              style: TextStyle(color: AppColor.lightText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await profitProvider.downloadReport(
                  format: format,
                  fileName: fileNameController.text,
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                  branchId: widget.branchId,
                  authToken: '', // Get from AuthProvider
                );
                _showDownloadSuccess(context);
              } catch (e) {
                _showDownloadError(context, e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lightPrimary,
            ),
            child: Text(
              'Download $format'.toUpperCase(),
              style: TextStyle(color: AppColor.light),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset(
              AppImages.check,
              width: 20,
              height: 20,
              color: AppColor.light,
            ),
            SizedBox(width: 8),
            Text('Report downloaded successfully!'),
          ],
        ),
        backgroundColor: AppColor.lightSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDownloadError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColor.light),
            SizedBox(width: 8),
            Text('Download failed: $error'),
          ],
        ),
        backgroundColor: AppColor.lightError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
