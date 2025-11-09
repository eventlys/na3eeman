class Branch {
  final int id;
  final String name;
  final String address;
  final String phone;
  final bool isOpen;
  final int todayAppointments;
  final double todayRevenue;

  // New fields for shop owner dashboard
  final String? manager;
  final double? monthlyRevenue;
  final int? totalSales;
  final int? lowStockItems;
  final String? email;
  final DateTime? openingDate;
  final int? totalEmployees;

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
    this.totalEmployees,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      isOpen: json['is_open'] ?? false,
      todayAppointments: json['today_appointments'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      // New fields with null safety
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
      totalEmployees: json['total_employees'] is int ? json['total_employees'] : int.tryParse(json['total_employees']?.toString() ?? '0'),
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
      // New fields
      'manager': manager,
      'monthly_revenue': monthlyRevenue,
      'total_sales': totalSales,
      'low_stock_items': lowStockItems,
      'email': email,
      'opening_date': openingDate?.toIso8601String(),
      'total_employees': totalEmployees,
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
    int? totalEmployees,
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
      totalEmployees: totalEmployees ?? this.totalEmployees,
    );
  }

  // Helper methods for the shop owner dashboard
  String get status => isOpen ? 'Open' : 'Closed';

  String get performanceLevel {
    if (monthlyRevenue == null) return 'Unknown';
    if (monthlyRevenue! > 50000) return 'Excellent';
    if (monthlyRevenue! > 25000) return 'Good';
    if (monthlyRevenue! > 10000) return 'Average';
    return 'Needs Attention';
  }

  bool get isActive {
    // If you don't have an isActive field, you can determine based on other logic
    // For now, let's assume all branches are active
    return true;
  }

  double get safeMonthlyRevenue {
    return monthlyRevenue ?? todayRevenue * 30; // Estimate if null
  }

  String get formattedMonthlyRevenue {
    return safeMonthlyRevenue.toStringAsFixed(2);
  }

  String get formattedTodayRevenue {
    return todayRevenue.toStringAsFixed(2);
  }

  bool get hasLowStockAlerts => (lowStockItems ?? 0) > 0;

  double get getMonthlyRevenue => monthlyRevenue ?? todayRevenue * 30; // Estimate if not available

  int get getTotalSales => totalSales ?? todayAppointments * 30; // Estimate if not available

  int get totalStaff {
    // You can calculate this based on your data or return a field
    return totalEmployees ?? 5; // Fallback to 5 if null
  }
}
