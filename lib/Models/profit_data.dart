class ProfitData {
  final DateTime date;
  final double revenue;
  final double profit;
  final double expenses;

  ProfitData({
    required this.date,
    required this.revenue,
    required this.profit,
    required this.expenses,
  });

  factory ProfitData.fromJson(Map<String, dynamic> json) {
    return ProfitData(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] is double ? json['revenue'] : double.tryParse(json['revenue']?.toString() ?? '0.0')) ?? 0.0,
      profit: (json['profit'] is double ? json['profit'] : double.tryParse(json['profit']?.toString() ?? '0.0')) ?? 0.0,
      expenses: (json['expenses'] is double ? json['expenses'] : double.tryParse(json['expenses']?.toString() ?? '0.0')) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'revenue': revenue,
      'profit': profit,
      'expenses': expenses,
    };
  }
}

class ProfitReport {
  final List<ProfitData> monthlyData;
  final List<ProfitData> yearlyData;
  final double totalRevenue;
  final double totalProfit;
  final double totalExpenses;

  ProfitReport({
    required this.monthlyData,
    required this.yearlyData,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalExpenses,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      monthlyData: List<ProfitData>.from(
        (json['monthlyData'] ?? []).map((x) => ProfitData.fromJson(x))
      ),
      yearlyData: List<ProfitData>.from(
        (json['yearlyData'] ?? []).map((x) => ProfitData.fromJson(x))
      ),
      totalRevenue: (json['totalRevenue'] is double ? json['totalRevenue'] : double.tryParse(json['totalRevenue']?.toString() ?? '0.0')) ?? 0.0,
      totalProfit: (json['totalProfit'] is double ? json['totalProfit'] : double.tryParse(json['totalProfit']?.toString() ?? '0.0')) ?? 0.0,
      totalExpenses: (json['totalExpenses'] is double ? json['totalExpenses'] : double.tryParse(json['totalExpenses']?.toString() ?? '0.0')) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyData': monthlyData.map((x) => x.toJson()).toList(),
      'yearlyData': yearlyData.map((x) => x.toJson()).toList(),
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'totalExpenses': totalExpenses,
    };
  }
}

