class ProfitData {
  final DateTime date;
  final double revenue;
  final double profit;
  final double expenses;
  final double tips;
  final int appointments;
  final int shopId;

  ProfitData({
    required this.date,
    required this.revenue,
    required this.profit,
    required this.expenses,
    this.tips = 0.0,
    this.appointments = 0,
    required this.shopId,
  });

  factory ProfitData.fromJson(Map<String, dynamic> json) {
    return ProfitData(
      date: DateTime.parse(json['date']),
      revenue: (json['revenue'] is double ? json['revenue'] : double.tryParse(json['revenue']?.toString() ?? '0.0')) ?? 0.0,
      profit: (json['profit'] is double ? json['profit'] : double.tryParse(json['profit']?.toString() ?? '0.0')) ?? 0.0,
      expenses: (json['expenses'] is double ? json['expenses'] : double.tryParse(json['expenses']?.toString() ?? '0.0')) ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      appointments: json['appointments'] as int? ?? 0,
      shopId: json['shop'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'revenue': revenue,
      'profit': profit,
      'expenses': expenses,
      'tips': tips,
      'appointments': appointments,
      'shop': shopId,
    };
  }

  double get profitMargin => revenue > 0 ? (profit / revenue) * 100 : 0;
}

class ProfitReport {
  final List<ProfitData> monthlyData;
  final List<ProfitData> yearlyData;
  final double totalRevenue;
  final double totalProfit;
  final double totalExpenses;
  final double totalTips;
  final int totalAppointments;
  final double averageProfitMargin;
  final DateTime reportDate;

  ProfitReport({
    required this.monthlyData,
    required this.yearlyData,
    required this.totalRevenue,
    required this.totalProfit,
    required this.totalExpenses,
    required this.totalTips,
    required this.totalAppointments,
    required this.averageProfitMargin,
    required this.reportDate,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      monthlyData: List<ProfitData>.from(
        (json['monthly_data'] ?? []).map((x) => ProfitData.fromJson(x))
      ),
      yearlyData: List<ProfitData>.from(
        (json['yearly_data'] ?? []).map((x) => ProfitData.fromJson(x))
      ),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['total_profit'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0.0,
      totalTips: (json['total_tips'] as num?)?.toDouble() ?? 0.0,
      totalAppointments: json['total_appointments'] as int? ?? 0,
      averageProfitMargin: (json['average_profit_margin'] as num?)?.toDouble() ?? 0.0,
      reportDate: DateTime.parse(json['report_date'] as String? ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthly_data': monthlyData.map((x) => x.toJson()).toList(),
      'yearly_data': yearlyData.map((x) => x.toJson()).toList(),
      'total_revenue': totalRevenue,
      'total_profit': totalProfit,
      'total_expenses': totalExpenses,
      'total_tips': totalTips,
      'total_appointments': totalAppointments,
      'average_profit_margin': averageProfitMargin,
      'report_date': reportDate.toIso8601String(),
    };
  }

  double get overallProfitMargin => totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0;
}
