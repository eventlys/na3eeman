class Subscription {
  final String id;
  final int customerId;
  final int shopId;
  final String planName;
  final String subscriptionType;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
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
    required this.endDate,
    required this.status,
    required this.isActive,
    required this.autoRenew,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'].toString(),
      customerId: json['customer_id'] ?? json['customerId'] ?? 0,
      shopId: json['shop_id'] ?? json['shopId'] ?? 0,
      planName: json['plan_name'] ?? json['planName'],
      subscriptionType: json['subscription_type'] ?? json['subscriptionType'],
      price: (json['price'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
      status: json['status'],
      isActive: json['is_active'] ?? false,
      autoRenew: json['auto_renew'] ?? false,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'shop_id': shopId,
      'plan_name': planName,
      'subscription_type': subscriptionType,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'is_active': isActive,
      'auto_renew': autoRenew,
      'features': features,
    };
  }
}
