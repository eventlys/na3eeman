class Branch {
  final int id;
  final String name;
  final String address;
  final String phone;
  final bool isOpen;
  final int todayAppointments;
  final double todayRevenue;
  final String? manager;
  final double? monthlyRevenue;
  final int? totalSales;
  final int? lowStockItems;
  final String? email;
  final DateTime? openingDate;
  final int? totalExperts;
  final int salonId;
  final String? openingTime;
  final String? closingTime;
  final int? seats;
  final int? staffCount;
  final double? lat;
  final double? lng;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isOpen,
    required this.todayAppointments,
    required this.todayRevenue,
    this.manager,
    this.monthlyRevenue,
    this.totalSales,
    this.lowStockItems,
    this.email,
    this.openingDate,
    this.totalExperts,
    required this.salonId,
    this.openingTime,
    this.closingTime,
    this.seats,
    this.staffCount,
    this.lat,
    this.lng,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['salon_name'] ?? '',
      address: json['address'] ?? json['location'] ?? '',
      phone: json['phone'] ?? json['salon_phon_num'] ?? '',
      isOpen: json['is_open'] ?? false,
      todayAppointments: json['today_appointments'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      manager: json['manager']?.toString(),
      monthlyRevenue: json['monthly_revenue'] != null
          ? (json['monthly_revenue'] is double
              ? json['monthly_revenue']
              : double.tryParse(json['monthly_revenue'].toString()) ?? 0.0)
          : null,
      totalSales: json['total_sales'] is int ? json['total_sales'] : int.tryParse(json['total_sales']?.toString() ?? '0'),
      lowStockItems: json['low_stock_items'] is int ? json['low_stock_items'] : int.tryParse(json['low_stock_items']?.toString() ?? '0'),
      email: json['email']?.toString(),
      openingDate: json['opening_date'] != null
          ? DateTime.tryParse(json['opening_date'].toString())
          : null,
      totalExperts: json['total_experts'] is int ? json['total_experts'] : int.tryParse(json['total_experts']?.toString() ?? '0'),
      salonId: json['salon'] as int? ?? 0,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      seats: json['seats'] as int? ?? json['salon_seats'] as int?,
      staffCount: json['staff_count'] as int? ?? json['salon_staff'] as int?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'is_open': isOpen,
      'today_appointments': todayAppointments,
      'today_revenue': todayRevenue,
      'manager': manager,
      'monthly_revenue': monthlyRevenue,
      'total_sales': totalSales,
      'low_stock_items': lowStockItems,
      'email': email,
      'opening_date': openingDate?.toIso8601String(),
      'total_experts': totalExperts,
      'salon': salonId,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'seats': seats,
      'staff_count': staffCount,
      'lat': lat,
      'lng': lng,
    };
  }

  Branch copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    bool? isOpen,
    int? todayAppointments,
    double? todayRevenue,
    String? manager,
    double? monthlyRevenue,
    int? totalSales,
    int? lowStockItems,
    String? email,
    DateTime? openingDate,
    int? totalExperts,
    int? salonId,
    String? openingTime,
    String? closingTime,
    int? seats,
    int? staffCount,
    double? lat,
    double? lng,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      manager: manager ?? this.manager,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      totalSales: totalSales ?? this.totalSales,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      email: email ?? this.email,
      openingDate: openingDate ?? this.openingDate,
      totalExperts: totalExperts ?? this.totalExperts,
      salonId: salonId ?? this.salonId,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      seats: seats ?? this.seats,
      staffCount: staffCount ?? this.staffCount,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  // Helper methods for the salon owner dashboard
  String get status => isOpen ? 'Open' : 'Closed';

  String get performanceLevel {
    if (monthlyRevenue == null) return 'Unknown';
    if (monthlyRevenue! > 50000) return 'Excellent';
    if (monthlyRevenue! > 25000) return 'Good';
    if (monthlyRevenue! > 10000) return 'Average';
    return 'Needs Attention';
  }

  bool get isActive => isOpen;

  double get safeMonthlyRevenue {
    return monthlyRevenue ?? todayRevenue * 30;
  }

  String get formattedMonthlyRevenue {
    return safeMonthlyRevenue.toStringAsFixed(2);
  }

  String get formattedTodayRevenue {
    return todayRevenue.toStringAsFixed(2);
  }

  bool get hasLowStockAlerts => (lowStockItems ?? 0) > 0;

  double get getMonthlyRevenue => monthlyRevenue ?? todayRevenue * 30;

  int get getTotalSales => totalSales ?? todayAppointments;

  int get totalStaff {
    return totalExperts ?? (staffCount ?? 5);
  }

  String get operatingHours {
    if (openingTime != null && closingTime != null) {
      return '$openingTime - $closingTime';
    }
    return '9:00 AM - 6:00 PM';
  }
}
