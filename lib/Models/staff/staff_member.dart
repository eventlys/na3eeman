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
  final int? salonId;
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
    this.salonId,
    this.isActive = true,
    this.hourlyRate,
    this.specialties,
    this.performanceMetrics,
  });

  String get roleString => role.displayName;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      userId: json['expert'] as int? ?? json['user'] as int? ?? 0,
      name: json['expert_name'] as String? ?? json['name'] as String? ?? '',
      email: json['expert_email'] as String? ?? json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: StaffRoleExtension.fromString(json['role']?.toString() ?? 'expert'),
      joinDate: DateTime.parse(json['hired_at']?.toString() ?? json['join_date']?.toString() ?? DateTime.now().toString()),
      profileImage: json['profile_image'] as String?,
      salonId: json['salon'] as int?,
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
      'expert': userId,
      'expert_name': name,
      'expert_email': email,
      'phone': phone,
      'role': role.value,
      'hired_at': joinDate.toIso8601String(),
      'profile_image': profileImage,
      'salon': salonId,
      'is_active': isActive,
      'hourly_rate': hourlyRate,
      'specialties': specialties,
      'performance_metrics': performanceMetrics,
    };
  }
}

class SalonExpert {
  final int id;
  final int expertId;
  final String expertName;
  final String expertEmail;
  final int salonId;
  final bool isActive;
  final DateTime hiredAt;

  SalonExpert({
    required this.id,
    required this.expertId,
    required this.expertName,
    required this.expertEmail,
    required this.salonId,
    required this.isActive,
    required this.hiredAt,
  });

  factory SalonExpert.fromJson(Map<String, dynamic> json) {
    return SalonExpert(
      id: json['id'] as int,
      expertId: json['expert'] as int,
      expertName: json['expert_name'] as String,
      expertEmail: json['expert_email'] as String,
      salonId: json['salon'] as int,
      isActive: json['is_active'] as bool? ?? true,
      hiredAt: DateTime.parse(json['hired_at'] as String),
    );
  }
}
