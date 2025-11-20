class ShopService {
  final String name;
  final String price;
  final String duration;
  final String type; // 'OPTION', 'PACKAGE', 'PRODUCT'
  final int? id;
  final String? description;
  final int? shopId;

  const ShopService({
    required this.name,
    required this.price,
    required this.duration,
    required this.type,
    this.id,
    this.description,
    this.shopId,
  });

  factory ShopService.fromMap(Map<String, dynamic> map) {
    return ShopService(
      name: map['name'] as String,
      price: map['price'] as String,
      duration: map['duration'] as String,
      type: map['type'] as String? ?? 'OPTION',
      id: map['id'] as int?,
      description: map['description'] as String?,
      shopId: map['shop'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'type': type,
      'id': id,
      'description': description,
      'shop': shopId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopService &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ type.hashCode;
}
