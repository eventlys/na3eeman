// import 'dart:convert';
// import 'package:http/http.dart' as http;
import '../Models/barber.dart';
import '../Models/branch_model.dart';
import '../Models/inventory_item.dart';
import '../Models/staff_models.dart';
import '../Models/subscription.dart';
import '../Models/profit_data.dart';
import '../Models/offer.dart';
import '../Models/pending_confirmation_model.dart';
import '../Models/working_hours_model.dart';


class ApiService {
  static const String baseUrl = 'https://your-api-domain.com/api';

    // ========== STAFF MANAGEMENT METHODS ==========

  static Future<List<StaffMember>> getStaffMembers({String? branchId}) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Mock staff data - replace with actual API call
    return [
      StaffMember(
        id: '1',
        name: 'John Barber',
        email: 'john@barbershop.com',
        phone: '+1234567890',
        role: StaffRole.barber,
        joinDate: DateTime(2023, 1, 15),
        branchId: '1',
        hourlyRate: 25.0,
        specialties: ['Haircut', 'Beard Trim', 'Styling'],
      ),
      StaffMember(
        id: '2',
        name: 'Mike Styles',
        email: 'mike@barbershop.com',
        phone: '+1234567891',
        role: StaffRole.barber,
        joinDate: DateTime(2023, 3, 10),
        branchId: '1',
        hourlyRate: 22.0,
        specialties: ['Fade', 'Shave', 'Coloring'],
      ),
      StaffMember(
        id: '3',
        name: 'Sarah Manager',
        email: 'sarah@barbershop.com',
        phone: '+1234567892',
        role: StaffRole.branchManager,
        joinDate: DateTime(2022, 12, 1),
        branchId: '1',
        hourlyRate: 30.0,
      ),
    ];

    // Uncomment when API is ready:
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/staff${branchId != null ? '?branchId=$branchId' : ''}')
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => StaffMember.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load staff members');
      }
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(Duration(milliseconds: 500));
      return []; // or return mock data
    }
    */
  }

  static Future<List<Barber>> getBarbers({String? branchId}) async {
    final staff = await getStaffMembers(branchId: branchId);
    final barbers = staff.where((member) => member.role == StaffRole.barber).toList();

    // Convert to Barber with performance data
    return barbers.asMap().entries.map((entry) {
      final index = entry.key;
      final staffMember = entry.value;
      return Barber.fromStaffMember(
        staffMember,
        rating: 4.5 + (index * 0.1),
        totalAppointments: 100 + (index * 50),
        totalEarnings: 5000 + (index * 2500).toDouble(),
        specialties: staffMember.specialties ?? ['Haircut', 'Beard Trim'],
        servicesCount: {'Haircut': 70 + index * 20, 'Beard Trim': 30 + index * 10},
        lastActive: DateTime.now().subtract(Duration(hours: index * 2)),
      );
    }).toList();
  }

  static Future<List<BarberPerformance>> getBarberPerformance(String barberId, DateTime startDate, DateTime endDate) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Mock performance data
    return List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      return BarberPerformance(
        staffId: barberId,
        date: date,
        appointmentsCompleted: 5 + (index % 10),
        totalRevenue: 200.0 + (index * 10.0),
        tips: 20.0 + (index * 2.0),
        rating: 4.0 + (index % 5 * 0.2),
        servicesBreakdown: {'Haircut': 3, 'Beard Trim': 2},
      );
    });
  }

  static Future<String> generateStaffReport(StaffReportRequest request) async {
    await Future.delayed(Duration(seconds: 2));

    // Mock report generation
    return 'https://example.com/reports/staff/${request.fileName}';

    // Uncomment when API is ready:
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/staff'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['downloadUrl'];
      } else {
        throw Exception('Failed to generate report');
      }
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
    */
  }

  static Future<void> assignBranchManager(String branchId, String staffId) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Mock assignment - replace with actual API call
    print('Assigned staff $staffId as manager of branch $branchId');

    // Uncomment when API is ready:
    /*
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/branches/$branchId/manager'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'staffId': staffId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to assign manager');
      }
    } catch (e) {
      throw Exception('Failed to assign manager: $e');
    }
    */
  }

  // Shop Owner Dashboard Methods - Use mock data for now
  static Future<Subscription> getSubscriptionDetails() async {
    // Use mock data directly until your API is ready
    await Future.delayed(Duration(milliseconds: 500));
    return Subscription(
      planName: "Business Pro",
      price: 99.99,
      startDate: DateTime.now().subtract(Duration(days: 30)),
      endDate: DateTime.now().add(Duration(days: 60)),
      status: "Active",
      features: [
        "Up to 5 branches",
        "Advanced analytics",
        "PDF reports",
        "24/7 support"
      ],
    );

    // Uncomment this when your API is ready:
    /*
    try {
      final response = await http.get(Uri.parse('$baseUrl/subscription'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Subscription.fromJson(data);
      } else {
        throw Exception('Failed to load subscription');
      }
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(Duration(milliseconds: 500));
      return Subscription(
        planName: "Business Pro",
        price: 99.99,
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now().add(Duration(days: 60)),
        status: "Active",
        features: [
          "Up to 5 branches",
          "Advanced analytics",
          "PDF reports",
          "24/7 support"
        ],
      );
    }
    */
  }

  static Future<List<InventoryItem>> getLowStockItems() async {
    // Use mock data directly
    await Future.delayed(Duration(milliseconds: 500));
    return [
      InventoryItem(
        id: "1",
        name: "Wireless Earbuds",
        count: 3,
        category: "Electronics",
        minStockLevel: 10,
        price: 79.99,
        imageUrl: "",
      ),
      InventoryItem(
        id: "2",
        name: "Smart Watch",
        count: 2,
        category: "Electronics",
        minStockLevel: 5,
        price: 199.99,
        imageUrl: "",
      ),
      InventoryItem(
        id: "3",
        name: "Laptop",
        count: 1,
        category: "Electronics",
        minStockLevel: 3,
        price: 999.99,
        imageUrl: "",
      ),
    ];

    // Uncomment this when your API is ready:
    /*
    try {
      final response = await http.get(Uri.parse('$baseUrl/inventory/low-stock'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => InventoryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load inventory');
      }
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(Duration(milliseconds: 500));
      return [
        InventoryItem(
          id: "1",
          name: "Wireless Earbuds",
          count: 3,
          category: "Electronics",
          minStockLevel: 10,
          price: 79.99,
          imageUrl: "",
        ),
        InventoryItem(
          id: "2",
          name: "Smart Watch",
          count: 2,
          category: "Electronics",
          minStockLevel: 5,
          price: 199.99,
          imageUrl: "",
        ),
      ];
    }
    */
  }

  static Future<ProfitReport> getProfitReport() async {
    // Use mock data directly
    await Future.delayed(Duration(milliseconds: 500));
    return ProfitReport(
      monthlyData: List.generate(30, (index) => ProfitData(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        revenue: 1000 + (index * 50).toDouble(),
        profit: 200 + (index * 10).toDouble(),
        expenses: 800 + (index * 40).toDouble(),
      )),
      yearlyData: List.generate(12, (index) => ProfitData(
        date: DateTime(DateTime.now().year, index + 1),
        revenue: 12000 + (index * 1000).toDouble(),
        profit: 2400 + (index * 200).toDouble(),
        expenses: 9600 + (index * 800).toDouble(),
      )),
      totalRevenue: 45000,
      totalProfit: 9000,
      totalExpenses: 36000,
    );

    // Uncomment this when your API is ready:
    /*
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports/profit'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProfitReport.fromJson(data);
      } else {
        throw Exception('Failed to load profit report');
      }
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(Duration(milliseconds: 500));
      return ProfitReport(
        monthlyData: List.generate(30, (index) => ProfitData(
          date: DateTime.now().subtract(Duration(days: 29 - index)),
          revenue: 1000 + (index * 50).toDouble(),
          profit: 200 + (index * 10).toDouble(),
          expenses: 800 + (index * 40).toDouble(),
        )),
        yearlyData: List.generate(12, (index) => ProfitData(
          date: DateTime(DateTime.now().year, index + 1),
          revenue: 12000 + (index * 1000).toDouble(),
          profit: 2400 + (index * 200).toDouble(),
          expenses: 9600 + (index * 800).toDouble(),
        )),
        totalRevenue: 45000,
        totalProfit: 9000,
        totalExpenses: 36000,
      );
    }
    */
  }

  static Future<List<Offer>> getCurrentOffers() async {
    // Use mock data directly
    await Future.delayed(Duration(milliseconds: 500));
    return [
      Offer(
        id: "1",
        title: "Summer Sale",
        description: "20% off on all electronics",
        discountPercentage: 20,
        startDate: DateTime.now().subtract(Duration(days: 5)),
        endDate: DateTime.now().add(Duration(days: 10)),
        isActive: true,
        applicableProducts: ["Electronics", "Accessories"],
      ),
      Offer(
        id: "2",
        title: "New Customer Discount",
        description: "15% off for first-time customers",
        discountPercentage: 15,
        startDate: DateTime.now().subtract(Duration(days: 2)),
        endDate: DateTime.now().add(Duration(days: 30)),
        isActive: true,
        applicableProducts: ["All Products"],
      ),
    ];

    // Uncomment this when your API is ready:
    /*
    try {
      final response = await http.get(Uri.parse('$baseUrl/offers/active'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Offer.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load offers');
      }
    } catch (e) {
      // Fallback to mock data
      await Future.delayed(Duration(milliseconds: 500));
      return [
        Offer(
          id: "1",
          title: "Summer Sale",
          description: "20% off on all electronics",
          discountPercentage: 20,
          startDate: DateTime.now().subtract(Duration(days: 5)),
          endDate: DateTime.now().add(Duration(days: 10)),
          isActive: true,
          applicableProducts: ["Electronics"],
        ),
      ];
    }
    */
  }

  static Future<List<Branch>> getBranches() async {
    // Use your existing fetchBranches method
    final branches = await fetchBranches();

    // Convert to the enhanced Branch model with additional data
    return branches.map((branch) => Branch(
      id: branch.id,
      name: branch.name,
      address: branch.address,
      phone: branch.phone,
      isOpen: branch.isOpen,
      todayAppointments: branch.todayAppointments,
      todayRevenue: branch.todayRevenue,
      // Enhanced fields for shop owner dashboard
      manager: 'Branch Manager',
      monthlyRevenue: branch.todayRevenue * 30,
      totalSales: branch.todayAppointments * 30,
      lowStockItems: 3,
      email: '${branch.name.toLowerCase().replaceAll(' ', '_')}@company.com',
      openingDate: DateTime.now().subtract(Duration(days: 365)),
      totalEmployees: 5,
    )).toList();
  }

  // Your existing methods remain the same...
  static Future<Map<String, dynamic>> fetchHomeData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'stats': {
        'completed': 12,
        'pending': 3,
        'cancelled': 1,
      },
      'appointments': [
        {
          'id': 1,
          'customerName': 'John Smith',
          'service': 'Haircut',
          'time': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
          'status': 'confirmed',
        },
        {
          'id': 2,
          'customerName': 'Maria Garcia',
          'service': 'Beard Trim',
          'time': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
          'status': 'pending',
        },
      ],
      'earnings': [
        {
          'date': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
          'amount': 450.00,
          'appointments': 8,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'amount': 520.00,
          'appointments': 10,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'amount': 380.00,
          'appointments': 7,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'amount': 610.00,
          'appointments': 12,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'amount': 490.00,
          'appointments': 9,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'amount': 550.00,
          'appointments': 11,
        },
        {
          'date': DateTime.now().toIso8601String(),
          'amount': 320.00,
          'appointments': 6,
        },
      ],
    };
  }

  // Your original fetchBranches method
  static Future<List<Branch>> fetchBranches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Branch(
        id: 1,
        name: 'Main Branch',
        address: '123 Main St, City',
        phone: '+1234567890',
        isOpen: true,
        todayAppointments: 15,
        todayRevenue: 1250.00,
      ),
      Branch(
        id: 2,
        name: 'Downtown Branch',
        address: '456 Downtown Ave, City',
        phone: '+1234567891',
        isOpen: true,
        todayAppointments: 8,
        todayRevenue: 800.00,
      ),
      Branch(
        id: 3,
        name: 'Westside Branch',
        address: '789 West St, City',
        phone: '+1234567892',
        isOpen: false,
        todayAppointments: 0,
        todayRevenue: 0.00,
      ),
    ];
  }

  static Future<List<PendingConfirmation>> fetchPendingConfirmations() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    // Replace with actual API call
    return [
      PendingConfirmation(
        id: 1,
        customerName: 'John Smith',
        service: 'Haircut & Beard',
        amount: 45.00,
        appointmentTime: DateTime.now().add(const Duration(hours: 1)),
        notes: 'Cash payment upon arrival',
      ),
      PendingConfirmation(
        id: 2,
        customerName: 'Maria Garcia',
        service: 'Hair Color',
        amount: 85.00,
        appointmentTime: DateTime.now().add(const Duration(hours: 2)),
      ),
    ];
  }

  static Future<WorkingHours> fetchTodayWorkingHours() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    // Replace with actual API call
    return WorkingHours(
      date: DateTime.now(),
      scheduledStart: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0),
      scheduledEnd: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 0),
      actualStart: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 15),
      actualEnd: null,
      isWorking: true,
    );
  }

  static Future<void> confirmCashPayment(int appointmentId) async {
    // Implement actual API call to confirm cash payment
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> startWorkingHours() async {
    // Implement actual API call to start working hours
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static Future<void> endWorkingHours() async {
    // Implement actual API call to end working hours
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
