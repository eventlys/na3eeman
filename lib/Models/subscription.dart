class Subscription {
  final String planName;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<String> features;

  Subscription({
    required this.planName,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      planName: json['planName'] ?? '',
      price: (json['price'] is double ? json['price'] : double.tryParse(json['price']?.toString() ?? '0.0')) ?? 0.0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'Active',
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'features': features,
    };
  }

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

