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
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] as int,
      salonName: json['salon_name'] as String,
      salonPhonNum: json['salon_phon_num'] as String,
      salonDescription: json['salon_description'] as String,
      slogan: json['slogan'] as String?,
      location: json['location'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      openingTime: json['opening_time'] as String,
      closingTime: json['closing_time'] as String,
      salonSeats: json['salon_seats'] as int? ?? 0,
      salonStaff: json['salon_staff'] as int? ?? 0,
      confirmedPhone: json['confirmed_phone'] as bool? ?? false,
      ownerId: json['owner'] as int? ?? 0,
      salonLogo: json['salon_logo'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_name': salonName,
      'salon_phon_num': salonPhonNum,
      'salon_description': salonDescription,
      'slogan': slogan,
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
      customerId: json['customer'] as int,
      salonId: json['salon'] as int,
      appointmentId: json['appointment'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
