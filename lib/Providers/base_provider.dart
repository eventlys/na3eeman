import 'package:flutter/material.dart';
import '../Services/storage_service.dart';

abstract class BaseProvider extends ChangeNotifier {
  final UnifiedStorageService secureStorage = UnifiedStorageService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    clearError();
    super.dispose();
  }
}
