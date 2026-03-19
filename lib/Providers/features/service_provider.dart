import 'package:flutter/material.dart';
import '../../Services/api/api_service.dart';
import '../../Services/barber_service.dart';
import '../../Helpers/service_models_helper.dart';

class ServiceProvider with ChangeNotifier {
  Map<String, dynamic>? _currentServiceSelection;
  List<Map<String, dynamic>> _availableAdditionalServices = [];

  Map<String, dynamic>? get currentServiceSelection => _currentServiceSelection;
  List<Map<String, dynamic>> get availableAdditionalServices =>
      _availableAdditionalServices;

  final ApiService _apiService = ApiService();
  late BarberService _barberService;

  ServiceProvider() {
    _initializeServices();
  }

  void _initializeServices() {
    _barberService = BarberService();
  }

  BarberService get barberService => _barberService;
  ApiService get apiService => _apiService;

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
