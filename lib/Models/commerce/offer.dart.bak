class Offer {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> applicableServices; // Service types or specific service IDs
  final int? salonId;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.applicableServices,
    this.salonId,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String? ?? DateTime.now().toString()),
      endDate: DateTime.parse(json['end_date'] as String? ?? DateTime.now().toString()),
      isActive: json['is_active'] ?? true,
      applicableServices: List<String>.from(json['applicable_services'] ?? []),
      salonId: json['salon'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discount_percentage': discountPercentage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'applicable_services': applicableServices,
      'salon': salonId,
    };
  }

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
}