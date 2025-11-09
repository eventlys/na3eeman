import 'package:flutter/material.dart';

class LocationService {
  final ValueNotifier<bool> locationEnabledNotifier = ValueNotifier(true);

  Future<void> toggleLocation(bool enabled) async {
    locationEnabledNotifier.value = enabled;
    // Implement actual location service toggle logic
    if (enabled) {
      // Request location permissions and enable
    } else {
      // Disable location services
    }
  }
}

