class EarningsData {
  final DateTime date;
  final double amount;
  final int appointments;
  final double tips;
  final int salonId;
  final int? barberId;

  EarningsData({
    required this.date,
    required this.amount,
    required this.appointments,
    this.tips = 0.0,
    required this.salonId,
    this.barberId,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0).toDouble(),
      appointments: json['appointments'] ?? 0,
      tips: (json['tips'] ?? 0).toDouble(),
      salonId: json['salon'] as int,
      barberId: json['barber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'appointments': appointments,
      'tips': tips,
      'salon': salonId,
      'barber': barberId,
    };
  }
}

class EarningsReport {
  final List<EarningsData> dailyEarnings;
  final List<EarningsData> weeklyEarnings;
  final List<EarningsData> monthlyEarnings;
  final double totalRevenue;
  final double totalTips;
  final int totalAppointments;
  final double averageEarningPerAppointment;
  final DateTime startDate;
  final DateTime endDate;

  EarningsReport({
    required this.dailyEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalRevenue,
    required this.totalTips,
    required this.totalAppointments,
    required this.averageEarningPerAppointment,
    required this.startDate,
    required this.endDate,
  });

  factory EarningsReport.fromJson(Map<String, dynamic> json) {
    return EarningsReport(
      dailyEarnings: List<EarningsData>.from(
        (json['daily_earnings'] ?? []).map((x) => EarningsData.fromJson(x))
      ),
      weeklyEarnings: List<EarningsData>.from(
        (json['weekly_earnings'] ?? []).map((x) => EarningsData.fromJson(x))
      ),
      monthlyEarnings: List<EarningsData>.from(
        (json['monthly_earnings'] ?? []).map((x) => EarningsData.fromJson(x))
      ),
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalTips: (json['total_tips'] as num?)?.toDouble() ?? 0.0,
      totalAppointments: json['total_appointments'] as int? ?? 0,
      averageEarningPerAppointment: (json['average_earning_per_appointment'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_earnings': dailyEarnings.map((x) => x.toJson()).toList(),
      'weekly_earnings': weeklyEarnings.map((x) => x.toJson()).toList(),
      'monthly_earnings': monthlyEarnings.map((x) => x.toJson()).toList(),
      'total_revenue': totalRevenue,
      'total_tips': totalTips,
      'total_appointments': totalAppointments,
      'average_earning_per_appointment': averageEarningPerAppointment,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
