class SoonestAppointment {
  final String id;
  final DateTime dateTime;
  final double totalPrice;
  final String shopName;
  final String shopPhoneNumber;
  final String shopId;
  final String customerName;
  final List<String> services;
  final String? barberName;
  final String? status;
  final String? shopAddress;
  final int? customerId;
  final int? barberId;

  SoonestAppointment({
    required this.id,
    required this.dateTime,
    required this.totalPrice,
    required this.shopName,
    required this.shopPhoneNumber,
    required this.shopId,
    required this.customerName,
    required this.services,
    this.barberName,
    this.status,
    this.shopAddress,
    this.customerId,
    this.barberId,
  });

  SoonestAppointment copyWith({
    DateTime? dateTime,
    double? totalPrice,
    String? shopName,
    String? shopPhoneNumber,
    String? barberName,
    String? status,
    List<String>? services,
  }) {
    return SoonestAppointment(
      id: id,
      dateTime: dateTime ?? this.dateTime,
      totalPrice: totalPrice ?? this.totalPrice,
      shopName: shopName ?? this.shopName,
      shopPhoneNumber: shopPhoneNumber ?? this.shopPhoneNumber,
      shopId: shopId,
      customerName: customerName,
      services: services ?? this.services,
      barberName: barberName ?? this.barberName,
      status: status ?? this.status,
      shopAddress: shopAddress,
      customerId: customerId,
      barberId: barberId,
    );
  }

  factory SoonestAppointment.fromAppointment(Map<String, dynamic> json) {
    return SoonestAppointment(
      id: json['id']?.toString() ?? '',
      dateTime: DateTime.parse(json['start_time'] as String),
      totalPrice: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      shopName: json['shop_name'] as String? ?? '',
      shopPhoneNumber: json['shop_phone'] as String? ?? '',
      shopId: json['shop_id']?.toString() ?? json['shop']?.toString() ?? '',
      customerName: json['customer_name'] as String? ?? '',
      services: List<String>.from(json['services'] ?? []),
      barberName: json['barber_name'] as String?,
      status: json['status'] as String?,
      shopAddress: json['shop_address'] as String?,
      customerId: json['customer'] as int?,
      barberId: json['barber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': dateTime.toIso8601String(),
      'total_amount': totalPrice,
      'shop_name': shopName,
      'shop_phone': shopPhoneNumber,
      'shop': shopId,
      'customer_name': customerName,
      'services': services,
      'barber_name': barberName,
      'status': status,
      'shop_address': shopAddress,
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
        shopName: 'Modern Cuts Barbershop',
        shopPhoneNumber: '+1 (555) 123-4567',
        shopId: '1',
        customerName: 'John Doe',
        services: ['Haircut', 'Beard Trim'],
        barberName: 'Mike Johnson',
        status: 'SCHEDULED',
      ),
      SoonestAppointment(
        id: '2',
        dateTime: DateTime.now().add(Duration(days: 1, hours: 3)),
        totalPrice: 60.00,
        shopName: 'Elite Barber Studio',
        shopPhoneNumber: '+1 (555) 987-6543',
        shopId: '2',
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
