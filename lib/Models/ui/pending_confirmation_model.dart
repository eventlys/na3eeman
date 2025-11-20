class PendingConfirmation {
  final int id;
  final String customerName;
  final String service;
  final double amount;
  final DateTime appointmentTime;
  final String? notes;

  PendingConfirmation({
    required this.id,
    required this.customerName,
    required this.service,
    required this.amount,
    required this.appointmentTime,
    this.notes,
  });

  factory PendingConfirmation.fromJson(Map<String, dynamic> json) {
    return PendingConfirmation(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      service: json['service'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      appointmentTime: DateTime.parse(json['appointment_time']),
      notes: json['notes'],
    );
  }
}

