import 'package:flutter/material.dart';
import '../../Services/api/api_service.dart';

class AdminServiceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
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
}
