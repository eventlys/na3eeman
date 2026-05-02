class SoonestAppointment {
  final String id;
  final DateTime dateTime;
  final double totalPrice;
  final String salonName;
  final String salonPhoneNumber;
  final String salonId;
  final String customerName;
  final List<String> services;
  final String? expertName;
  final String? status;
  final String? salonAddress;
  final int? customerId;
  final int? expertId;

  SoonestAppointment({
    required this.id,
    required this.dateTime,
    required this.totalPrice,
    required this.salonName,
    required this.salonPhoneNumber,
    required this.salonId,
    required this.customerName,
    required this.services,
    this.expertName,
    this.status,
    this.salonAddress,
    this.customerId,
    this.expertId,
  });

  SoonestAppointment copyWith({
    DateTime? dateTime,
    double? totalPrice,
    String? salonName,
    String? salonPhoneNumber,
    String? expertName,
    String? status,
    List<String>? services,
  }) {
    return SoonestAppointment(
      id: id,
      dateTime: dateTime ?? this.dateTime,
      totalPrice: totalPrice ?? this.totalPrice,
      salonName: salonName ?? this.salonName,
      salonPhoneNumber: salonPhoneNumber ?? this.salonPhoneNumber,
      salonId: salonId,
      customerName: customerName,
      services: services ?? this.services,
      expertName: expertName ?? this.expertName,
      status: status ?? this.status,
      salonAddress: salonAddress,
      customerId: customerId,
      expertId: expertId,
    );
  }

  factory SoonestAppointment.fromAppointment(Map<String, dynamic> json) {
    return SoonestAppointment(
      id: json['id']?.toString() ?? '',
      dateTime: DateTime.parse(json['start_time'] as String),
      totalPrice: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      salonName: json['salon_name'] as String? ?? '',
      salonPhoneNumber: json['salon_phone'] as String? ?? '',
      salonId: json['salon_id']?.toString() ?? json['salon']?.toString() ?? '',
      customerName: json['customer_name'] as String? ?? '',
      services: List<String>.from(json['services'] ?? []),
      expertName: json['expert_name'] ?? json['expert_name'] as String?,
      status: json['status'] as String?,
      salonAddress: json['salon_address'] as String?,
      customerId: json['customer'] as int?,
      expertId: json['expert'] ?? json['expert'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': dateTime.toIso8601String(),
      'total_amount': totalPrice,
      'salon_name': salonName,
      'salon_phone': salonPhoneNumber,
      'salon': salonId,
      'customer_name': customerName,
      'services': services,
      'expert_name': expertName,
      'status': status,
      'salon_address': salonAddress,
      'customer': customerId,
      'expert': expertId,
    };
  }
}

class SoonestAppointmentData {
  static SoonestAppointment? getSoonestAppointment(List<SoonestAppointment> appointments) {
    if (appointments.isEmpty) return null;

    DateTime now = DateTime.now();
    List<SoonestAppointment> upcomingAppointments = appointments
        .where((appointment) => appointment.dateTime.isAfter(now))
        .toList();

    if (upcomingAppointments.isEmpty) return null;

    upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcomingAppointments.first;
  }

  static SoonestAppointment? fromAppointmentJson(Map<String, dynamic> json) {
    try {
      return SoonestAppointment.fromAppointment(json);
    } catch (e) {
      return null;
    }
  }
}
