import '../../Services/enums/staff_role.dart';

class StaffMember {
  final String id;
  final int userId;
  final String name;
  final String email;
  final String? phone;
  final StaffRole role;
  final DateTime joinDate;
  final String? profileImage;
  final int? shopId;
  final bool isActive;
  final double? hourlyRate;
  final List<String>? specialties;
  final Map<String, dynamic>? performanceMetrics;

  StaffMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.joinDate,
    this.profileImage,
    this.shopId,
    this.isActive = true,
    this.hourlyRate,
    this.specialties,
    this.performanceMetrics,
  });

  String get roleString => role.displayName;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      userId: json['barber'] as int? ?? json['user'] as int? ?? 0,
      name: json['barber_name'] as String? ?? json['name'] as String? ?? '',
      email: json['barber_email'] as String? ?? json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: StaffRoleExtension.fromString(json['role']?.toString() ?? 'barber'),
      joinDate: DateTime.parse(json['hired_at']?.toString() ?? json['join_date']?.toString() ?? DateTime.now().toString()),
      profileImage: json['profile_image'] as String?,
      shopId: json['shop'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : null,
      performanceMetrics: json['performance_metrics'] != null
          ? Map<String, dynamic>.from(json['performance_metrics'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barber': userId,
      'barber_name': name,
      'barber_email': email,
      'phone': phone,
      'role': role.value,
      'hired_at': joinDate.toIso8601String(),
      'profile_image': profileImage,
      'shop': shopId,
      'is_active': isActive,
      'hourly_rate': hourlyRate,
      'specialties': specialties,
      'performance_metrics': performanceMetrics,
    };
  }
}

class ShopBarber {
  final int id;
  final int barberId;
  final String barberName;
  final String barberEmail;
  final int shopId;
  final bool isActive;
  final DateTime hiredAt;

  ShopBarber({
    required this.id,
    required this.barberId,
    required this.barberName,
    required this.barberEmail,
    required this.shopId,
    required this.isActive,
    required this.hiredAt,
  });

  factory ShopBarber.fromJson(Map<String, dynamic> json) {
    return ShopBarber(
      id: json['id'] as int,
      barberId: json['barber'] as int,
      barberName: json['barber_name'] as String,
      barberEmail: json['barber_email'] as String,
      shopId: json['shop'] as int,
      isActive: json['is_active'] as bool? ?? true,
      hiredAt: DateTime.parse(json['hired_at'] as String),
    );
  }
}
