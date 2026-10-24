import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Models/staff/expert.dart';
import 'package:na3eeman/Models/staff/staff_member.dart';
import 'package:na3eeman/Services/enums/staff_role.dart';

// Characterization tests for the merged StaffMember / Expert models.
// The `Models/staff/` variants now absorb the payload shapes previously
// handled by the deleted `Models/salon/staff_member_model.dart` and
// `Models/salon/expert_model.dart`, so these pin down tolerance for BOTH
// key styles plus round-trip behavior.
void main() {
  group('StaffMember.fromJson', () {
    test('parses the business_service (hired_at/expert) shape', () {
      final member = StaffMember.fromJson({
        'id': 7,
        'expert': 42,
        'expert_name': 'Sara',
        'expert_email': 'sara@example.com',
        'phone': '+966500000000',
        'role': 'receptionist',
        'hired_at': '2024-01-15T09:00:00.000',
        'profile_image': 'https://example.com/pic.png',
        'salon': 3,
        'is_active': false,
        'hourly_rate': 120,
        'specialties': ['Haircut', 'Color'],
        'performance_metrics': {'rating': 4.5},
      });

      expect(member.id, '7');
      expect(member.userId, 42);
      expect(member.name, 'Sara');
      expect(member.email, 'sara@example.com');
      expect(member.phone, '+966500000000');
      expect(member.role, StaffRole.receptionist);
      expect(member.roleString, 'Receptionist');
      expect(member.joinDate, DateTime.parse('2024-01-15T09:00:00.000'));
      expect(member.profileImage, 'https://example.com/pic.png');
      expect(member.salonId, 3);
      expect(member.isActive, isFalse);
      expect(member.hourlyRate, 120.0);
      expect(member.specialties, ['Haircut', 'Color']);
      expect(member.performanceMetrics, {'rating': 4.5});
      expect(member.status, isNull);
      expect(member.statusNote, isNull);
    });

    test('parses the staff_provider (join_date/user_id) shape', () {
      final member = StaffMember.fromJson({
        'id': 'abc-1',
        'user_id': 11,
        'name': 'Omar',
        'email': 'omar@example.com',
        'phone': '+966511111111',
        'role': 'MANAGER',
        'join_date': '2023-06-01T08:00:00.000',
        'salon_id': 9,
        'hourly_rate': 85.5,
        'status': 'BUSY',
        'status_note': 'With a client',
      });

      expect(member.id, 'abc-1');
      expect(member.userId, 11);
      expect(member.name, 'Omar');
      expect(member.role, StaffRole.manager);
      expect(member.joinDate, DateTime.parse('2023-06-01T08:00:00.000'));
      expect(member.salonId, 9);
      expect(member.isActive, isTrue);
      expect(member.hourlyRate, 85.5);
      expect(member.specialties, isEmpty);
      expect(member.performanceMetrics, isEmpty);
      expect(member.status, 'BUSY');
      expect(member.statusNote, 'With a client');
    });

    test('coerces string ids and falls back to defaults on sparse input', () {
      final member = StaffMember.fromJson({'id': 5});

      expect(member.id, '5');
      expect(member.userId, 0);
      expect(member.name, '');
      expect(member.email, '');
      expect(member.phone, '');
      expect(member.role, StaffRole.expert);
      expect(member.salonId, 0);
      expect(member.isActive, isTrue);
      expect(member.hourlyRate, 0.0);
      expect(member.specialties, isEmpty);
      expect(member.performanceMetrics, isEmpty);
    });

    test(
      'prefers name/email over expert_name/expert_email when both exist',
      () {
        final member = StaffMember.fromJson({
          'id': 1,
          'user_id': 2,
          'expert': 3,
          'name': 'Primary',
          'expert_name': 'Fallback',
          'email': 'primary@example.com',
          'expert_email': 'fallback@example.com',
        });

        expect(member.userId, 2);
        expect(member.name, 'Primary');
        expect(member.email, 'primary@example.com');
      },
    );

    test('toJson round-trips through fromJson', () {
      final original = StaffMember.fromJson({
        'id': 7,
        'user_id': 42,
        'name': 'Sara',
        'email': 'sara@example.com',
        'phone': '+966500000000',
        'role': 'OWNER_EXPERT',
        'join_date': '2024-01-15T09:00:00.000',
        'salon_id': 3,
        'is_active': true,
        'hourly_rate': 120.0,
        'specialties': ['Haircut'],
        'performance_metrics': {'rating': 4.5},
        'status': 'AVAILABLE',
        'status_note': null,
      });

      final restored = StaffMember.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.phone, original.phone);
      expect(restored.role, original.role);
      expect(restored.joinDate, original.joinDate);
      expect(restored.salonId, original.salonId);
      expect(restored.isActive, original.isActive);
      expect(restored.hourlyRate, original.hourlyRate);
      expect(restored.specialties, original.specialties);
      expect(restored.performanceMetrics, original.performanceMetrics);
      expect(restored.status, original.status);
      expect(restored.statusNote, original.statusNote);
    });

    test('copyWith overrides only the given fields', () {
      final original = StaffMember.fromJson({
        'id': 1,
        'user_id': 2,
        'name': 'Sara',
        'salon_id': 3,
        'status': 'BUSY',
      });

      final copy = original.copyWith(name: 'Omar', status: 'AVAILABLE');

      expect(copy.name, 'Omar');
      expect(copy.status, 'AVAILABLE');
      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.salonId, original.salonId);
    });
  });

  group('Expert.fromJson', () {
    test('parses the business_service (expert_*) shape', () {
      final expert = Expert.fromJson({
        'id': 3,
        'expert': 21,
        'expert_name': 'Layla',
        'expert_email': 'layla@example.com',
        'hired_at': '2022-03-10T10:00:00.000',
        'salon': 4,
        'hourly_rate': 150,
        'rating': 4.8,
        'total_appointments': 320,
        'total_earnings': 48000,
        'specialties': ['Bridal'],
        'services_count': {'Haircut': 10},
        'last_active': '2026-10-20T14:00:00.000',
      });

      expect(expert.id, '3');
      expect(expert.userId, 21);
      expect(expert.name, 'Layla');
      expect(expert.email, 'layla@example.com');
      expect(expert.role, StaffRole.expert);
      expect(expert.salonId, 4);
      expect(expert.hourlyRate, 150.0);
      expect(expert.rating, 4.8);
      expect(expert.totalAppointments, 320);
      expect(expert.totalEarnings, 48000.0);
      expect(expert.specialties, ['Bridal']);
      expect(expert.servicesCount, {'Haircut': 10});
      expect(expert.lastActive, DateTime.parse('2026-10-20T14:00:00.000'));
      expect(expert.expertProfile, isNull);
    });

    test('parses the staff_provider (join_date/user_id) shape', () {
      final expert = Expert.fromJson({
        'id': 'e-9',
        'user_id': 12,
        'name': 'Huda',
        'email': 'huda@example.com',
        'join_date': '2021-05-01T09:00:00.000',
        'salon_id': 6,
        'status': 'BREAK',
      });

      expect(expert.id, 'e-9');
      expect(expert.userId, 12);
      expect(expert.name, 'Huda');
      expect(expert.joinDate, DateTime.parse('2021-05-01T09:00:00.000'));
      expect(expert.salonId, 6);
      expect(expert.rating, 0.0);
      expect(expert.totalAppointments, 0);
      expect(expert.totalEarnings, 0.0);
      expect(expert.specialties, isEmpty);
      expect(expert.servicesCount, isEmpty);
      expect(expert.status, 'BREAK');
      expect(expert.lastActive, isNull);
    });

    test('builds performanceMetrics from expert stats', () {
      final expert = Expert.fromJson({
        'id': 1,
        'expert': 2,
        'rating': 4.2,
        'total_appointments': 50,
        'total_earnings': 7500,
        'services_count': {'Haircut': 5},
      });

      expect(expert.performanceMetrics['rating'], 4.2);
      expect(expert.performanceMetrics['totalAppointments'], 50);
      expect(expert.performanceMetrics['totalEarnings'], 7500.0);
      expect(expert.performanceMetrics['servicesCount'], {'Haircut': 5});
    });

    test('averageServiceTime is 0 with no services counted', () {
      final expert = Expert.fromJson({
        'id': 1,
        'expert': 2,
        'total_appointments': 12,
      });

      expect(expert.averageServiceTime, 0);
    });

    test('toJson round-trips through fromJson', () {
      final original = Expert.fromJson({
        'id': 3,
        'expert': 21,
        'expert_name': 'Layla',
        'expert_email': 'layla@example.com',
        'hired_at': '2022-03-10T10:00:00.000',
        'salon': 4,
        'hourly_rate': 150.0,
        'rating': 4.8,
        'total_appointments': 320,
        'total_earnings': 48000.0,
        'specialties': ['Bridal'],
        'services_count': {'Haircut': 10},
        'last_active': '2026-10-20T14:00:00.000',
      });

      final restored = Expert.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.joinDate, original.joinDate);
      expect(restored.salonId, original.salonId);
      expect(restored.hourlyRate, original.hourlyRate);
      expect(restored.rating, original.rating);
      expect(restored.totalAppointments, original.totalAppointments);
      expect(restored.totalEarnings, original.totalEarnings);
      expect(restored.specialties, original.specialties);
      expect(restored.servicesCount, original.servicesCount);
      expect(restored.lastActive, original.lastActive);
    });
  });

  group('SalonExpert.fromJson', () {
    test('parses the junction shape', () {
      final junction = SalonExpert.fromJson({
        'id': 1,
        'expert': 21,
        'expert_name': 'Layla',
        'expert_email': 'layla@example.com',
        'salon': 4,
        'is_active': true,
        'hired_at': '2022-03-10T10:00:00.000',
      });

      expect(junction.id, 1);
      expect(junction.expertId, 21);
      expect(junction.expertName, 'Layla');
      expect(junction.expertEmail, 'layla@example.com');
      expect(junction.salonId, 4);
      expect(junction.isActive, isTrue);
      expect(junction.hiredAt, DateTime.parse('2022-03-10T10:00:00.000'));
    });
  });
}
