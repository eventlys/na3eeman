import '../Helpers/expert_list_helper.dart';
import '../Helpers/error_handler.dart';
import '../Helpers/logger.dart';
import 'api/api_service.dart';
import 'api/endpoints.dart';

class ExpertService {
  ExpertService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<ExpertDto>> getExperts({
    int page = 1,
    int limit = 20,
    String? search,
    int? salonId,
    bool? isActive,
  }) async {
    try {
      AppLogger.debug(
        'Fetching experts - page: $page, limit: $limit, salonId: $salonId',
      );

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (salonId != null) {
        queryParams['salon'] = salonId.toString();
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final response = await _apiService.get(
        Endpoints.usersExperts,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((expertData) => ExpertDto.fromJson(expertData)).toList();
    } catch (error) {
      AppLogger.debug(
        'Backend returned error for GET /staff. Mocking empty list to prevent crash.',
      );
      return [];
    }
  }

  Future<ExpertDto> getExpertById(String expertId) async {
    try {
      AppLogger.debug('Fetching expert details: $expertId');

      final response = await _apiService.get('/staff/$expertId');
      return ExpertDto.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to fetch expert: $expertId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<ExpertDto> createExpert(Map<String, dynamic> expertData) async {
    try {
      AppLogger.debug('Creating new expert');

      final response = await _apiService.post('/staff', data: expertData);
      return ExpertDto.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to create expert', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<ExpertDto> updateExpert(
    String expertId,
    Map<String, dynamic> expertData,
  ) async {
    try {
      AppLogger.debug('Updating expert: $expertId');

      final response = await _apiService.put(
        '/staff/$expertId',
        data: expertData,
      );
      return ExpertDto.fromJson(response['data'] ?? response);
    } catch (error) {
      AppLogger.error('Failed to update expert: $expertId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<void> deleteExpert(String expertId) async {
    try {
      AppLogger.debug('Deleting expert: $expertId');

      await _apiService.delete('/staff/$expertId');
    } catch (error) {
      AppLogger.error('Failed to delete expert: $expertId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }

  Future<List<ExpertDto>> getSalonExperts(int salonId) async {
    try {
      AppLogger.debug('Fetching experts for salon: $salonId');

      final response = await _apiService.get('/salons/$salonId/staff');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((expertData) => ExpertDto.fromJson(expertData)).toList();
    } catch (error) {
      AppLogger.debug(
        'Failed to fetch salon experts: $salonId. Returning empty list.',
      );
      return [];
    }
  }

  Future<Map<String, dynamic>> getExpertStats(String expertId) async {
    try {
      AppLogger.debug('Fetching stats for expert: $expertId');

      return await _apiService.get('/expert/$expertId/stats');
    } catch (error) {
      AppLogger.error('Failed to fetch expert stats: $expertId', error: error);
      throw ErrorHandler.handleException(error);
    }
  }
}
