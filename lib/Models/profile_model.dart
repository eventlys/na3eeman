class UserProfile {
  final String? role;
  final String? gender;
  final String? email;
  final String? username;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? profilePic;
  final String? location;
  final double? lat;
  final double? lng;
  final bool? vrfidEmail;
  final bool? vrfidPhone;
  final bool? isDeleted;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bio;
  final List<String>? specialties;
  final String? contactPhone;
  final bool? hasAccess;
  final bool? isOwner;
  final bool? isWorker;
  final bool? isSubscribed;
  final bool? hasBranches;
  final bool? hasOffers;

  UserProfile({
    this.role,
    this.gender,
    this.email,
    this.username,
    this.phone,
    this.firstName,
    this.lastName,
    this.profilePic,
    this.location,
    this.lat,
    this.lng,
    this.vrfidEmail,
    this.vrfidPhone,
    this.isDeleted,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.bio,
    this.specialties,
    this.contactPhone,
    this.hasAccess,
    this.isOwner,
    this.isWorker,
    this.isSubscribed,
    this.hasBranches,
    this.hasOffers,
  });

  UserProfile copyWith({
    String? role,
    String? gender,
    String? email,
    String? username,
    String? phone,
    String? firstName,
    String? lastName,
    String? profilePic,
    String? location,
    double? lat,
    double? lng,
    bool? vrfidEmail,
    bool? vrfidPhone,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
    List<String>? specialties,
    String? contactPhone,
    bool? hasAccess,
    bool? isOwner,
    bool? isWorker,
    bool? isSubscribed,
    bool? hasBranches,
    bool? hasOffers,
  }) {
    return UserProfile(
      role: role ?? this.role,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePic: profilePic ?? this.profilePic,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      vrfidEmail: vrfidEmail ?? this.vrfidEmail,
      vrfidPhone: vrfidPhone ?? this.vrfidPhone,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      contactPhone: contactPhone ?? this.contactPhone,
      hasAccess: hasAccess ?? this.hasAccess,
      isOwner: isOwner ?? this.isOwner,
      isWorker: isWorker ?? this.isWorker,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      hasBranches: hasBranches ?? this.hasBranches,
      hasOffers: hasOffers ?? this.hasOffers,
    );
  }
}

