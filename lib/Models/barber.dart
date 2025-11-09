import '../Models/staff_models.dart';

class Barber extends StaffMember {
  final double rating;
  final int totalAppointments;
  final double totalEarnings;
  final List<String> specialties;
  final Map<String, int> servicesCount;
  final DateTime? lastActive;

  Barber({
    required String id,
    required String name,
    required String email,
    required String phone,
    required DateTime joinDate,
    String? profileImage,
    String? branchId,
    bool isActive = true,
    required this.rating,
    required this.totalAppointments,
    required this.totalEarnings,
    required this.specialties,
    required this.servicesCount,
    this.lastActive,
    double? hourlyRate,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          role: StaffRole.barber,
          joinDate: joinDate,
          profileImage: profileImage,
          branchId: branchId,
          isActive: isActive,
          hourlyRate: hourlyRate,
          specialties: specialties,
          performanceMetrics: {
            'rating': rating,
            'totalAppointments': totalAppointments,
            'totalEarnings': totalEarnings,
            'servicesCount': servicesCount,
          },
        );

  factory Barber.fromStaffMember(StaffMember staff, {
    required double rating,
    required int totalAppointments,
    required double totalEarnings,
    required List<String> specialties,
    required Map<String, int> servicesCount,
    DateTime? lastActive,
  }) {
    return Barber(
      id: staff.id,
      name: staff.name,
      email: staff.email,
      phone: staff.phone,
      joinDate: staff.joinDate,
      profileImage: staff.profileImage,
      branchId: staff.branchId,
      isActive: staff.isActive,
      rating: rating,
      totalAppointments: totalAppointments,
      totalEarnings: totalEarnings,
      specialties: specialties,
      servicesCount: servicesCount,
      lastActive: lastActive,
      hourlyRate: staff.hourlyRate,
    );
  }

  double get averageServiceTime {
    final totalServices = servicesCount.values.reduce((a, b) => a + b);
    return totalServices > 0 ? totalAppointments / totalServices : 0;
  }

  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'rating': rating,
      'totalAppointments': totalAppointments,
      'totalEarnings': totalEarnings,
      'specialties': specialties,
      'servicesCount': servicesCount,
      'lastActive': lastActive?.toIso8601String(),
    });
    return json;
  }
}
