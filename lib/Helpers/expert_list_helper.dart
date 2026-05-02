class ExpertDto {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double rating;
  final int totalAppointments;
  final List<String> specialties;
  final String? profileImage;
  final bool isActive;
  final double? hourlyRate;
  final DateTime? lastActive;
  final int? salonId;

  ExpertDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rating,
    required this.totalAppointments,
    required this.specialties,
    this.profileImage,
    this.isActive = true,
    this.hourlyRate,
    this.lastActive,
    this.salonId,
  });

  factory ExpertDto.fromJson(Map<String, dynamic> json) {
    return ExpertDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['contact_phone'] ?? '',
      rating: (json['rating'] ?? json['avg_rating'] ?? 0.0).toDouble(),
      totalAppointments: json['total_appointments'] ?? json['appointments_count'] ?? 0,
      specialties: _parseSpecialties(json['specialties']),
      profileImage: json['profile_image'] ?? json['image_url'],
      isActive: json['is_active'] ?? true,
      hourlyRate: (json['hourly_rate'] ?? json['rate'] ?? 0.0).toDouble(),
      lastActive: json['last_active'] != null ? DateTime.parse(json['last_active']) : null,
      salonId: json['salon_id'],
    );
  }

  static List<String> _parseSpecialties(dynamic specialties) {
    if (specialties is List) {
      return specialties.map((e) => e.toString()).toList();
    } else if (specialties is String) {
      return specialties.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'rating': rating,
      'total_appointments': totalAppointments,
      'specialties': specialties,
      'profile_image': profileImage,
      'is_active': isActive,
      'hourly_rate': hourlyRate,
      'last_active': lastActive?.toIso8601String(),
      'salon_id': salonId,
    };
  }

  ExpertDto copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? rating,
    int? totalAppointments,
    List<String>? specialties,
    String? profileImage,
    bool? isActive,
    double? hourlyRate,
    DateTime? lastActive,
    int? salonId,
  }) {
    return ExpertDto(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      specialties: specialties ?? this.specialties,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      lastActive: lastActive ?? this.lastActive,
      salonId: salonId ?? this.salonId,
    );
  }
}


class ExpertPerformanceData {
  final String expertId;
  final String expertName;
  final double rating;
  final int totalAppointments;
  final double totalEarnings;
  final double efficiencyScore;

  ExpertPerformanceData({
    required this.expertId,
    required this.expertName,
    required this.rating,
    required this.totalAppointments,
    required this.totalEarnings,
    required this.efficiencyScore,
  });
}

class PerformanceHelper {
  List<ExpertPerformanceData> calculatePerformanceMetrics(List<ExpertDto> experts) {
    return experts.map((expert) {
      // Calculate performance metrics based on expert data
      final efficiencyScore = _calculateEfficiencyScore(
        expert.rating,
        expert.totalAppointments,
      );

      return ExpertPerformanceData(
        expertId: expert.id,
        expertName: expert.name,
        rating: expert.rating,
        totalAppointments: expert.totalAppointments,
        totalEarnings: _calculateTotalEarnings(expert),
        efficiencyScore: efficiencyScore,
      );
    }).toList();
  }

  double _calculateEfficiencyScore(double rating, int appointments) {
    // Simple efficiency calculation based on rating and appointment volume
    final baseScore = rating * 20; // Convert rating to base score
    final volumeBonus = appointments * 0.1; // Small bonus for more appointments
    return (baseScore + volumeBonus).clamp(0.0, 100.0);
  }

  double _calculateTotalEarnings(ExpertDto expert) {
    // Calculate earnings based on appointments and hourly rate
    final baseRate = expert.hourlyRate ?? 25.0; // Default rate if not provided
    final avgAppointmentDuration = 0.75; // Average appointment duration in hours
    return expert.totalAppointments * baseRate * avgAppointmentDuration;
  }

  List<ExpertPerformanceData> sortByRating(List<ExpertPerformanceData> data) {
    final sorted = List<ExpertPerformanceData>.from(data);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  List<ExpertPerformanceData> sortByEarnings(List<ExpertPerformanceData> data) {
    final sorted = List<ExpertPerformanceData>.from(data);
    sorted.sort((a, b) => b.totalEarnings.compareTo(a.totalEarnings));
    return sorted;
  }

  List<ExpertPerformanceData> sortByEfficiency(List<ExpertPerformanceData> data) {
    final sorted = List<ExpertPerformanceData>.from(data);
    sorted.sort((a, b) => b.efficiencyScore.compareTo(a.efficiencyScore));
    return sorted;
  }
}
