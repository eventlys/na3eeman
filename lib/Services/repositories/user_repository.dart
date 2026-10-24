import '../../Helpers/logger.dart';
import '../../Models/auth/user_model.dart';
import '../api/api_service.dart';

/// Repository for user profile backend access.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
/// Distinct from `AuthRepository`, which covers authentication flows.
class UserRepository {
  final ApiService _apiService;

  UserRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return User.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<User> updateUserProfile(
    int userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.patch('/users/$userId', data: updates);
      return User.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error updating user profile: $e');
      rethrow;
    }
  }
}
