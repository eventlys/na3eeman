class ExpertProfile {
  final int id;
  final int expertId;
  final String? bio;
  final String? specialties;
  final String? contactPhone;
  final bool hasAccess;
  final double avgRating;
  final int? yearsExperience;
  final String? certification;

  const ExpertProfile({
    required this.id,
    required this.expertId,
    this.bio,
    this.specialties,
    this.contactPhone,
    this.hasAccess = false,
    this.avgRating = 0.0,
    this.yearsExperience,
    this.certification,
  });

  List<String> get specialtiesList =>
      specialties
          ?.split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList() ??
      [];

  factory ExpertProfile.fromJson(Map<String, dynamic> json) {
    return ExpertProfile(
      id: (json['id'] as int?) ?? 0,
      expertId:
          (json['expert'] ?? json['id'] as int?) ??
          0, // Changed from User object to ID
      bio: json['bio'] as String?,
      specialties: json['specialties'] is List
          ? (json['specialties'] as List).join(', ')
          : json['specialties'] as String?,
      contactPhone: json['contact_phone'] as String?,
      hasAccess: json['has_access'] as bool? ?? false,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      yearsExperience: json['years_experience'] as int?,
      certification: json['certification'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expert': expertId,
      'bio': bio,
      'specialties': specialties,
      'contact_phone': contactPhone,
      'has_access': hasAccess,
      'avg_rating': avgRating,
      'years_experience': yearsExperience,
      'certification': certification,
    };
  }

  ExpertProfile copyWith({
    int? id,
    int? expertId,
    String? bio,
    String? specialties,
    String? contactPhone,
    bool? hasAccess,
    double? avgRating,
    int? yearsExperience,
    String? certification,
  }) {
    return ExpertProfile(
      id: id ?? this.id,
      expertId: expertId ?? this.expertId,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      contactPhone: contactPhone ?? this.contactPhone,
      hasAccess: hasAccess ?? this.hasAccess,
      avgRating: avgRating ?? this.avgRating,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      certification: certification ?? this.certification,
    );
  }
}
