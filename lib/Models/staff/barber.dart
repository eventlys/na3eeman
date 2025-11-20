import '../../Services/enums/staff_role.dart';
import '../auth/barber_profile.dart';
import '../auth/user_model.dart';
import 'staff_member.dart';

class Barber extends StaffMember {
  final BarberProfile? barberProfile;
  final double rating;
  final int totalAppointments;
  final double totalEarnings;
  final List<String> specialties;
  final Map<String, int> servicesCount;
  final DateTime? lastActive;

  Barber({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.joinDate,
    super.profileImage,
    super.shopId,
    super.isActive = true,
    super.hourlyRate,
    this.barberProfile,
    required this.rating,
    required this.totalAppointments,
    required this.totalEarnings,
    required this.specialties,
    required this.servicesCount,
    this.lastActive,
  }) : super(
          role: StaffRole.barber,
          phone: barberProfile?.contactPhone,
          specialties: specialties,
          performanceMetrics: {
            'rating': rating,
            'totalAppointments': totalAppointments,
            'totalEarnings': totalEarnings,
            'servicesCount': servicesCount,
          },
        );

  factory Barber.fromUserAndProfile({
    required User user,
    required BarberProfile profile,
    double rating = 0.0,
    int totalAppointments = 0,
    double totalEarnings = 0.0,
    List<String> specialties = const [],
    Map<String, int> servicesCount = const {},
    DateTime? lastActive,
    double? hourlyRate,
    int? shopId,
  }) {
    return Barber(
      id: user.id.toString(),
      userId: user.id,
      name: user.fullName,
      email: user.email,
      joinDate: user.createdAt,
      profileImage: user.profilePic,
      shopId: shopId,
      isActive: user.isActive,
      hourlyRate: hourlyRate,
      barberProfile: profile,
      rating: rating,
      totalAppointments: totalAppointments,
      totalEarnings: totalEarnings,
      specialties: specialties,
      servicesCount: servicesCount,
      lastActive: lastActive,
    );
  }

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      id: json['id']?.toString() ?? '',
      userId: json['barber'] as int? ?? 0,
      name: json['barber_name'] as String? ?? '',
      email: json['barber_email'] as String? ?? '',
      joinDate: DateTime.parse(json['hired_at'] as String? ?? DateTime.now().toString()),
      profileImage: json['profile_image'] as String?,
      shopId: json['shop'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      barberProfile: json['barber_profile'] != null
          ? BarberProfile.fromJson(json['barber_profile'])
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalAppointments: (json['total_appointments'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      specialties: List<String>.from(json['specialties'] ?? []),
      servicesCount: Map<String, int>.from(json['services_count'] ?? {}),
      lastActive: json['last_active'] != null
          ? DateTime.tryParse(json['last_active'].toString())
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'barber_profile': barberProfile?.toJson(),
      'rating': rating,
      'total_appointments': totalAppointments,
      'total_earnings': totalEarnings,
      'specialties': specialties,
      'services_count': servicesCount,
      'last_active': lastActive?.toIso8601String(),
    });
    return json;
  }

  double get averageServiceTime {
    final totalServices = servicesCount.values.fold(0, (sum, count) => sum + count);
    return totalServices > 0 ? totalAppointments / totalServices : 0;
  }
}
