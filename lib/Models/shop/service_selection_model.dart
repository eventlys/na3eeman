import 'package:na3eeman/Models/shop/shop_service_model.dart';

class ServiceSelection {
  final ShopService mainService;
  final List<ShopService> additionalServices;
  final int? shopId;
  final int? barberId;
  final DateTime? selectedDate;
  final String? selectedTime;

  const ServiceSelection({
    required this.mainService,
    this.additionalServices = const [],
    this.shopId,
    this.barberId,
    this.selectedDate,
    this.selectedTime,
  });

  List<ShopService> get allServices => [mainService, ...additionalServices];

  double get totalPrice {
    double total = double.parse(mainService.price.replaceAll('\$', ''));
    for (var service in additionalServices) {
      total += double.parse(service.price.replaceAll('\$', ''));
    }
    return total;
  }

  String get totalDuration {
    int totalMinutes = _parseDuration(mainService.duration);
    for (var service in additionalServices) {
      totalMinutes += _parseDuration(service.duration);
    }

    if (totalMinutes < 60) {
      return '${totalMinutes}min';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }

  int _parseDuration(String duration) {
    try {
      if (duration.toLowerCase().contains('min')) {
        return int.parse(duration.replaceAll(RegExp(r'[^0-9]'), ''));
      } else if (duration.toLowerCase().contains('h')) {
        final hours = int.parse(duration.replaceAll(RegExp(r'[^0-9]'), ''));
        return hours * 60;
      }
      return 30; // default 30 minutes
    } catch (e) {
      return 30;
    }
  }

  ServiceSelection copyWith({
    ShopService? mainService,
    List<ShopService>? additionalServices,
    int? shopId,
    int? barberId,
    DateTime? selectedDate,
    String? selectedTime,
  }) {
    return ServiceSelection(
      mainService: mainService ?? this.mainService,
      additionalServices: additionalServices ?? this.additionalServices,
      shopId: shopId ?? this.shopId,
      barberId: barberId ?? this.barberId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  ServiceSelection addService(ShopService service) {
    return copyWith(
      additionalServices: [...additionalServices, service],
    );
  }

  ServiceSelection removeService(ShopService service) {
    return copyWith(
      additionalServices: additionalServices.where((s) => s != service).toList(),
    );
  }

  bool containsService(ShopService service) {
    return additionalServices.contains(service);
  }

  Map<String, dynamic> toAppointmentData() {
    return {
      'shop': shopId,
      'barber': barberId,
      'start_time': selectedDate != null && selectedTime != null
          ? '${selectedDate!.toIso8601String().split('T')[0]}T$selectedTime'
          : null,
      'services': allServices.map((service) => {
        'service_type': service.type.toUpperCase(),
        'option': service.type == 'OPTION' ? service.id : null,
        'package': service.type == 'PACKAGE' ? service.id : null,
        'product': service.type == 'PRODUCT' ? service.id : null,
        'quantity': 1,
      }).toList(),
    };
  }

  bool get isComplete {
    return shopId != null && selectedDate != null && selectedTime != null;
  }
}
