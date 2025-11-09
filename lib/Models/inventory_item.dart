class InventoryItem {
  final String id;
  final String name;
  final int count;
  final String? description;
  final DateTime? lastUpdated;
  final String? category; // Make optional
  final int? minStockLevel; // Make optional
  final double? price; // Make optional
  final String? imageUrl; // Make optional

  InventoryItem({
    required this.id,
    required this.name,
    required this.count,
    this.description,
    this.lastUpdated,
    this.category, // Optional
    this.minStockLevel, // Optional
    this.price, // Optional
    this.imageUrl, // Optional
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated']?.toString() ?? '')
          : null,
      category: json['category']?.toString(), // Optional
      minStockLevel: json['minStockLevel'] is int ? json['minStockLevel'] : int.tryParse(json['minStockLevel']?.toString() ?? '5'), // Optional
      price: json['price'] != null
          ? (json['price'] is double ? json['price'] : double.tryParse(json['price']?.toString() ?? '0.0'))
          : null, // Optional
      imageUrl: json['imageUrl']?.toString(), // Optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'description': description,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'category': category,
      'minStockLevel': minStockLevel,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    int? count,
    String? description,
    DateTime? lastUpdated,
    String? category,
    int? minStockLevel,
    double? price,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      description: description ?? this.description,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isLowStock => count < 3;
  bool get isCriticalStock => count <= ((minStockLevel ?? 5) * 0.3).ceil();
  int get currentStock => count;
}

