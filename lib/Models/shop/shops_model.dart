class Shop {
  final int id;
  final String shopName;
  final String shopPhonNum;
  final String shopDescription;
  final String location;
  final double lat;
  final double lng;
  final String openingTime;
  final String closingTime;
  final int shopSeats;
  final int shopStaff;
  final bool confirmedPhone;
  final int ownerId;
  final String? shopLogo;
  final double? avgRating;
  final List<Review>? reviews;

  Shop({
    required this.id,
    required this.shopName,
    required this.shopPhonNum,
    required this.shopDescription,
    required this.location,
    required this.lat,
    required this.lng,
    required this.openingTime,
    required this.closingTime,
    required this.shopSeats,
    required this.shopStaff,
    required this.confirmedPhone,
    required this.ownerId,
    this.shopLogo,
    this.avgRating,
    this.reviews,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as int,
      shopName: json['shop_name'] as String,
      shopPhonNum: json['shop_phon_num'] as String,
      shopDescription: json['shop_description'] as String,
      location: json['location'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      openingTime: json['opening_time'] as String,
      closingTime: json['closing_time'] as String,
      shopSeats: json['shop_seats'] as int? ?? 0,
      shopStaff: json['shop_staff'] as int? ?? 0,
      confirmedPhone: json['confirmed_phone'] as bool? ?? false,
      ownerId: json['owner'] as int? ?? 0,
      shopLogo: json['shop_logo'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'shop_phon_num': shopPhonNum,
      'shop_description': shopDescription,
      'location': location,
      'lat': lat,
      'lng': lng,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'shop_seats': shopSeats,
      'shop_staff': shopStaff,
      'confirmed_phone': confirmedPhone,
      'owner': ownerId,
      'shop_logo': shopLogo,
    };
  }
}

class Review {
  final int id;
  final int customerId;
  final int shopId;
  final int? appointmentId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.customerId,
    required this.shopId,
    this.appointmentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      customerId: json['customer'] as int,
      shopId: json['shop'] as int,
      appointmentId: json['appointment'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
