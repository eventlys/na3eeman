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
  final String? status;
  final String? statusNote;

  StaffMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    required this.joinDate,
    this.profileImage,
    this.salonId = 0,
    this.isActive = true,
    this.hourlyRate = 0.0,
    this.specialties = const [],
    this.performanceMetrics = const {},
    this.status,
    this.statusNote,
  });

  String get roleString => role.displayName;

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      userId: _toInt(json['user_id'] ?? json['expert'] ?? json['user']),
      name: (json['name'] ?? json['expert_name'] ?? '') as String,
      email: (json['email'] ?? json['expert_email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: StaffRoleExtension.fromString(json['role']?.toString() ?? 'EXPERT'),
      joinDate: DateTime.parse(
        json['join_date']?.toString() ??
            json['hired_at']?.toString() ??
            DateTime.now().toIso8601String(),
      ),
      profileImage: json['profile_image'] as String?,
      salonId: _toInt(json['salon_id'] ?? json['salon']),
      isActive: json['is_active'] as bool? ?? true,
      hourlyRate: (json['hourly_rate'] as num? ?? 0.0).toDouble(),
      specialties: List<String>.from(json['specialties'] ?? []),
      performanceMetrics: Map<String, dynamic>.from(
        json['performance_metrics'] ?? {},
      ),
      status: json['status'] as String?,
      statusNote: json['status_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'join_date': joinDate.toIso8601String(),
      'profile_image': profileImage,
      'salon_id': salonId,
      'is_active': isActive,
      'hourly_rate': hourlyRate,
      'specialties': specialties,
      'performance_metrics': performanceMetrics,
      'status': status,
      'status_note': statusNote,
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
    String? status,
    String? statusNote,
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
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
    );
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
