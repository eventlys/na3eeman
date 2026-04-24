// import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_roles.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/auth/user_model.dart';
import '../../Models/auth/barber_profile.dart';
import '../../Models/salon/staff_member_model.dart';
import '../../Models/salon/barber_model.dart';
import '../../Services/enums/staff_role.dart';
import '../../core/enums/app_enums.dart';
import '../../Services/enums/gender.dart';

class StaffProvider extends BaseProvider {
  List<StaffMember> _staff = [];
  List<Barber> _barbers = [];
  AuthProvider? _authProvider;
  StaffMember? _selectedStaff;

  // Getters
  List<StaffMember> get staff => _staff;
  List<Barber> get barbers => _barbers;
  StaffMember? get selectedStaff => _selectedStaff;

  List<StaffMember> get manageableStaff {
    if (_authProvider?.isOwner != true) return [];
    return _staff
        .where(
          (member) =>
              member.salonId == _authProvider?.ownerProfile?.barberProfileId,
        )
        .toList();
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true &&
        _authProvider?.isOwner == true) {
      loadStaffData();
    }
  }

  Future<void> loadStaffData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([loadStaff(), loadBarbers()]);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadStaff() async {
    await Future.delayed(const Duration(seconds: 1));
    _staff = [
      StaffMember(
        id: '1',
        userId: 2,
        name: 'Mike Johnson',
        email: 'mike@barbershop.com',
        phone: '+962791234567',
        role: StaffRole.employee,
        joinDate: DateTime.now().subtract(const Duration(days: 365)),
        profileImage: 'https://example.com/mike.jpg',
        salonId: 1,
        isActive: true,
        hourlyRate: 25.0,
        specialties: ['Haircuts', 'Beard Trims', 'Shaves'],
        performanceMetrics: {
          'rating': 4.5,
          'totalAppointments': 150,
          'totalEarnings': 3750.0,
        },
      ),
    ];
  }

  Future<void> loadBarbers() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _barbers = [
      Barber.fromUserAndProfile(
        user: User(
          id: 2,
          email: 'mike@barbershop.com',
          username: 'mike_barber',
          firstName: 'Mike',
          lastName: 'Johnson',
          role: UserRole.employee,
          gender: Gender.male,
          location: 'Amman, Jordan',
          lat: 31.963158,
          lng: 35.930359,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
        ),
        profile: BarberProfile(
          id: 1,
          barberId: 2,
          bio: 'Professional barber with 5 years experience',
          specialties: 'Haircuts, Beard Trims, Shaves, Styling',
          contactPhone: '+962791234567',
          hasAccess: true,
          avgRating: 4.5,
        ),
        rating: 4.5,
        totalAppointments: 150,
        totalEarnings: 3750.0,
        specialties: ['Haircuts', 'Beard Trims', 'Shaves'],
        servicesCount: {'Haircut': 80, 'Beard Trim': 45, 'Shave': 25},
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        hourlyRate: 25.0,
        salonId: 1,
      ),
    ];
  }

  void selectStaff(StaffMember? staff) {
    _selectedStaff = staff;
    notifyListeners();
  }
}
