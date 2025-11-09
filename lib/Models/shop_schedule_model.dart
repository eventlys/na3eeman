import 'package:flutter/material.dart';
import 'shop_service_model.dart';

class ShopScheduleSlot {
  final DateTime date;
  final TimeOfDay time;
  final ShopService shopService;

  const ShopScheduleSlot({
    required this.date,
    required this.time,
    required this.shopService,
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
}

class ShopScheduleData {
  final Map<String, dynamic> data;
  final List<ShopService> shopServices;

  const ShopScheduleData({
    required this.data,
    required this.shopServices,
  });

  factory ShopScheduleData.fromMap(Map<String, dynamic> map) {
    final shopServices = (map['services'] as List<dynamic>? ?? [])
        .map((service) => ShopService.fromMap(service as Map<String, dynamic>))
        .toList();

    return ShopScheduleData(
      data: map,
      shopServices: shopServices,
    );
  }
}

