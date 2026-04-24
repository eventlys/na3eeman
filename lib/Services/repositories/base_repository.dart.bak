// lib/Services/repositories/base_repository.dart
import '../api/api_service.dart';
import '../../Helpers/error_handler.dart';
import '../../Helpers/logger.dart';

abstract class BaseRepository<T> {
  final ApiService apiService;

  BaseRepository(this.apiService);

  Future<List<T>> getAll({int page = 1, int limit = 20}) async {
    try {
      final response = await apiService.get('/${_getEndpoint()}', queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      });

      return (response['data'] as List).map((item) => _fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Failed to get all ${_getEndpoint()}', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  Future<T?> getById(String id) async {
    try {
      final response = await apiService.get('/${_getEndpoint()}/$id');
      return _fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Failed to get ${_getEndpoint()} by id: $id', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  Future<T> create(T item) async {
    try {
      final response = await apiService.post('/${_getEndpoint()}', data: _toJson(item));
      return _fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Failed to create ${_getEndpoint()}', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  Future<T> update(String id, T item) async {
    try {
      final response = await apiService.put('/${_getEndpoint()}/$id', data: _toJson(item));
      return _fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Failed to update ${_getEndpoint()}: $id', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  Future<T> patch(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiService.patch('/${_getEndpoint()}/$id', data: data);
      return _fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Failed to patch ${_getEndpoint()}: $id', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  Future<bool> delete(String id) async {
    try {
      await apiService.delete('/${_getEndpoint()}/$id');
      return true;
    } catch (e) {
      AppLogger.error('Failed to delete ${_getEndpoint()}: $id', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  // Search method
  Future<List<T>> search(String query, {int page = 1, int limit = 20}) async {
    try {
      final response = await apiService.get('/${_getEndpoint()}/search', queryParams: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });

      return (response['data'] as List).map((item) => _fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Failed to search ${_getEndpoint()}', error: e);
      throw ErrorHandler.handleException(e);
    }
  }

  // Abstract methods to be implemented by concrete repositories
  String _getEndpoint();
  T _fromJson(Map<String, dynamic> json);
  Map<String, dynamic> _toJson(T item);
}

// Repository interfaces for dependency injection
abstract class AuthRepositoryInterface {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData);
  Future<void> logout();
  Future<bool> isLoggedIn();
}

abstract class SalonRepositoryInterface {
  Future<List<dynamic>> getSalons({int page, int limit});
  Future<Map<String, dynamic>> getSalonDetails(String salonId);
  Future<List<dynamic>> searchSalons(String query);
  Future<List<dynamic>> getFavoriteSalons();
  Future<bool> toggleFavorite(String salonId);
}

abstract class AppointmentRepositoryInterface {
  Future<List<dynamic>> getAppointments({int page, int limit});
  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> appointmentData);
  Future<bool> cancelAppointment(String appointmentId);
  Future<bool> rescheduleAppointment(String appointmentId, DateTime newTime);
}

abstract class LoyaltyRepositoryInterface {
  Future<Map<String, dynamic>> getLoyaltyBalance(int customerId);
  Future<Map<String, dynamic>> awardPoints(int customerId, int points, String source);
  Future<Map<String, dynamic>> redeemFreeHaircut(int customerId);
}
