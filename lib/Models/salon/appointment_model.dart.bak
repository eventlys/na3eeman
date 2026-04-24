import '../../Services/enums/appointment_status.dart';

class SalonAppointment {
  final String id;
  final int customerId;
  final int salonId;
  final int? barberId;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final DateTime createdAt;
  final List<String> services;

  SalonAppointment({
    required this.id,
    required this.customerId,
    required this.salonId,
    this.barberId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    required this.services,
  });

  factory SalonAppointment.fromJson(Map<String, dynamic> json) {
    return SalonAppointment(
      id: json['id'].toString(),
      customerId: json['customer_id'] ?? json['customerId'] ?? 0,
      salonId: json['salon_id'] ?? json['salonId'] ?? 0,
      barberId: json['barber_id'] ?? json['barberId'],
      startTime: DateTime.parse(json['start_time'] ?? json['startTime']),
      endTime: DateTime.parse(json['end_time'] ?? json['endTime']),
      status: AppointmentStatusExtension.fromString(json['status'] ?? 'PENDING'),
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      services: List<String>.from(json['services'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'salon_id': salonId,
      'barber_id': barberId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.name.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      'services': services,
    };
  }

  SalonAppointment copyWith({
    String? id,
    int? customerId,
    int? salonId,
    int? barberId,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    DateTime? createdAt,
    List<String>? services,
  }) {
    return SalonAppointment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      salonId: salonId ?? this.salonId,
      barberId: barberId ?? this.barberId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      services: services ?? this.services,
    );
  }
}
