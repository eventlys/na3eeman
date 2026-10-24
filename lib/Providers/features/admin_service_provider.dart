import 'package:flutter/material.dart';
import '../../Services/api/api_service.dart';
import '../../Models/loyalty/feedback_model.dart';

class AdminServiceProvider with ChangeNotifier {
  final ApiService _apiService;

  AdminServiceProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  List<dynamic> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.get(
        '/analytics/admin/service-requests/',
      );
      _requests = response['results'] ?? response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRequestStatus(int id, String status) async {
    try {
      await _apiService.patch(
        '/analytics/admin/service-requests/$id/',
        data: {'status': status},
      );
      final index = _requests.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        _requests[index]['status'] = status;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // DATA-ACCESS DELEGATES
  // Pure pass-throughs so admin pages never touch ApiService directly.
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getUsers({String? role, String? query}) =>
      _apiService.getUsers(role: role, query: query);

  Future<dynamic> updateUserStatus(int userId, String status) =>
      _apiService.updateUserStatus(userId, status);

  Future<List<HelpFeedback>> getFeedback() => _apiService.getFeedback();

  Future<dynamic> reviewFeedback(int feedbackId, String status) =>
      _apiService.reviewFeedback(feedbackId, status);

  Future<List<dynamic>> getFAQs() => _apiService.getFAQs();

  Future<dynamic> createFAQ(Map<String, dynamic> data) =>
      _apiService.createFAQ(data);

  Future<dynamic> updateFAQ(int id, Map<String, dynamic> data) =>
      _apiService.updateFAQ(id, data);

  Future<dynamic> deleteFAQ(int id) => _apiService.deleteFAQ(id);
}
