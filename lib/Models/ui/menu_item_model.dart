import 'package:flutter/material.dart';
import '../../Packages/Core/constants/app_roles.dart';
import '../../core/enums/app_enums.dart';

class MenuItem {
  final String title;
  final IconData? icon;
  final String? assetIcon;
  final int delay;
  final VoidCallback onTap;
  final String? route;
  final bool? requiresAuth;
  final List<UserRole>? requiredRoles;
  final List<MenuItem>? children;

  MenuItem({
    required this.title,
    this.icon,
    this.assetIcon,
    required this.delay,
    required this.onTap,
    this.route,
    this.requiresAuth = false,
    this.requiredRoles,
    this.children,
  }) : assert(icon != null || assetIcon != null, 'Either icon or assetIcon must be provided');

  bool isAccessible(UserRole userRole) {
    if (!requiresAuth!) return true;
    if (requiredRoles == null || requiredRoles!.isEmpty) return true;
    return requiredRoles!.contains(userRole);
  }
}

class PendingConfirmation {
  final int id;
  final String customerName;
  final String service;
  final double amount;
  final DateTime appointmentTime;
  final String? notes;
  final int appointmentId;
  final int? expertId;
  final int salonId;

  PendingConfirmation({
    required this.id,
    required this.customerName,
    required this.service,
    required this.amount,
    required this.appointmentTime,
    this.notes,
    required this.appointmentId,
    this.expertId,
    required this.salonId,
  });

  factory PendingConfirmation.fromJson(Map<String, dynamic> json) {
    return PendingConfirmation(
      id: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      service: json['service'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      appointmentTime: DateTime.parse(json['appointment_time']),
      notes: json['notes'],
      appointmentId: json['appointment'] as int,
      expertId: json['expert'] as int?,
      salonId: json['salon'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'service': service,
      'amount': amount,
      'appointment_time': appointmentTime.toIso8601String(),
      'notes': notes,
      'appointment': appointmentId,
      'expert': expertId,
      'salon': salonId,
    };
  }
}

