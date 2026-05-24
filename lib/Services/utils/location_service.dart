import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../Helpers/logger.dart';

class LocationService with ChangeNotifier {
  // final LoggingInterceptor _logger = LoggingInterceptor();

  final ValueNotifier<bool> locationEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<Position?> currentPositionNotifier = ValueNotifier(null);
  final ValueNotifier<LocationPermission> permissionStatusNotifier =
      ValueNotifier(LocationPermission.denied);

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLocationEnabled => locationEnabledNotifier.value;
  Position? get currentPosition => currentPositionNotifier.value;
  LocationPermission get permissionStatus => permissionStatusNotifier.value;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      locationEnabledNotifier.value = serviceEnabled;

      // Check permission status
      final permission = await Geolocator.checkPermission();
      permissionStatusNotifier.value = permission;

      // Get current position if permission granted
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await getCurrentLocation();
      }

      _isLoading = false;
      notifyListeners();
      AppLogger.debug('Location service initialized');
    } catch (e) {
      _error = 'Failed to initialize location service: $e';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Location service initialization failed: $e');
    }
  }

  Future<void> toggleLocation(bool enabled) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (enabled) {
        await _enableLocationServices();
      } else {
        locationEnabledNotifier.value = false;
        currentPositionNotifier.value = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle location: $e';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Location toggle failed: $e');
    }
  }

  Future<void> _enableLocationServices() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      permissionStatusNotifier.value = permission;
      locationEnabledNotifier.value = true;

      // Get current location
      await getCurrentLocation();

      AppLogger.debug('Location services enabled');
    } catch (e) {
      AppLogger.error('Failed to enable location services: $e');
      rethrow;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );

      currentPositionNotifier.value = position;
      _error = null;

      AppLogger.debug(
        'Current location obtained: ${position.latitude}, ${position.longitude}',
      );

      _isLoading = false;
      notifyListeners();
      return position;
    } catch (e) {
      _error = 'Failed to get current location: $e';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Failed to get current location: $e');
      return null;
    }
  }

  Future<List<Position>> getLastKnownPositions() async {
    try {
      final positions = await Geolocator.getLastKnownPosition();
      return positions != null ? [positions] : [];
    } catch (e) {
      AppLogger.error('Failed to get last known positions: $e');
      return [];
    }
  }

  Future<double> calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final distance = Geolocator.distanceBetween(
        startLat,
        startLng,
        endLat,
        endLng,
      );

      return distance;
    } catch (e) {
      AppLogger.error('Distance calculation failed: $e');
      return 0.0;
    }
  }

  Future<bool> isWithinRadius(
    double targetLat,
    double targetLng,
    double radiusMeters,
  ) async {
    try {
      final currentPosition = await getCurrentLocation();
      if (currentPosition == null) return false;

      final distance = await calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        targetLat,
        targetLng,
      );

      return distance <= radiusMeters;
    } catch (e) {
      AppLogger.error('Radius check failed: $e');
      return false;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10, // meters
      ),
    ).handleError((error) {
      AppLogger.error('Location stream error: $error');
    });
  }

  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
      AppLogger.debug('Location settings opened');
    } catch (e) {
      AppLogger.error('Failed to open location settings: $e');
    }
  }

  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
      AppLogger.debug('App settings opened');
    } catch (e) {
      AppLogger.error('Failed to open app settings: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if location permission is granted
  bool get hasLocationPermission {
    return permissionStatus == LocationPermission.always ||
        permissionStatus == LocationPermission.whileInUse;
  }

  // Check if location data is available
  bool get hasLocationData {
    return currentPosition != null && hasLocationPermission;
  }

  // Get formatted address from coordinates (would integrate with geocoding service)
  Future<String?> getFormattedAddress(double lat, double lng) async {
    try {
      // This would integrate with a geocoding service like Google Maps Geocoding API
      // For now, return coordinates as string
      return '$lat, $lng';
    } catch (e) {
      AppLogger.error('Failed to get formatted address: $e');
      return null;
    }
  }

  // Method to get nearby salons based on current location
  Future<List<dynamic>> getNearbySalons(double radiusKm) async {
    try {
      final currentPosition = await getCurrentLocation();
      if (currentPosition == null) {
        throw Exception('No current location available');
      }

      // This would integrate with your backend API to get nearby salons
      // For now, return empty list
      return [];
    } catch (e) {
      AppLogger.error('Failed to get nearby salons: $e');
      return [];
    }
  }

  // Dispose method
  @override
  void dispose() {
    locationEnabledNotifier.dispose();
    currentPositionNotifier.dispose();
    permissionStatusNotifier.dispose();
  }
}
