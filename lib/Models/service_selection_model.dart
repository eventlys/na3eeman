import 'shop_service_model.dart';

class ServiceSelection {
  final ShopService mainService;
  final List<ShopService> additionalServices;

  const ServiceSelection({
    required this.mainService,
    this.additionalServices = const [],
  });

  List<ShopService> get allServices => [mainService, ...additionalServices];

  ServiceSelection copyWith({
    ShopService? mainService,
    List<ShopService>? additionalServices,
  }) {
    return ServiceSelection(
      mainService: mainService ?? this.mainService,
      additionalServices: additionalServices ?? this.additionalServices,
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
}

