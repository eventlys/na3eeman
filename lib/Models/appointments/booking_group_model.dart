class BookingGroup {
  final String id;
  final int organizerId;
  final String organizerName;
  final DateTime createdAt;
  final bool isRecurring;
  final List<AppointmentReference> appointments;
  final int? salonId;

  BookingGroup({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.createdAt,
    required this.isRecurring,
    required this.appointments,
    this.salonId,
  });

  factory BookingGroup.fromJson(Map<String, dynamic> json) {
    return BookingGroup(
      id: json['id']?.toString() ?? '',
      organizerId: json['organizer'] as int,
      organizerName: json['organizer_name'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isRecurring: json['is_recurring'] as bool? ?? false,
      appointments: List<AppointmentReference>.from(
        (json['appointments'] ?? []).map(
          (x) => AppointmentReference.fromJson(x),
        ),
      ),
      salonId: json['salon'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer': organizerId,
      'organizer_name': organizerName,
      'created_at': createdAt.toIso8601String(),
      'is_recurring': isRecurring,
      'appointments': appointments.map((x) => x.toJson()).toList(),
      'salon': salonId,
    };
  }

  int get totalAppointments => appointments.length;

  double get totalAmount {
    return appointments.fold(
      0.0,
      (sum, appointment) => sum + appointment.amount,
    );
  }

  DateTime? get nextAppointment {
    final now = DateTime.now();
    final upcoming = appointments
        .where((a) => a.startTime.isAfter(now))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.first.startTime;
  }
}

class AppointmentReference {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final double amount;
  final String? expertName;
  final int? expertId;
  final List<String> services;

  AppointmentReference({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.amount,
    this.expertName,
    this.expertId,
    required this.services,
  });

  factory AppointmentReference.fromJson(Map<String, dynamic> json) {
    return AppointmentReference(
      id: json['id']?.toString() ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: json['status'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expertName: json['expert_name'] as String?,
      expertId: json['expert'] as int?,
      services: List<String>.from(json['services'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
      'amount': amount,
      'expert_name': expertName,
      'expert': expertId,
      'services': services,
    };
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
}
