class ExpertPerformance {
  final String staffId;
  final DateTime date;
  final int appointmentsCompleted;
  final double totalRevenue;
  final double tips;
  final double rating;
  final Map<String, int> servicesBreakdown;
  final int salonId;

  ExpertPerformance({
    required this.staffId,
    required this.date,
    required this.appointmentsCompleted,
    required this.totalRevenue,
    required this.tips,
    required this.rating,
    required this.servicesBreakdown,
    required this.salonId,
  });

  double get earnings => totalRevenue + tips;
  double get averageEarningPerAppointment => appointmentsCompleted > 0 ? earnings / appointmentsCompleted : 0;

  factory ExpertPerformance.fromJson(Map<String, dynamic> json) {
    return ExpertPerformance(
      staffId: json['staff_id'] ?? json['staffId'] ?? '',
      date: DateTime.parse(json['date']),
      appointmentsCompleted: json['appointments_completed'] ?? json['appointmentsCompleted'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? json['totalRevenue'] ?? 0).toDouble(),
      tips: (json['tips'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      servicesBreakdown: Map<String, int>.from(json['services_breakdown'] ?? json['servicesBreakdown'] ?? {}),
      salonId: json['salon'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'date': date.toIso8601String(),
      'appointments_completed': appointmentsCompleted,
      'total_revenue': totalRevenue,
      'tips': tips,
      'rating': rating,
      'services_breakdown': servicesBreakdown,
      'salon': salonId,
    };
  }
}

class StaffAttendance {
  final String staffId;
  final DateTime date;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final String status; // 'PRESENT', 'ABSENT', 'LATE', 'LEAVE'
  final String? notes;
  final int salonId;

  StaffAttendance({
    required this.staffId,
    required this.date,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.clockIn,
    this.clockOut,
    required this.status,
    this.notes,
    required this.salonId,
  });

  Duration get scheduledHours => scheduledEnd.difference(scheduledStart);
  Duration get workedHours {
    if (clockIn != null && clockOut != null) {
      return clockOut!.difference(clockIn!);
    }
    return Duration.zero;
  }

  bool get isLate {
    if (clockIn == null) return false;
    return clockIn!.isAfter(scheduledStart.add(Duration(minutes: 15)));
  }

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      staffId: json['staff_id'] as String,
      date: DateTime.parse(json['date']),
      scheduledStart: DateTime.parse(json['scheduled_start']),
      scheduledEnd: DateTime.parse(json['scheduled_end']),
      clockIn: json['clock_in'] != null ? DateTime.parse(json['clock_in']) : null,
      clockOut: json['clock_out'] != null ? DateTime.parse(json['clock_out']) : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      salonId: json['salon'] as int,
    );
  }
}

class StaffPayroll {
  final String staffId;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final double baseSalary;
  final double commission;
  final double tips;
  final double deductions;
  final double netPay;
  final String status; // 'PENDING', 'PAID', 'PROCESSING'
  final int salonId;

  StaffPayroll({
    required this.staffId,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.baseSalary,
    required this.commission,
    required this.tips,
    required this.deductions,
    required this.netPay,
    required this.status,
    required this.salonId,
  });

  double get grossPay => baseSalary + commission + tips;

  factory StaffPayroll.fromJson(Map<String, dynamic> json) {
    return StaffPayroll(
      staffId: json['staff_id'] as String,
      payPeriodStart: DateTime.parse(json['pay_period_start']),
      payPeriodEnd: DateTime.parse(json['pay_period_end']),
      baseSalary: (json['base_salary'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      tips: (json['tips'] as num).toDouble(),
      deductions: (json['deductions'] as num).toDouble(),
      netPay: (json['net_pay'] as num).toDouble(),
      status: json['status'] as String,
      salonId: json['salon'] as int,
    );
  }
}
