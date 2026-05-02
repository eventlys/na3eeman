// helpers/profit_helper.dart
import 'package:intl/intl.dart';

class ProfitHelper {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static double calculateProfit(double revenue, double expenses) {
    return revenue - expenses;
  }

  static double calculateProfitMargin(double revenue, double profit) {
    return revenue > 0 ? (profit / revenue) * 100 : 0;
  }

  static List<Map<String, dynamic>> generateMonthlyProfitData(
    List<Map<String, dynamic>> rawData,
    DateTime startDate,
    DateTime endDate,
  ) {
    final monthlyData = <Map<String, dynamic>>[];
    var current = DateTime(startDate.year, startDate.month);
    final end = DateTime(endDate.year, endDate.month);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final monthData = rawData.where((data) {
        final dataDate = DateTime.parse(data['date']);
        return dataDate.year == current.year && dataDate.month == current.month;
      }).toList();

      final monthlyRevenue = monthData.fold(0.0, (sum, data) => sum + (data['revenue'] as num).toDouble());
      final monthlyExpenses = monthData.fold(0.0, (sum, data) => sum + (data['expenses'] as num).toDouble());
      final monthlyProfit = calculateProfit(monthlyRevenue, monthlyExpenses);

      monthlyData.add({
        'date': DateTime(current.year, current.month),
        'revenue': monthlyRevenue,
        'expenses': monthlyExpenses,
        'profit': monthlyProfit,
        'profitMargin': calculateProfitMargin(monthlyRevenue, monthlyProfit),
      });

      current = DateTime(current.year, current.month + 1);
    }

    return monthlyData;
  }

  static List<Map<String, dynamic>> generateYearlyProfitData(
    List<Map<String, dynamic>> rawData,
    DateTime startDate,
    DateTime endDate,
  ) {
    final yearlyData = <Map<String, dynamic>>[];
    var current = DateTime(startDate.year);
    final end = DateTime(endDate.year);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final yearData = rawData.where((data) {
        final dataDate = DateTime.parse(data['date']);
        return dataDate.year == current.year;
      }).toList();

      final yearlyRevenue = yearData.fold(0.0, (sum, data) => sum + (data['revenue'] as num).toDouble());
      final yearlyExpenses = yearData.fold(0.0, (sum, data) => sum + (data['expenses'] as num).toDouble());
      final yearlyProfit = calculateProfit(yearlyRevenue, yearlyExpenses);

      yearlyData.add({
        'date': DateTime(current.year),
        'revenue': yearlyRevenue,
        'expenses': yearlyExpenses,
        'profit': yearlyProfit,
        'profitMargin': calculateProfitMargin(yearlyRevenue, yearlyProfit),
      });

      current = DateTime(current.year + 1);
    }

    return yearlyData;
  }
}
