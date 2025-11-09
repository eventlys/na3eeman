class SoonestAppointment {
  final String id;
  final DateTime dateTime;
  final double totalPrice;
  final String shopName;
  final String shopPhoneNumber;
  final String shopId;
  final String customerName;
  final List<String> services;

  SoonestAppointment({
    required this.id,
    required this.dateTime,
    required this.totalPrice,
    required this.shopName,
    required this.shopPhoneNumber,
    required this.shopId,
    required this.customerName,
    required this.services,
  });

  SoonestAppointment copyWith({
    DateTime? dateTime,
    double? totalPrice,
    String? shopName,
    String? shopPhoneNumber,
  }) {
    return SoonestAppointment(
      id: id,
      dateTime: dateTime ?? this.dateTime,
      totalPrice: totalPrice ?? this.totalPrice,
      shopName: shopName ?? this.shopName,
      shopPhoneNumber: shopPhoneNumber ?? this.shopPhoneNumber,
      shopId: shopId,
      customerName: customerName,
      services: services,
    );
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
        shopId: 'shop1',
        customerName: 'John Doe',
        services: ['Haircut', 'Beard Trim'],
      ),
      SoonestAppointment(
        id: '2',
        dateTime: DateTime.now().add(Duration(days: 1, hours: 3)),
        totalPrice: 60.00,
        shopName: 'Elite Barber Studio',
        shopPhoneNumber: '+1 (555) 987-6543',
        shopId: 'shop2',
        customerName: 'John Doe',
        services: ['Haircut', 'Shave', 'Facial'],
      ),
      SoonestAppointment(
        id: '3',
        dateTime: DateTime.now().add(Duration(days: 2, hours: 1)),
        totalPrice: 35.00,
        shopName: 'Classic Barbers',
        shopPhoneNumber: '+1 (555) 456-7890',
        shopId: 'shop3',
        customerName: 'John Doe',
        services: ['Haircut'],
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
}

