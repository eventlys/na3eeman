import '../Models/salon/salon_service_model.dart';

// Helper class to provide service-related data structures
class ServiceModelsHelper {
  // Service selection data structure
  static ServiceSelection createServiceSelection({
    required SalonService mainService,
    List<SalonService> additionalServices = const [],
  }) {
    return ServiceSelection(
      mainService: mainService,
      additionalServices: additionalServices,
    );
  }

  // Check if service selection contains a service
  static bool containsService(
    ServiceSelection selection,
    SalonService service,
  ) {
    return selection.mainService.id == service.id ||
        selection.additionalServices.any((s) => s.id == service.id);
  }

  // Get all services from selection
  static List<SalonService> getAllServices(ServiceSelection selection) {
    return [selection.mainService, ...selection.additionalServices];
  }
}

// Data structure for service management
class ServiceSelection {
  final SalonService mainService;
  final List<SalonService> additionalServices;

  ServiceSelection({
    required this.mainService,
    this.additionalServices = const [],
  });

  List<SalonService> get allServices => [mainService, ...additionalServices];

  bool containsService(SalonService service) {
    return ServiceModelsHelper.containsService(this, service);
  }
}

// Helper class to handle service data without using Models
class ServiceDataHelper {
  // Service data structure
  static Map<String, dynamic> createServiceData({
    required String id,
    required String name,
    required String duration,
    required String price,
    String? description,
  }) {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'description': description,
    };
  }

  // Get service name
  static String getServiceName(Map<String, dynamic> service) {
    return service['name'] ?? 'Unnamed Service';
  }

  // Get service duration
  static String getServiceDuration(Map<String, dynamic> service) {
    return service['duration'] ?? 'N/A';
  }

  // Get service price
  static String getServicePrice(Map<String, dynamic> service) {
    return service['price'] ?? 'N/A';
  }

  // Get service ID
  static String getServiceId(Map<String, dynamic> service) {
    return service['id'] ?? '';
  }

  // Check if two services are the same
  static bool areServicesEqual(
    Map<String, dynamic> service1,
    Map<String, dynamic> service2,
  ) {
    return getServiceId(service1) == getServiceId(service2);
  }

  // Convert list of service maps to display format
  static List<Map<String, dynamic>> convertToDisplayFormat(
    List<dynamic> services,
  ) {
    return services.map((service) {
      if (service is Map<String, dynamic>) {
        return service;
      }
      return createServiceData(
        id: service['id']?.toString() ?? '',
        name: service['name']?.toString() ?? 'Unnamed Service',
        duration: service['duration']?.toString() ?? 'N/A',
        price: service['price']?.toString() ?? 'N/A',
        description: service['description']?.toString(),
      );
    }).toList();
  }
}

// Helper class to manage service selections
class ServiceSelectionHelper {
  // Create service selection data
  static Map<String, dynamic> createServiceSelection({
    required Map<String, dynamic> mainService,
    List<Map<String, dynamic>> additionalServices = const [],
  }) {
    return {
      'mainService': mainService,
      'additionalServices': additionalServices,
    };
  }

  // Check if selection contains a service
  static bool containsService(
    Map<String, dynamic> selection,
    Map<String, dynamic> service,
  ) {
    final mainService = selection['mainService'] as Map<String, dynamic>? ?? {};
    final additionalServices =
        selection['additionalServices'] as List<dynamic>? ?? [];

    return ServiceDataHelper.areServicesEqual(mainService, service) ||
        additionalServices.any(
          (s) => ServiceDataHelper.areServicesEqual(s, service),
        );
  }

  // Get all services from selection
  static List<Map<String, dynamic>> getAllServices(
    Map<String, dynamic> selection,
  ) {
    final mainService = selection['mainService'] as Map<String, dynamic>? ?? {};
    final additionalServices =
        selection['additionalServices'] as List<dynamic>? ?? [];

    return [mainService, ...additionalServices.cast<Map<String, dynamic>>()];
  }

  // Get main service
  static Map<String, dynamic> getMainService(Map<String, dynamic> selection) {
    return selection['mainService'] as Map<String, dynamic>? ?? {};
  }

  // Get additional services
  static List<Map<String, dynamic>> getAdditionalServices(
    Map<String, dynamic> selection,
  ) {
    return (selection['additionalServices'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  // Add service to additional services
  static Map<String, dynamic> addAdditionalService(
    Map<String, dynamic> selection,
    Map<String, dynamic> service,
  ) {
    final currentAdditional = getAdditionalServices(selection);

    if (containsService(selection, service)) {
      return selection; // Already exists
    }

    return {
      'mainService': selection['mainService'],
      'additionalServices': [...currentAdditional, service],
    };
  }

  // Remove service from additional services
  static Map<String, dynamic> removeAdditionalService(
    Map<String, dynamic> selection,
    Map<String, dynamic> service,
  ) {
    final currentAdditional = getAdditionalServices(selection);

    return {
      'mainService': selection['mainService'],
      'additionalServices': currentAdditional
          .where((s) => !ServiceDataHelper.areServicesEqual(s, service))
          .toList(),
    };
  }

  // Toggle service in additional services
  static Map<String, dynamic> toggleAdditionalService(
    Map<String, dynamic> selection,
    Map<String, dynamic> service,
  ) {
    if (containsService(selection, service)) {
      return removeAdditionalService(selection, service);
    } else {
      return addAdditionalService(selection, service);
    }
  }
}
