class CartItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String type; // 'OPTION', 'PACKAGE', 'PRODUCT'
  final int? itemId; // ID of the option, package, or product
  int quantity;
  final String? duration; // For services
  final String? description;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.type,
    this.itemId,
    this.quantity = 1,
    this.duration,
    this.description,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toAppointmentService() {
    return {
      'service_type': type,
      'option': type == 'OPTION' ? itemId : null,
      'package': type == 'PACKAGE' ? itemId : null,
      'product': type == 'PRODUCT' ? itemId : null,
      'quantity': quantity,
    };
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final String description;
  final int? shopId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.description,
    this.shopId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['product_name'] as String,
      price: (json['product_price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      description: json['product_description'] as String,
      shopId: json['shop'] as int?,
    );
  }
}
