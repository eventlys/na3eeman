class SoonestAppointment {
  final String id;
  final DateTime dateTime;
  final double totalPrice;
  final String salonName;
  final String salonPhoneNumber;
  final String salonId;
  final String customerName;
  final List<String> services;
  final String? barberName;
  final String? status;
  final String? salonAddress;
  final int? customerId;
  final int? barberId;

  SoonestAppointment({
    required this.id,
    required this.dateTime,
    required this.totalPrice,
    required this.salonName,
    required this.salonPhoneNumber,
    required this.salonId,
    required this.customerName,
    required this.services,
    this.barberName,
    this.status,
    this.salonAddress,
    this.customerId,
    this.barberId,
  });

  SoonestAppointment copyWith({
    DateTime? dateTime,
    double? totalPrice,
    String? salonName,
    String? salonPhoneNumber,
    String? barberName,
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
      barberName: barberName ?? this.barberName,
      status: status ?? this.status,
      salonAddress: salonAddress,
      customerId: customerId,
      barberId: barberId,
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
      barberName: json['barber_name'] as String?,
      status: json['status'] as String?,
      salonAddress: json['salon_address'] as String?,
      customerId: json['customer'] as int?,
      barberId: json['barber'] as int?,
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
      'barber_name': barberName,
      'status': status,
      'salon_address': salonAddress,
      'customer': customerId,
      'barber': barberId,
    };
  }
}

class SoonestAppointmentData {
  static List<SoonestAppointment> getMockAppointments() {
    return [
      SoonestAppointment(
        id: '1',
        dateTime: DateTime.now().add(Duration(hours: 2)),
        totalPrice: 45.00,
        salonName: 'Modern Cuts Barbersalon',
        salonPhoneNumber: '+1 (555) 123-4567',
        salonId: '1',
        customerName: 'John Doe',
        services: ['Haircut', 'Beard Trim'],
        barberName: 'Mike Johnson',
        status: 'SCHEDULED',
      ),
      SoonestAppointment(
        id: '2',
        dateTime: DateTime.now().add(Duration(days: 1, hours: 3)),
        totalPrice: 60.00,
        salonName: 'Elite Barber Studio',
        salonPhoneNumber: '+1 (555) 987-6543',
        salonId: '2',
        customerName: 'John Doe',
        services: ['Haircut', 'Shave', 'Facial'],
        barberName: 'Sarah Wilson',
        status: 'SCHEDULED',
      ),
    ];
  }

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
