class OfferModel {
  final int id;
  final String title;
  final String description;
  final String price; // Discounted Price
  final String? originalPrice;
  final String validityPeriod; // 'Valid until Dec 20' or Date string
  final int salonId;
  final String salonName;
  final String? imageUrl;
  final List<String>? includedServices;
  final bool isActive;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.validityPeriod,
    required this.salonId,
    required this.salonName,
    this.imageUrl,
    this.includedServices,
    this.isActive = true,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'] as int? ?? 0,
      title:
          map['title'] as String? ??
          (map['name'] as String? ?? 'Special Offer'),
      description: map['description'] as String? ?? '',
      price: map['price'] as String? ?? '0.00',
      originalPrice: map['original_price'] as String?,
      validityPeriod: map['validity_period'] as String? ?? 'Limited Time',
      salonId: map['salon_id'] as int? ?? (map['salon'] as int? ?? 0),
      salonName: map['salon_name'] as String? ?? 'Salon',
      imageUrl: map['image_url'] as String?,
      includedServices: map['included_services'] != null
          ? List<String>.from(map['included_services'] as List)
          : null,
      isActive: map['is_active'] as bool? ?? true,
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
      'salon_id': salonId,
      'salon_name': salonName,
      'image_url': imageUrl,
      'included_services': includedServices,
      'is_active': isActive,
    };
  }

  OfferModel copyWith({
    int? id,
    String? title,
    String? description,
    String? price,
    String? originalPrice,
    String? validityPeriod,
    int? salonId,
    String? salonName,
    String? imageUrl,
    List<String>? includedServices,
    bool? isActive,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      validityPeriod: validityPeriod ?? this.validityPeriod,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      imageUrl: imageUrl ?? this.imageUrl,
      includedServices: includedServices ?? this.includedServices,
      isActive: isActive ?? this.isActive,
    );
  }
}
