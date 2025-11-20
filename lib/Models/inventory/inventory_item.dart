class InventoryItem {
  final String id;
  final int productId;
  final int shopId;
  final int quantityInStock;
  final DateTime lastUpdated;
  final String? productName;
  final String? productDescription;
  final double? productPrice;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.shopId,
    required this.quantityInStock,
    required this.lastUpdated,
    this.productName,
    this.productDescription,
    this.productPrice,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      productId: json['product'] as int,
      shopId: json['shop'] as int,
      quantityInStock: json['quantity_in_stock'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      productName: json['product_name'] as String?,
      productDescription: json['product_description'] as String?,
      productPrice: (json['product_price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': productId,
      'shop': shopId,
      'quantity_in_stock': quantityInStock,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  InventoryItem copyWith({
    String? id,
    int? productId,
    int? shopId,
    int? quantityInStock,
    DateTime? lastUpdated,
    String? productName,
    String? productDescription,
    double? productPrice,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      shopId: shopId ?? this.shopId,
      quantityInStock: quantityInStock ?? this.quantityInStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productPrice: productPrice ?? this.productPrice,
    );
  }

  bool get isLowStock => quantityInStock < 5;
  bool get isCriticalStock => quantityInStock <= 2;
}

class Product {
  final int id;
  final String productName;
  final String productDescription;
  final double productPrice;
  final String? imageUrl;
  final int? shopId;
  final List<int>? optionIds;

  Product({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.imageUrl,
    this.shopId,
    this.optionIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      productName: json['product_name'] as String,
      productDescription: json['product_description'] as String,
      productPrice: (json['product_price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      shopId: json['shop'] as int?,
      optionIds: json['options'] != null
          ? (json['options'] as List).cast<int>()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'product_description': productDescription,
      'product_price': productPrice,
      'image_url': imageUrl,
      'shop': shopId,
      'options': optionIds,
    };
  }
}

class Option {
  final int id;
  final String optionName;
  final String optionDescription;
  final double optionPrice;
  final String optionTiming;
  final int shopId;

  Option({
    required this.id,
    required this.optionName,
    required this.optionDescription,
    required this.optionPrice,
    required this.optionTiming,
    required this.shopId,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as int,
      optionName: json['option_name'] as String,
      optionDescription: json['option_description'] as String,
      optionPrice: (json['option_price'] as num).toDouble(),
      optionTiming: json['option_timing'] as String,
      shopId: json['shop'] as int,
    );
  }
}

class Package {
  final int id;
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final int shopId;
  final List<int>? optionIds;

  Package({
    required this.id,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.shopId,
    this.optionIds,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] as int,
      packageName: json['package_name'] as String,
      packageDescription: json['package_description'] as String,
      packagePrice: (json['package_price'] as num).toDouble(),
      shopId: json['shop'] as int,
      optionIds: json['options'] != null
          ? (json['options'] as List).cast<int>()
          : null,
    );
  }
}
