import '../auth/user_model.dart';
import '../auth/barber_profile.dart';

class Barber {
  final User user;
  final BarberProfile profile;
  final double rating;
  final int totalAppointments;
  final double totalEarnings;
  final List<String> specialties;
  final Map<String, int> servicesCount;
  final DateTime? lastActive;
  final double hourlyRate;
  final int shopId;

  Barber({
    required this.user,
    required this.profile,
    required this.rating,
    required this.totalAppointments,
    required this.totalEarnings,
    required this.specialties,
    required this.servicesCount,
    this.lastActive,
    required this.hourlyRate,
    required this.shopId,
  });

  factory Barber.fromUserAndProfile({
    required User user,
    required BarberProfile profile,
    required double rating,
    required int totalAppointments,
    required double totalEarnings,
    required List<String> specialties,
    required Map<String, int> servicesCount,
    DateTime? lastActive,
    required double hourlyRate,
    required int shopId,
  }) {
    return Barber(
      user: user,
      profile: profile,
      rating: rating,
      totalAppointments: totalAppointments,
      totalEarnings: totalEarnings,
      specialties: specialties,
      servicesCount: servicesCount,
      lastActive: lastActive,
      hourlyRate: hourlyRate,
      shopId: shopId,
    );
  }

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      user: User.fromJson(json['user']),
      profile: BarberProfile.fromJson(json['profile']),
      rating: (json['rating'] as num).toDouble(),
      totalAppointments: json['total_appointments'] as int,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      specialties: List<String>.from(json['specialties'] ?? []),
      servicesCount: Map<String, int>.from(json['services_count'] ?? {}),
      lastActive: json['last_active'] != null ? DateTime.parse(json['last_active']) : null,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      shopId: json['shop_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'profile': profile.toJson(),
      'rating': rating,
      'total_appointments': totalAppointments,
      'total_earnings': totalEarnings,
      'specialties': specialties,
      'services_count': servicesCount,
      'last_active': lastActive?.toIso8601String(),
      'hourly_rate': hourlyRate,
      'shop_id': shopId,
    };
  }
}
