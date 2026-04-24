import 'package:flutter/material.dart';
import 'salon_service_model.dart';

class SalonScheduleSlot {
  final DateTime date;
  final TimeOfDay time;
  final SalonService salonService;
  final bool isAvailable;
  final int? barberId;
  final int salonId;

  const SalonScheduleSlot({
    required this.date,
    required this.time,
    required this.salonService,
    this.isAvailable = true,
    this.barberId,
    required this.salonId,
  });

  DateTime get dateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String get formattedTime {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'service': salonService.toMap(),
      'is_available': isAvailable,
      'barber': barberId,
      'salon': salonId,
    };
  }

  factory SalonScheduleSlot.fromJson(Map<String, dynamic> json) {
    return SalonScheduleSlot(
      date: DateTime.parse(json['date']),
      time: _parseTime(json['time']),
      salonService: SalonService.fromMap(Map<String, dynamic>.from(json['service'])),
      isAvailable: json['is_available'] ?? true,
      barberId: json['barber'] as int?,
      salonId: json['salon'] as int,
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay(hour: 9, minute: 0);
    }
  }
}

class SalonScheduleData {
  final Map<String, dynamic> data;
  final List<SalonService> salonServices;
  final List<SalonScheduleSlot> availableSlots;
  final int salonId;
  final String openingTime;
  final String closingTime;
  final List<String> workingDays;

  const SalonScheduleData({
    required this.data,
    required this.salonServices,
    required this.availableSlots,
    required this.salonId,
    required this.openingTime,
    required this.closingTime,
    required this.workingDays,
  });

  factory SalonScheduleData.fromMap(Map<String, dynamic> map) {
    final salonServices = (map['services'] as List<dynamic>? ?? [])
        .map((service) => SalonService.fromMap(service as Map<String, dynamic>))
        .toList();

    final availableSlots = (map['available_slots'] as List<dynamic>? ?? [])
        .map((slot) => SalonScheduleSlot.fromJson(slot as Map<String, dynamic>))
        .toList();

    return SalonScheduleData(
      data: map,
      salonServices: salonServices,
      availableSlots: availableSlots,
      salonId: map['salon_id'] as int? ?? 0,
      openingTime: map['opening_time'] as String? ?? '09:00',
      closingTime: map['closing_time'] as String? ?? '18:00',
      workingDays: List<String>.from(map['working_days'] ?? ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'services': salonServices.map((service) => service.toMap()).toList(),
      'available_slots': availableSlots.map((slot) => slot.toJson()).toList(),
      'salon_id': salonId,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'working_days': workingDays,
    };
  }

  List<SalonScheduleSlot> getSlotsForDate(DateTime date) {
    return availableSlots.where((slot) =>
      slot.date.year == date.year &&
      slot.date.month == date.month &&
      slot.date.day == date.day
    ).toList();
  }

  List<SalonScheduleSlot> getAvailableSlotsForDate(DateTime date) {
    return getSlotsForDate(date).where((slot) => slot.isAvailable).toList();
  }

  bool isSalonOpenOnDay(String day) {
    return workingDays.contains(day);
  }

  TimeOfDay get parsedOpeningTime {
    return SalonScheduleSlot._parseTime(openingTime);
  }

  TimeOfDay get parsedClosingTime {
    return SalonScheduleSlot._parseTime(closingTime);
  }
}

class BarberWorkingHours {
  final int barberId;
  final String barberName;
  final List<String> workingDays;
  final String startTime;
  final String endTime;
  final String? breakStart;
  final String? breakEnd;
  final bool isAvailable;

  BarberWorkingHours({
    required this.barberId,
    required this.barberName,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    this.breakStart,
    this.breakEnd,
    this.isAvailable = true,
  });

  factory BarberWorkingHours.fromJson(Map<String, dynamic> json) {
    return BarberWorkingHours(
      barberId: json['barber_id'] as int,
      barberName: json['barber_name'] as String,
      workingDays: List<String>.from(json['working_days'] ?? []),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      breakStart: json['break_start'] as String?,
      breakEnd: json['break_end'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barber_id': barberId,
      'barber_name': barberName,
      'working_days': workingDays,
      'start_time': startTime,
      'end_time': endTime,
      'break_start': breakStart,
      'break_end': breakEnd,
      'is_available': isAvailable,
    };
  }
}
