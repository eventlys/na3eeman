class EarningsData {
  final DateTime date;
  final double amount;
  final int appointments;

  EarningsData({
    required this.date,
    required this.amount,
    required this.appointments,
  });

  factory EarningsData.fromJson(Map<String, dynamic> json) {
    return EarningsData(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0).toDouble(),
      appointments: json['appointments'] ?? 0,
    );
  }
}
