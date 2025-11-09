class ShopSubscription {
  final String id;
  final String name;
  final String description;
  final double price;
  final Duration duration;
  final List<String> features;
  final bool isPopular;

  const ShopSubscription({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedDuration {
    if (duration.inDays >= 30) {
      final months = duration.inDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''}';
    }
    return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
  }

  ShopSubscription copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    Duration? duration,
    List<String>? features,
    bool? isPopular,
  }) {
    return ShopSubscription(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}

