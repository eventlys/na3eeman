import '../../Helpers/service_models_helper.dart';

class ServiceRepository {
  // Simulate fetching services from API
  Future<List<Map<String, dynamic>>> getSalonServices(int salonId) async {
    // This would typically call your API service
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay

    // Mock data - in real app, this would come from your API
    return [
      ServiceDataHelper.createServiceData(
        id: '1',
        name: 'Classic Haircut',
        duration: '30 min',
        price: '\$25.00',
        description: 'Professional haircut with styling',
      ),
      ServiceDataHelper.createServiceData(
        id: '2',
        name: 'Beard Trim',
        duration: '15 min',
        price: '\$15.00',
        description: 'Precise beard shaping and trimming',
      ),
      ServiceDataHelper.createServiceData(
        id: '3',
        name: 'Haircut & Beard',
        duration: '45 min',
        price: '\$35.00',
        description: 'Complete grooming package',
      ),
      ServiceDataHelper.createServiceData(
        id: '4',
        name: 'Hair Wash & Style',
        duration: '20 min',
        price: '\$18.00',
        description: 'Relaxing hair wash with professional styling',
      ),
    ];
  }

  // Convert API response to service data format
  List<Map<String, dynamic>> convertApiResponseToServices(List<dynamic> apiResponse) {
    return ServiceDataHelper.convertToDisplayFormat(apiResponse);
  }

  // Search services by name
  List<Map<String, dynamic>> searchServices(
    List<Map<String, dynamic>> services,
    String query
  ) {
    if (query.isEmpty) return services;

    return services.where((service) {
      final name = ServiceDataHelper.getServiceName(service).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }

  // Filter services by price range
  List<Map<String, dynamic>> filterServicesByPrice(
    List<Map<String, dynamic>> services,
    double minPrice,
    double maxPrice,
  ) {
    return services.where((service) {
      final priceString = ServiceDataHelper.getServicePrice(service);
      final cleanPrice = priceString.replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(cleanPrice) ?? 0.0;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }
}
