import 'package:flutter/foundation.dart';
import '../../Services/enums/gender.dart';
import '../../core/enums/app_enums.dart';

@immutable
class User {
  final int id;
  final String email;
  final String username;
  final String? phone;
  final String firstName;
  final String lastName;
  final String? profilePic;
  final UserRole role;
  final Gender gender;
  final String location;
  final double lat;
  final double lng;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final String? specialization;
  final int? shopId; // Shop association for staff

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePic,
    required this.role,
    required this.gender,
    this.location = 'Amman, Jordan',
    this.lat = 31.963158,
    this.lng = 35.930359,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = false,
    this.specialization,
    this.shopId,
  });

  String get fullName => '$firstName $lastName';
  bool get isCustomer => role == UserRole.customer;
  bool get isEmployee => role == UserRole.employee;
  bool get isBarber => role == UserRole.employee;
  bool get isOwner => role == UserRole.owner;
  bool get isReceptionist => role == UserRole.receptionist;
  bool get isIntern => role == UserRole.intern;
  bool get isAdmin => role == UserRole.admin;
  bool get isStaffMember => isEmployee || isOwner || isReceptionist || isIntern || isAdmin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String?,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePic: (json['profile_pic_path'] ?? json['profile_pic']) as String?,
      role: UserRoleExtension.fromString(json['role'] as String? ?? 'CUSTOMER'),
      gender: GenderExtension.fromString(json['gender'] as String? ?? 'MALE'),
      location: json['location'] as String? ?? 'Amman, Jordan',
      lat: (json['lat'] as num?)?.toDouble() ?? 31.963158,
      lng: (json['lng'] as num?)?.toDouble() ?? 35.930359,
      isEmailVerified: (json['is_email_verified'] ?? json['vrfid_email']) as bool? ?? false,
      isPhoneVerified: (json['is_phone_verified'] ?? json['vrfid_phone']) as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      specialization: json['specialization'] is List
          ? (json['specialization'] as List).join(', ')
          : json['specialization'] as String?,
      shopId: json['shop'] as int?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'profile_pic': profilePic,
      'role': role.value,
      'gender': gender.value,
      'location': location,
      'lat': lat,
      'lng': lng,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'specialization': specialization,
      'shop': shopId,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? phone,
    String? firstName,
    String? lastName,
    String? profilePic,
    UserRole? role,
    Gender? gender,
    String? location,
    double? lat,
    double? lng,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    String? specialization,
    int? shopId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      specialization: specialization ?? this.specialization,
      shopId: shopId ?? this.shopId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
