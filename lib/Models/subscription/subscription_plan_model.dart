class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration;
  final List<String> features;
  final bool isPopular;
  final int maxBranches;
  final int maxStaff;
  final bool analyticsEnabled;
  final bool premiumSupport;
  final int trialDays;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    required this.maxBranches,
    required this.maxStaff,
    this.analyticsEnabled = false,
    this.premiumSupport = false,
    this.trialDays = 0,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['is_popular'] ?? false,
      maxBranches: json['max_branches'] ?? 1,
      maxStaff: json['max_staff'] ?? 3,
      analyticsEnabled: json['analytics_enabled'] ?? false,
      premiumSupport: json['premium_support'] ?? false,
      trialDays: json['trial_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'features': features,
      'is_popular': isPopular,
      'max_branches': maxBranches,
      'max_staff': maxStaff,
      'analytics_enabled': analyticsEnabled,
      'premium_support': premiumSupport,
      'trial_days': trialDays,
    };
  }
}
