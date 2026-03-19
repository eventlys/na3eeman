// import 'package:flutter/material.dart';
import '../base_provider.dart';
import '../../Models/settings/app_settings_model.dart';

class SettingsProvider extends BaseProvider {
  AppSettings _settings = AppSettings.defaultSettings;

  // Getters
  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  String get languageCode => _settings.languageCode;

  Future<void> loadSettings() async {
    try {
      setLoading(true);
      clearError();

      await _mockLoadSettings();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _mockLoadSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      setLoading(true);
      clearError();

      _settings = newSettings;
      await _mockSaveSettings();

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> _mockSaveSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> toggleDarkMode() async {
    final newSettings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await updateSettings(newSettings);
  }
}
