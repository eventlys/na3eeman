class Salon {
  final int id;
  final String salonName;
  final String salonPhonNum;
  final String salonDescription;
  final String? slogan;
  final String location;
  final double lat;
  final double lng;
  final String openingTime;
  final String closingTime;
  final int salonSeats;
  final int salonStaff;
  final bool confirmedPhone;
  final int ownerId;
  final String? salonLogo;
  final double? avgRating;
  final List<Review>? reviews;
  final List<SalonGalleryImage>? galleryImages;

  Salon({
    required this.id,
    required this.salonName,
    required this.salonPhonNum,
    required this.salonDescription,
    this.slogan,
    required this.location,
    required this.lat,
    required this.lng,
    required this.openingTime,
    required this.closingTime,
    required this.salonSeats,
    required this.salonStaff,
    required this.confirmedPhone,
    required this.ownerId,
    this.salonLogo,
    this.avgRating,
    this.reviews,
    this.galleryImages,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] as int,
      salonName: json['salonName'] ?? json['salon_name'] ?? '',
      salonPhonNum: json['salonPhoneNum'] ?? json['salon_phone_num'] ?? '',
      salonDescription: json['salonDescription'] ?? json['salon_description'] ?? '',
      slogan: json['slogan'] ?? json['salon_slogan'],
      location: json['location'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      openingTime: json['openingTime'] ?? json['opening_time'] ?? '09:00',
      closingTime: json['closingTime'] ?? json['closing_time'] ?? '21:00',
      salonSeats: json['salonSeats'] ?? json['salon_seats'] ?? 0,
      salonStaff: json['salonStaff'] ?? json['salon_staff'] ?? 0,
      confirmedPhone: json['confirmed_phone'] as bool? ?? false,
      ownerId: json['owner_id'] ?? json['owner'] ?? 0,
      salonLogo: json['salon_logo'] as String?,
      avgRating: (json['salonRating'] ?? json['salon_rating'] as num?)?.toDouble(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : null,
      galleryImages: json['gallery_images'] != null
          ? (json['gallery_images'] as List).map((i) => SalonGalleryImage.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_name': salonName,
      'salon_phone_num': salonPhonNum,
      'salon_description': salonDescription,
      'salon_slogan': slogan,
      'location': location,
      'lat': lat,
      'lng': lng,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'salon_seats': salonSeats,
      'salon_staff': salonStaff,
      'confirmed_phone': confirmedPhone,
      'owner': ownerId,
      'salon_logo': salonLogo,
    };
  }
}

class SalonGalleryImage {
  final int id;
  final String image;
  final String? altText;

  SalonGalleryImage({required this.id, required this.image, this.altText});

  factory SalonGalleryImage.fromJson(Map<String, dynamic> json) {
    return SalonGalleryImage(
      id: json['id'] as int,
      image: json['image'] as String,
      altText: json['alt_text'] as String?,
    );
  }
}

class Review {
  final int id;
  final int customerId;
  final int salonId;
  final int? appointmentId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.customerId,
    required this.salonId,
    this.appointmentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      customerId: json['customer'] as int? ?? (json['customerId'] as int? ?? 0),
      salonId: json['salon'] as int? ?? (json['salonId'] as int? ?? 0),
      appointmentId: json['appointment'] as int?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
