import '../../Services/enums/appointment_status.dart';
import '../../Services/enums/attendee_type.dart';
import '../../Services/enums/recurrence_type.dart';

class SalonAppointment {
  final String id;
  final int customerId;
  final int salonId;
  final int? barberId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime? arrivalTime;
  final AppointmentStatus status;
  final bool isFree;
  final String? bookingGroupId;
  final int? requestedStyleId;
  final AttendeeType attendeeType;
  final RecurrenceType? recurrence;
  final DateTime? recurrenceEndDate;
  final DateTime createdAt;
  final List<AppointmentServiceModel> services;
  final Payment? payment;
  final bool isGift;
  final String? giftReceiverName;
  final String? giftReceiverPhone;
  final String? giftReceiverGender;
  final String? giftRelation;
  final String? giftMessage;
  final String? giftLink;
  final double? totalAmount;
  final double? depositAmount;

  String get paymentStatus => payment?.status ?? 'PENDING';

  SalonAppointment({
    required this.id,
    required this.customerId,
    required this.salonId,
    this.barberId,
    required this.startTime,
    required this.endTime,
    this.arrivalTime,
    required this.status,
    this.isFree = false,
    this.bookingGroupId,
    this.requestedStyleId,
    this.attendeeType = AttendeeType.self,
    this.recurrence,
    this.recurrenceEndDate,
    required this.createdAt,
    required this.services,
    this.payment,
    this.isGift = false,
    this.giftReceiverName,
    this.giftReceiverPhone,
    this.giftReceiverGender,
    this.giftRelation,
    this.giftMessage,
    this.giftLink,
    this.totalAmount,
    this.depositAmount,
  });

  factory SalonAppointment.fromJson(Map<String, dynamic> json) {
    return SalonAppointment(
      id: json['id']?.toString() ?? '',
      customerId: json['customer'] as int? ?? 0,
      salonId: json['salon'] as int? ?? 0,
      barberId: json['barber'] as int?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'] as String)
          : null,
      status: AppointmentStatusExtension.fromString(json['status'] as String? ?? 'SCHEDULED'),
      isFree: json['is_free'] as bool? ?? false,
      bookingGroupId: json['booking_group_id']?.toString(),
      requestedStyleId: json['style'] as int?,
      attendeeType: AttendeeTypeExtension.fromString(json['attendee_type'] as String? ?? 'SELF'),
      recurrence: json['recurrence'] != null
          ? RecurrenceTypeExtension.fromString(json['recurrence'] as String)
          : null,
      recurrenceEndDate: json['recurrence_end_date'] != null
          ? DateTime.parse(json['recurrence_end_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      services: json['services'] != null
          ? (json['services'] as List).map((s) => AppointmentServiceModel.fromJson(s)).toList()
          : [],
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null,
      isGift: json['is_gift'] as bool? ?? false,
      giftReceiverName: json['gift_receiver_name'] as String?,
      giftReceiverPhone: json['gift_receiver_phone'] as String?,
      giftReceiverGender: json['gift_receiver_gender'] as String?,
      giftRelation: json['gift_relation'] as String?,
      giftMessage: json['gift_message'] as String?,
      giftLink: json['gift_link'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salon': salonId,
      'barber': barberId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'attendee_type': attendeeType.value,
      'recurrence': recurrence?.value,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
      'services': services.map((s) => s.toJson()).toList(),
      'style': requestedStyleId,
      'is_gift': isGift,
      'gift_receiver_name': giftReceiverName,
      'gift_receiver_phone': giftReceiverPhone,
      'gift_receiver_gender': giftReceiverGender,
      'gift_relation': giftRelation,
      'gift_message': giftMessage,
      'total_amount': totalAmount,
      'deposit_amount': depositAmount,
    };
  }
}

class AppointmentServiceModel {
  final String serviceType; // 'OPTION', 'PACKAGE', 'PRODUCT'
  final int? optionId;
  final int? packageId;
  final int? productId;
  final String name; // Service or product name
  final int quantity;

  AppointmentServiceModel({
    required this.serviceType,
    this.optionId,
    this.packageId,
    this.productId,
    this.name = 'Service',
    this.quantity = 1,
  });

  factory AppointmentServiceModel.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceModel(
      serviceType: json['service_type'] as String,
      optionId: json['option'] as int?,
      packageId: json['package'] as int?,
      productId: json['product'] as int?,
      name: json['service_name'] ?? json['name'] ?? 'Service',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_type': serviceType,
      'option': optionId,
      'package': packageId,
      'product': productId,
      'quantity': quantity,
    };
  }
}

class Payment {
  final String id;
  final String appointmentId;
  final double amount;
  final String method; // 'CASH', 'VISA', 'CLIQ', 'SUBSCRIPTION', 'POINTS', 'VOUCHER'
  final String status; // 'PENDING', 'PAID', 'FAILED', 'REFUNDED', 'REPORTED'
  final String? transactionId;
  final bool isDeposit;
  final DateTime? paidAt;
  final DateTime? reportedAt;

  Payment({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.isDeposit = false,
    this.paidAt,
    this.reportedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      appointmentId: json['appointment']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? 'CASH',
      status: json['status'] as String? ?? 'PENDING',
      transactionId: json['transaction_id'] as String?,
      isDeposit: json['is_deposit'] as bool? ?? false,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      reportedAt: json['reported_at'] != null
          ? DateTime.parse(json['reported_at'] as String)
          : null,
    );
  }
}
