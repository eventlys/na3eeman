class OfferModel {
  final int id;
  final String title;
  final String description;
  final String price; // Discounted Price
  final String? originalPrice;
  final String validityPeriod; // 'Valid until Dec 20' or Date string
  final int shopId;
  final String shopName;
  final String? imageUrl;
  final List<String>? includedServices;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.validityPeriod,
    required this.shopId,
    required this.shopName,
    this.imageUrl,
    this.includedServices,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'] as int? ?? 0,
      title: map['title'] as String? ?? (map['name'] as String? ?? 'Special Offer'),
      description: map['description'] as String? ?? '',
      price: map['price'] as String? ?? '0.00',
      originalPrice: map['original_price'] as String?,
      validityPeriod: map['validity_period'] as String? ?? 'Limited Time',
      shopId: map['shop_id'] as int? ?? (map['shop'] as int? ?? 0),
      shopName: map['shop_name'] as String? ?? 'Shop',
      imageUrl: map['image_url'] as String?,
      includedServices: map['included_services'] != null 
        ? List<String>.from(map['included_services'] as List) 
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'validity_period': validityPeriod,
      'shop_id': shopId,
      'shop_name': shopName,
      'image_url': imageUrl,
      'included_services': includedServices,
    };
  }
}
