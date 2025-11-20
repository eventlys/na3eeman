class Subscription {
  final String id;
  final int customerId;
  final int shopId;
  final String planName;
  final String subscriptionType; // 'MONTHLY', 'BIWEEKLY'
  final double price;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final bool isActive;
  final bool autoRenew;
  final List<String> features;

  Subscription({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.planName,
    required this.subscriptionType,
    required this.price,
    required this.startDate,
    this.endDate,
    required this.status,
    this.isActive = true,
    this.autoRenew = true,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id']?.toString() ?? '',
      customerId: json['customer'] as int,
      shopId: json['shop'] as int,
      planName: json['plan_name'] ?? 'Premium Plan',
      subscriptionType: json['subscription_type'] as String? ?? 'MONTHLY',
      price: (json['price'] is double ? json['price'] : double.tryParse(json['price']?.toString() ?? '0.0')) ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: json['status'] ?? 'Active',
      isActive: json['is_active'] as bool? ?? true,
      autoRenew: json['auto_renew'] as bool? ?? true,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customerId,
      'shop': shopId,
      'plan_name': planName,
      'subscription_type': subscriptionType,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'is_active': isActive,
      'auto_renew': autoRenew,
      'features': features,
    };
  }

  int get daysRemaining => endDate?.difference(DateTime.now()).inDays ?? 0;
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
}

class ShopSubscription {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration; // 'MONTHLY', 'BIWEEKLY'
  final List<String> features;
  final bool isPopular;
  final int? shopId;

  const ShopSubscription({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.shopId,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedDuration {
    switch (duration) {
      case 'MONTHLY':
        return '1 month';
      case 'BIWEEKLY':
        return '2 weeks';
      default:
        return duration.toLowerCase();
    }
  }

  factory ShopSubscription.fromJson(Map<String, dynamic> json) {
    return ShopSubscription(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String? ?? 'MONTHLY',
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['is_popular'] as bool? ?? false,
      shopId: json['shop'] as int?,
    );
  }

  ShopSubscription copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? duration,
    List<String>? features,
    bool? isPopular,
    int? shopId,
  }) {
    return ShopSubscription(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      shopId: shopId ?? this.shopId,
    );
  }
}
