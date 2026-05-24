import '../../Helpers/service_models_helper.dart';
import '../api/api_service.dart';
import '../../Helpers/logger.dart';

class ServiceRepository {
  // Simulate fetching services from API
  Future<List<Map<String, dynamic>>> getSalonServices(int salonId) async {
    try {
      final apiService = ApiService();
      final response = await apiService.getSalonServices(salonId);
      return convertApiResponseToServices(response);
    } catch (e) {
      AppLogger.error('Failed to fetch salon services', error: e);
      return [];
    }
  }

  // Convert API response to service data format
  List<Map<String, dynamic>> convertApiResponseToServices(
    List<dynamic> apiResponse,
  ) {
    return ServiceDataHelper.convertToDisplayFormat(apiResponse);
  }

  // Search services by name
  List<Map<String, dynamic>> searchServices(
    List<Map<String, dynamic>> services,
    String query,
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
