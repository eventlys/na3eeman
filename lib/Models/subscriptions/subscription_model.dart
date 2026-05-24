class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String duration; // 'MONTHLY', 'BIWEEKLY'
  final List<String> features;
  final bool isPopular;
  final int? maxBranches;
  final int? maxStaff;
  final bool analyticsEnabled;
  final bool premiumSupport;
  final int? trialDays;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.maxBranches,
    this.maxStaff,
    this.analyticsEnabled = false,
    this.premiumSupport = false,
    this.trialDays = 0,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedDuration {
    switch (duration) {
      case 'MONTHLY':
        return 'per month';
      case 'BIWEEKLY':
        return 'every 2 weeks';
      default:
        return 'per ${duration.toLowerCase()}';
    }
  }

  String get fullPriceDescription {
    return '$formattedPrice $formattedDuration';
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String? ?? 'MONTHLY',
      features: List<String>.from(json['features'] ?? []),
      isPopular: json['is_popular'] as bool? ?? false,
      maxBranches: json['max_branches'] as int?,
      maxStaff: json['max_staff'] as int?,
      analyticsEnabled: json['analytics_enabled'] as bool? ?? false,
      premiumSupport: json['premium_support'] as bool? ?? false,
      trialDays: json['trial_days'] as int? ?? 0,
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

  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? duration,
    List<String>? features,
    bool? isPopular,
    int? maxBranches,
    int? maxStaff,
    bool? analyticsEnabled,
    bool? premiumSupport,
    int? trialDays,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      maxBranches: maxBranches ?? this.maxBranches,
      maxStaff: maxStaff ?? this.maxStaff,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      premiumSupport: premiumSupport ?? this.premiumSupport,
      trialDays: trialDays ?? this.trialDays,
    );
  }
}

class SubscriptionTier {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxBranches;
  final int maxStaff;
  final bool includesAnalytics;
  final bool includesPremiumSupport;
  final bool includesMarketingTools;

  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.maxBranches,
    required this.maxStaff,
    this.includesAnalytics = false,
    this.includesPremiumSupport = false,
    this.includesMarketingTools = false,
  });

  double get yearlySavings => (monthlyPrice * 12) - yearlyPrice;
  double get yearlySavingsPercentage =>
      yearlySavings / (monthlyPrice * 12) * 100;

  factory SubscriptionTier.fromJson(Map<String, dynamic> json) {
    return SubscriptionTier(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthly_price'] as num).toDouble(),
      yearlyPrice: (json['yearly_price'] as num).toDouble(),
      features: List<String>.from(json['features'] ?? []),
      maxBranches: json['max_branches'] as int? ?? 1,
      maxStaff: json['max_staff'] as int? ?? 3,
      includesAnalytics: json['includes_analytics'] as bool? ?? false,
      includesPremiumSupport:
          json['includes_premium_support'] as bool? ?? false,
      includesMarketingTools:
          json['includes_marketing_tools'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'features': features,
      'max_branches': maxBranches,
      'max_staff': maxStaff,
      'includes_analytics': includesAnalytics,
      'includes_premium_support': includesPremiumSupport,
      'includes_marketing_tools': includesMarketingTools,
    };
  }
}
