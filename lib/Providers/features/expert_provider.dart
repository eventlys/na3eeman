import 'package:flutter/material.dart';
import '../../Services/expert_service.dart';
import '../../Helpers/expert_list_helper.dart';

class ExpertProvider with ChangeNotifier {
  final ExpertService _expertService = ExpertService();

  List<ExpertDto> _experts = [];
  ExpertDto? _selectedExpert;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<ExpertDto> get experts => _experts;
  ExpertDto? get selectedExpert => _selectedExpert;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Methods
  Future<void> loadExperts({
    bool refresh = false,
    String? search,
    int? salonId,
    bool? isActive,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _experts.clear();
      }

      if (!_hasMore && !refresh) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      final List<ExpertDto> newExperts = await _expertService.getExperts(
        page: _currentPage,
        limit: 20,
        search: search,
        salonId: salonId,
        isActive: isActive,
      );

      if (refresh) {
        _experts = newExperts;
      } else {
        _experts.addAll(newExperts);
      }

      _hasMore =
          newExperts.length == 20; // If we got less than limit, no more data
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshExperts({
    String? search,
    int? salonId,
    bool? isActive,
  }) async {
    return loadExperts(
      refresh: true,
      search: search,
      salonId: salonId,
      isActive: isActive,
    );
  }

  Future<ExpertDto> getExpertById(String expertId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final ExpertDto expert = await _expertService.getExpertById(expertId);
      _selectedExpert = expert;

      notifyListeners();
      return expert;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ExpertDto> createExpert(Map<String, dynamic> expertData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final ExpertDto newExpert = await _expertService.createExpert(expertData);
      _experts.insert(0, newExpert);

      notifyListeners();
      return newExpert;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ExpertDto> updateExpert(
    String expertId,
    Map<String, dynamic> expertData,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final ExpertDto updatedExpert = await _expertService.updateExpert(
        expertId,
        expertData,
      );

      final int index = _experts.indexWhere((expert) => expert.id == expertId);
      if (index != -1) {
        _experts[index] = updatedExpert;
      }

      if (_selectedExpert?.id == expertId) {
        _selectedExpert = updatedExpert;
      }

      notifyListeners();
      return updatedExpert;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpert(String expertId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _expertService.deleteExpert(expertId);

      _experts.removeWhere((expert) => expert.id == expertId);

      if (_selectedExpert?.id == expertId) {
        _selectedExpert = null;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectExpert(ExpertDto? expert) {
    _selectedExpert = expert;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedExpert = null;
    notifyListeners();
  }
}
