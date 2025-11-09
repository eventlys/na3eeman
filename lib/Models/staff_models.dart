import 'report_model.dart';
import 'user_model.dart';


enum StaffRole {
  owner,
  subOwner,
  branchManager,
  barber,
  assistant,
  receptionist,
  cleaner
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String phone;
  final StaffRole role;
  final DateTime joinDate;
  final String? profileImage;
  final String? branchId;
  final bool isActive;
  final double? hourlyRate;
  final List<String>? specialties;
  final Map<String, dynamic>? performanceMetrics;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.joinDate,
    this.profileImage,
    this.branchId,
    this.isActive = true,
    this.hourlyRate,
    this.specialties,
    this.performanceMetrics,
  });

  String get roleString {
    switch (role) {
      case StaffRole.owner: return 'Owner';
      case StaffRole.subOwner: return 'Sub Owner';
      case StaffRole.branchManager: return 'Branch Manager';
      case StaffRole.barber: return 'Barber';
      case StaffRole.assistant: return 'Assistant';
      case StaffRole.receptionist: return 'Receptionist';
      case StaffRole.cleaner: return 'Cleaner';
    }
  }

  factory StaffMember.fromUser(User user, {StaffRole? role, String? branchId}) {
    return StaffMember(
      id: user.id.toString(),
      name: user.name,
      email: user.email,
      phone: '', // You might want to add phone to your User model
      role: role ?? StaffRole.barber,
      joinDate: DateTime.now(),
      profileImage: user.profilePic,
      branchId: branchId,
      isActive: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString(),
      'joinDate': joinDate.toIso8601String(),
      'profileImage': profileImage,
      'branchId': branchId,
      'isActive': isActive,
      'hourlyRate': hourlyRate,
      'specialties': specialties,
      'performanceMetrics': performanceMetrics,
    };
  }
}

class BarberPerformance {
  final String staffId;
  final DateTime date;
  final int appointmentsCompleted;
  final double totalRevenue;
  final double tips;
  final double rating;
  final Map<String, int> servicesBreakdown;

  BarberPerformance({
    required this.staffId,
    required this.date,
    required this.appointmentsCompleted,
    required this.totalRevenue,
    required this.tips,
    required this.rating,
    required this.servicesBreakdown,
  });

  double get earnings => totalRevenue + tips;
}

enum StaffReportType {
  daily,
  weekly,
  monthly,
  annually,
  performance,
  payroll,
  attendance
}

class StaffReportRequest {
  final ReportTime time;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final String? staffId;
  final String fileName;

  StaffReportRequest({
    required this.time,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.staffId,
    required this.fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'branchId': branchId,
      'staffId': staffId,
      'fileName': fileName,
    };
  }
}
