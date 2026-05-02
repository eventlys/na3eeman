import 'api/api_service.dart';
import 'api/endpoints.dart';
import '../Helpers/logger.dart';

class ContentService {
  final ApiService _apiService;

  ContentService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<Map<String, dynamic>>> getFAQs() async {
    try {
      final response = await _apiService.get(Endpoints.faqs);
      final List<dynamic> data = response is List ? response : (response['results'] ?? response['data'] ?? []);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('Error fetching FAQs: $e');
      return [];
    }
  }

  Future<String> getAppRules(String role) async {
    try {
      final response = await _apiService.get(Endpoints.rulesByRole(role.toUpperCase()));
      return response['content'] ?? '';
    } catch (e) {
      AppLogger.error('Error fetching rules for $role: $e');
      return '';
    }
  }

  Future<String> getUserGuide(String role) async {
    try {
      final response = await _apiService.get(Endpoints.guidesByRole(role.toUpperCase()));
      return response['content'] ?? '';
    } catch (e) {
      AppLogger.error('Error fetching guide for $role: $e');
      return '';
    }
  }

  Future<String> getPrivacyPolicy() async {
    try {
      final response = await _apiService.get(Endpoints.privacyPolicy);
      return response['content'] ?? '';
    } catch (e) {
      AppLogger.error('Error fetching privacy policy: $e');
      return '';
    }
  }
}
