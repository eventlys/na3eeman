import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../Core/utils/formatters.dart';


class ProfitGraph extends StatefulWidget {
  final ProfitReport profitReport;

  const ProfitGraph({super.key, required this.profitReport});

  @override
  ProfitGraphState createState() => ProfitGraphState();
}

class ProfitGraphState extends State<ProfitGraph> {
  bool _isMonthly = true;
  late List<ProfitData> _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.profitReport.monthlyData;
  }

  void _togglePeriod() {
    setState(() {
      _isMonthly = !_isMonthly;
      _currentData = _isMonthly
          ? widget.profitReport.monthlyData
          : widget.profitReport.yearlyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.cardColor,
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
                    color: AppColors.textColor,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _togglePeriod,
                      child: Text(
                        _isMonthly ? 'Monthly' : 'Yearly',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _showDownloadDialog(context, value),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'pdf', child: Text('Download PDF')),
                        PopupMenuItem(value: 'csv', child: Text('Download CSV')),
                      ],
                      icon: Icon(Icons.download, color: AppColors.primaryColor),
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
                      spots: _currentData.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          e.value.profit,
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primaryColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
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
                _buildStatItem('Total Revenue', widget.profitReport.totalRevenue),
                _buildStatItem('Total Profit', widget.profitReport.totalProfit),
                _buildStatItem('Total Expenses', widget.profitReport.totalExpenses),
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
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  void _showDownloadDialog(BuildContext context, String format) {
    TextEditingController fileNameController = TextEditingController(
      text: 'profit_report_${DateTime.now().millisecondsSinceEpoch}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose file name:'),
            SizedBox(height: 12),
            TextField(
              controller: fileNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'File Name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement download logic
              Navigator.pop(context);
              _showDownloadSuccess(context);
            },
            child: Text('Download $format'.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _showDownloadSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report downloaded successfully!'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }
}

