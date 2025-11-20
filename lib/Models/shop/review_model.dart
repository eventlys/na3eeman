class Review {
  final int id;
  final int customerId;
  final String customerName;
  final String? customerProfilePic;
  final int shopId;
  final String shopName;
  final int? appointmentId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool? isVerified;
  final List<String>? photos;

  Review({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerProfilePic,
    required this.shopId,
    required this.shopName,
    this.appointmentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isVerified,
    this.photos,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      customerId: json['customer'] as int,
      customerName: json['customer_name'] as String? ?? '',
      customerProfilePic: json['customer_profile_pic'] as String?,
      shopId: json['shop'] as int,
      shopName: json['shop_name'] as String? ?? '',
      appointmentId: json['appointment'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customerId,
      'customer_name': customerName,
      'customer_profile_pic': customerProfilePic,
      'shop': shopId,
      'shop_name': shopName,
      'appointment': appointmentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_verified': isVerified,
      'photos': photos,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  List<String> get starRating {
    List<String> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(i <= rating ? '★' : '☆');
    }
    return stars;
  }

  bool get hasPhotos => photos != null && photos!.isNotEmpty;

  Review copyWith({
    int? id,
    int? customerId,
    String? customerName,
    String? customerProfilePic,
    int? shopId,
    String? shopName,
    int? appointmentId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    List<String>? photos,
  }) {
    return Review(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerProfilePic: customerProfilePic ?? this.customerProfilePic,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      appointmentId: appointmentId ?? this.appointmentId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      photos: photos ?? this.photos,
    );
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // key: rating (1-5), value: count
  final int fiveStar;
  final int fourStar;
  final int threeStar;
  final int twoStar;
  final int oneStar;

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.fiveStar,
    required this.fourStar,
    required this.threeStar,
    required this.twoStar,
    required this.oneStar,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final distribution = Map<int, int>.from(json['rating_distribution'] ?? {});
    return ReviewStats(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      ratingDistribution: distribution,
      fiveStar: distribution[5] ?? 0,
      fourStar: distribution[4] ?? 0,
      threeStar: distribution[3] ?? 0,
      twoStar: distribution[2] ?? 0,
      oneStar: distribution[1] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': ratingDistribution,
      'five_star': fiveStar,
      'four_star': fourStar,
      'three_star': threeStar,
      'two_star': twoStar,
      'one_star': oneStar,
    };
  }

  double getPercentage(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }
}
