import '../Helpers/barber_list_helper.dart';
import '../Helpers/error_handler.dart';
import '../Helpers/logger.dart';
import 'api/api_service.dart';
import 'api/endpoints.dart';

class BarberService {
  final ApiService _apiService = ApiService();

  Future<List<BarberDto>> getBarbers({
    int page = 1,
    int limit = 20,
    String? search,
    int? shopId,
    bool? isActive,
  }) async {
    try {
      AppLogger.debug('Fetching barbers - page: $page, limit: $limit, shopId: $shopId');

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (shopId != null) {
        queryParams['shop'] = shopId.toString();
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final response = await _apiService.get(Endpoints.usersStaff, queryParams: queryParams);

      final List<dynamic> data = response['data'] ?? [];
      return data.map((barberData) => BarberDto.fromJson(barberData)).toList();
    } catch (error) {
      AppLogger.debug('Backend returned error for GET /staff. Mocking empty list to prevent crash.');
      return [];
    }
  }

  Future<BarberDto> getBarberById(String barberId) async {
    try {
      AppLogger.debug('Fetching barber details: $barberId');

      final response = await _apiService.get('/staff/$barberId');
      return BarberDto.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to fetch barber: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<BarberDto> createBarber(Map<String, dynamic> barberData) async {
    try {
      AppLogger.debug('Creating new barber');

      final response = await _apiService.post('/staff', data: barberData);
      return BarberDto.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to create barber', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<BarberDto> updateBarber(String barberId, Map<String, dynamic> barberData) async {
    try {
      AppLogger.debug('Updating barber: $barberId');

      final response = await _apiService.put('/staff/$barberId', data: barberData);
      return BarberDto.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to update barber: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> deleteBarber(String barberId) async {
    try {
      AppLogger.debug('Deleting barber: $barberId');

      await _apiService.delete('/staff/$barberId');
    } catch (error) {
      AppLogger.error('Failed to delete barber: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<BarberDto>> getShopBarbers(int shopId) async {
    try {
      AppLogger.debug('Fetching barbers for shop: $shopId');

      final response = await _apiService.get('/shops/$shopId/staff');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((barberData) => BarberDto.fromJson(barberData)).toList();
    } catch (error) {
      AppLogger.debug('Failed to fetch shop barbers: $shopId. Returning empty list.');
      return [];
    }
  }

  Future<Map<String, dynamic>> getBarberStats(String barberId) async {
    try {
      AppLogger.debug('Fetching stats for barber: $barberId');

      return await _apiService.get('/barber/$barberId/stats');
    } catch (error) {
      AppLogger.error('Failed to fetch barber stats: $barberId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }
}
