class CartItem {
  final String id;
  final String name;
  final double price;
  final String type;
  final String itemId;
  final String duration;
  final String description;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.itemId,
    required this.duration,
    required this.description,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      type: json['type'],
      itemId: json['item_id'],
      duration: json['duration'],
      description: json['description'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'type': type,
      'item_id': itemId,
      'duration': duration,
      'description': description,
      'quantity': quantity,
    };
  }

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? type,
    String? itemId,
    String? duration,
    String? description,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
    );
  }
}
