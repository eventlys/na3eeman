class ShopAppointment {
  final String id;
  final String imagePath;
  final String title;
  final String status;
  final double totalPrice;
  final String serviceTime;
  final String date;
  final String barberName;
  final String barberNumber;
  final String barberShopName;

  ShopAppointment({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.status,
    required this.totalPrice,
    required this.serviceTime,
    required this.date,
    required this.barberName,
    required this.barberNumber,
    required this.barberShopName,
  });

  factory ShopAppointment.fromJson(Map<String, dynamic> json) {
    return ShopAppointment(
      id: json['id']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalPrice: (json['totalPrice'] is int ? (json['totalPrice'] as int).toDouble() : json['totalPrice'] ?? 0.0),
      serviceTime: json['serviceTime']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      barberName: json['barberName']?.toString() ?? '',
      barberNumber: json['barberNumber']?.toString() ?? '',
      barberShopName: json['barberShopName']?.toString() ?? '',
    );
  }
}

