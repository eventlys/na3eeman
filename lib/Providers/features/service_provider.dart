import 'package:flutter/material.dart';
import '../../Services/api/api_service.dart';
import '../../Services/expert_service.dart';
import '../../Helpers/service_models_helper.dart';

class ServiceProvider with ChangeNotifier {
  Map<String, dynamic>? _currentServiceSelection;
  List<Map<String, dynamic>> _availableAdditionalServices = [];

  Map<String, dynamic>? get currentServiceSelection => _currentServiceSelection;
  List<Map<String, dynamic>> get availableAdditionalServices =>
      _availableAdditionalServices;

  // Retained as an injection seam: no instance reads it directly today
  // (the public getter that exposed it was removed), so it is discarded.
  // ignore: unused_field
  final ApiService _apiService;
  late ExpertService _expertService;

  ServiceProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService() {
    _initializeServices();
  }

  void _initializeServices() {
    _expertService = ExpertService();
  }

  ExpertService get expertService => _expertService;

  // Initialize with main service
  void initializeServiceSelection(Map<String, dynamic> mainService) {
    _currentServiceSelection = ServiceSelectionHelper.createServiceSelection(
      mainService: mainService,
    );
    notifyListeners();
  }

  void toggleAdditionalService(Map<String, dynamic> service) {
    if (_currentServiceSelection == null) return;

    _currentServiceSelection = ServiceSelectionHelper.toggleAdditionalService(
      _currentServiceSelection!,
      service,
    );
    notifyListeners();
  }

  // Set available additional services
  void setAvailableAdditionalServices(List<Map<String, dynamic>> services) {
    _availableAdditionalServices = services;
    notifyListeners();
  }

  // Clear service selection
  void clearServiceSelection() {
    _currentServiceSelection = null;
    _availableAdditionalServices = [];
    notifyListeners();
  }

  // Get all selected services
  List<Map<String, dynamic>> get allSelectedServices {
    if (_currentServiceSelection == null) return [];
    return ServiceSelectionHelper.getAllServices(_currentServiceSelection!);
  }

  // Check if service is selected
  bool isServiceSelected(Map<String, dynamic> service) {
    if (_currentServiceSelection == null) return false;
    return ServiceSelectionHelper.containsService(
      _currentServiceSelection!,
      service,
    );
  }

  // Get main service
  Map<String, dynamic>? get mainService {
    if (_currentServiceSelection == null) return null;
    return ServiceSelectionHelper.getMainService(_currentServiceSelection!);
  }

  // Get additional services
  List<Map<String, dynamic>> get additionalServices {
    if (_currentServiceSelection == null) return [];
    return ServiceSelectionHelper.getAdditionalServices(
      _currentServiceSelection!,
    );
  }

  // Check if any service is selected
  bool get hasServiceSelected => _currentServiceSelection != null;

  // Convert API response to service data format
  List<Map<String, dynamic>> convertApiResponseToServices(
    List<dynamic> apiResponse,
  ) {
    return ServiceDataHelper.convertToDisplayFormat(apiResponse);
  }
}
