class ShopService {
  final String name;
  final String price;
  final String duration;

  const ShopService({
    required this.name,
    required this.price,
    required this.duration,
  });

  factory ShopService.fromMap(Map<String, dynamic> map) {
    return ShopService(
      name: map['name'] as String,
      price: map['price'] as String,
      duration: map['duration'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopService &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

