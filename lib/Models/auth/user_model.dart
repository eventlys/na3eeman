import 'package:na3eeman/Packages/Core/constants/app_roles.dart';
import 'package:na3eeman/Services/enums/gender.dart';

class User {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final UserRole role;
  final Gender gender;
  final String? profilePic;
  final String? phone;
  final String? location;
  final int? salonId;
  final SubscriptionTier? subscriptionTier;
  final String? specialization;
  final bool isOnline;
  final double? lat;
  final double? lng;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isDeleted;
  final DateTime? deletedAt;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.gender,
    this.profilePic,
    this.phone,
    this.location,
    this.salonId,
    this.subscriptionTier,
    this.specialization,
    this.isOnline = false,
    this.lat,
    this.lng,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isDeleted = false,
    this.deletedAt,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  String get fullName => '$firstName $lastName';

  bool get isCustomer => role == UserRole.customer;
  bool get isExpert => role == UserRole.expert;
  bool get isReceptionist => role == UserRole.receptionist;
  bool get isIntern => role == UserRole.intern;
  bool get isOwner => [UserRole.owner, UserRole.manager, UserRole.ownerExpert, UserRole.cofounder].contains(role);
  bool get isManager => role == UserRole.manager;
  bool get isOwnerExpert => role == UserRole.ownerExpert;
  bool get isAdmin => role == UserRole.admin;
  bool get isStaffMember => role != UserRole.customer;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.split('@')[0] ?? '',
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      role: UserRoleExtension.fromString(json['role']?.toString() ?? 'CUSTOMER'),
      gender: GenderExtension.fromString(json['gender']?.toString() ?? 'MALE'),
      profilePic: json['profile_pic']?.toString() ?? json['profile_image']?.toString(),
      phone: json['phone']?.toString() ?? json['phone_number']?.toString(),
      location: json['location']?.toString(),
      salonId: json['salon_id'] is int ? json['salon_id'] : int.tryParse(json['salon_id']?.toString() ?? ''),
      subscriptionTier: json['subscription_tier'] != null ? SubscriptionTier.values.firstWhere((e) => e.name.toUpperCase() == json['subscription_tier'].toString().toUpperCase(), orElse: () => SubscriptionTier.basic) : null,
      specialization: json['specialization']?.toString(),
      isOnline: (json['is_online'] ?? false) as bool,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      isEmailVerified: (json['is_email_verified'] ?? json['isVerified'] ?? false) as bool,
      isPhoneVerified: (json['is_phone_verified'] ?? false) as bool,
      isDeleted: (json['is_deleted'] ?? false) as bool,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'].toString()) : null,
      isActive: (json['is_active'] ?? true) as bool,
      isStaff: (json['is_staff'] ?? false) as bool,
      isSuperuser: (json['is_superuser'] ?? false) as bool,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.value,
      'gender': gender.value,
      'profile_pic': profilePic,
      'phone': phone,
      'location': location,
      'salon_id': salonId,
      'subscription_tier': subscriptionTier?.name.toUpperCase(),
      'specialization': specialization,
      'is_online': isOnline,
      'lat': lat,
      'lng': lng,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    UserRole? role,
    Gender? gender,
    String? profilePic,
    String? phone,
    String? location,
    int? salonId,
    SubscriptionTier? subscriptionTier,
    String? specialization,
    bool? isOnline,
    double? lat,
    double? lng,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isDeleted,
    DateTime? deletedAt,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      profilePic: profilePic ?? this.profilePic,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      salonId: salonId ?? this.salonId,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      specialization: specialization ?? this.specialization,
      isOnline: isOnline ?? this.isOnline,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
