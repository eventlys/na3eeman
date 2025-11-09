class Offer {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> applicableProducts;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.applicableProducts,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: (json['discountPercentage'] is double ? json['discountPercentage'] : double.tryParse(json['discountPercentage']?.toString() ?? '0.0')) ?? 0.0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
      applicableProducts: List<String>.from(json['applicableProducts'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'applicableProducts': applicableProducts,
    };
  }

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isExpired => DateTime.now().isAfter(endDate);
}

