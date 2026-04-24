import '../../Services/enums/staff_role.dart';

class StaffMember {
  final String id;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final StaffRole role;
  final DateTime joinDate;
  final String? profileImage;
  final int salonId;
  final bool isActive;
  final double hourlyRate;
  final List<String> specialties;
  final Map<String, dynamic> performanceMetrics;

  StaffMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.joinDate,
    this.profileImage,
    required this.salonId,
    this.isActive = true,
    required this.hourlyRate,
    required this.specialties,
    required this.performanceMetrics,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'].toString(),
      userId: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: StaffRoleExtension.fromString(json['role'] as String),
      joinDate: DateTime.parse(json['join_date'] as String),
      profileImage: json['profile_image'] as String?,
      salonId: json['salon_id'] as int,
      isActive: json['is_active'] as bool? ?? true,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      specialties: List<String>.from(json['specialties'] ?? []),
      performanceMetrics: Map<String, dynamic>.from(json['performance_metrics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'join_date': joinDate.toIso8601String(),
      'profile_image': profileImage,
      'salon_id': salonId,
      'is_active': isActive,
      'hourly_rate': hourlyRate,
      'specialties': specialties,
      'performance_metrics': performanceMetrics,
    };
  }

  StaffMember copyWith({
    String? id,
    int? userId,
    String? name,
    String? email,
    String? phone,
    StaffRole? role,
    DateTime? joinDate,
    String? profileImage,
    int? salonId,
    bool? isActive,
    double? hourlyRate,
    List<String>? specialties,
    Map<String, dynamic>? performanceMetrics,
  }) {
    return StaffMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
      profileImage: profileImage ?? this.profileImage,
      salonId: salonId ?? this.salonId,
      isActive: isActive ?? this.isActive,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      specialties: specialties ?? this.specialties,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
}
