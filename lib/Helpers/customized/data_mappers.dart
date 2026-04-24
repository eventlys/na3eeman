import 'package:na3eeman/Services/enums/gender.dart';
import 'package:na3eeman/core/enums/app_enums.dart';

import '../../Models/appointments/salon_appointments_model.dart';
import '../../Models/auth/user_model.dart';
import '../../Services/enums/appointment_status.dart';
import '../../Services/enums/attendee_type.dart';
import '../../Services/enums/recurrence_type.dart';

class DataMappers {
  // User Mappers
  static Map<String, dynamic> userToJson(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'username': user.username,
      'phone': user.phone,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'profile_pic': user.profilePic,
      'role': user.role.value,
      'gender': user.gender.value,
      'location': user.location,
      'lat': user.lat,
      'lng': user.lng,
      'is_email_verified': user.isEmailVerified,
      'is_phone_verified': user.isPhoneVerified,
      'is_deleted': user.isDeleted,
      'deleted_at': user.deletedAt?.toIso8601String(),
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
      'is_active': user.isActive,
      'is_staff': user.isStaff,
      'is_superuser': user.isSuperuser,
    };
  }

  static User userFromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      phone: json['phone']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      profilePic: json['profile_pic']?.toString(),
      role: UserRoleExtension.fromString(json['role']?.toString() ?? 'CUSTOMER'),
      gender: GenderExtension.fromString(json['gender']?.toString() ?? 'MALE'),
      location: json['location']?.toString() ?? 'amman, Jordan',
      lat: (json['lat'] as num?)?.toDouble() ?? 31.963158,
      lng: (json['lng'] as num?)?.toDouble() ?? 35.930359,
      isEmailVerified: (json['is_email_verified'] ?? json['vrfid_email']) as bool? ?? false,
      isPhoneVerified: (json['is_phone_verified'] ?? json['vrfid_phone']) as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at']?.toString() ?? '')
          : null,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] as bool? ?? true,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
    );
  }

  // Salon Mappers - Using Map structure since Salon class might not exist
  static Map<String, dynamic> salonToJson(Map<String, dynamic> salon) {
    return {
      'id': salon['id'],
      'title': salon['title'],
      'workingHours': salon['workingHours'],
      'salonLocation': salon['salonLocation'],
      'salonRating': salon['salonRating'],
      'profilePicture': salon['profilePicture'],
    };
  }

  static Map<String, dynamic> salonFromJson(Map<String, dynamic> json) {
    return {
      'id': json['id']?.toString() ?? '',
      'title': json['title']?.toString() ?? '',
      'workingHours': json['workingHours']?.toString() ?? '',
      'salonLocation': json['salonLocation']?.toString() ?? '',
      'salonRating': _parseRating(json['salonRating']),
      'profilePicture': json['profilePicture']?.toString() ?? '',
    };
  }

  // Appointment Mappers
  static Map<String, dynamic> appointmentToJson(SalonAppointment appointment) {
    return {
      'id': appointment.id,
      'customer': appointment.customerId,
      'salon': appointment.salonId,
      'barber': appointment.barberId,
      'start_time': appointment.startTime.toIso8601String(),
      'end_time': appointment.endTime.toIso8601String(),
      'arrival_time': appointment.arrivalTime?.toIso8601String(),
      'status': appointment.status.value,
      'is_free': appointment.isFree,
      'booking_group_id': appointment.bookingGroupId,
      'style': appointment.requestedStyleId,
      'attendee_type': appointment.attendeeType.value,
      'recurrence': appointment.recurrence?.value,
      'recurrence_end_date': appointment.recurrenceEndDate?.toIso8601String(),
      'created_at': appointment.createdAt.toIso8601String(),
      'services': appointment.services.map((service) => service.toJson()).toList(),
      'payment': appointment.payment != null ? _paymentToJson(appointment.payment!) : null,
    };
  }

  static SalonAppointment appointmentFromJson(Map<String, dynamic> json) {
    return SalonAppointment(
      id: json['id']?.toString() ?? '',
      customerId: (json['customer'] as num?)?.toInt() ?? 0,
      salonId: (json['salon'] as num?)?.toInt() ?? 0,
      barberId: (json['barber'] as num?)?.toInt(),
      startTime: DateTime.parse(json['start_time']?.toString() ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['end_time']?.toString() ?? DateTime.now().toIso8601String()),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.tryParse(json['arrival_time']?.toString() ?? '')
          : null,
      status: AppointmentStatusExtension.fromString(json['status']?.toString() ?? 'SCHEDULED'),
      isFree: json['is_free'] as bool? ?? false,
      bookingGroupId: json['booking_group_id']?.toString(),
      requestedStyleId: (json['style'] as num?)?.toInt(),
      attendeeType: AttendeeTypeExtension.fromString(json['attendee_type']?.toString() ?? 'SELF'),
      recurrence: json['recurrence'] != null
          ? RecurrenceTypeExtension.fromString(json['recurrence']?.toString() ?? '')
          : null,
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.tryParse(json['recurrence_end_date']?.toString() ?? '')
          : null,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      services: json['services'] != null
          ? (json['services'] as List).map((s) => AppointmentServiceModel.fromJson(s)).toList()
          : [],
      payment: json['payment'] != null
          ? _paymentFromJson(json['payment'])
          : null,
    );
  }

  // Helper methods for Payment
  static Map<String, dynamic> _paymentToJson(Payment payment) {
    return {
      'id': payment.id,
      'appointment': payment.appointmentId,
      'amount': payment.amount,
      'method': payment.method,
      'status': payment.status,
      'paid_at': payment.paidAt?.toIso8601String(),
      'reported_at': payment.reportedAt?.toIso8601String(),
    };
  }

  static Payment _paymentFromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      appointmentId: json['appointment']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method']?.toString() ?? 'CASH',
      status: json['status']?.toString() ?? 'PENDING',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at']?.toString() ?? '')
          : null,
      reportedAt: json['reported_at'] != null
          ? DateTime.tryParse(json['reported_at']?.toString() ?? '')
          : null,
    );
  }

  // Helper methods for type conversion
  static double _parseRating(dynamic rating) {
    if (rating == null) return 0.0;
    if (rating is double) return rating;
    if (rating is int) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0.0;
    return 0.0;
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }
}
