import 'package:shared_preferences/shared_preferences.dart';
import '../../Helpers/logger.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  static const String _keyFirstLogin = 'is_first_login';
  static const String _keyLastActivity = 'last_activity_time';

  Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLogin = prefs.getBool(_keyFirstLogin) ?? true;
    
    if (isFirstLogin) return true;

    // Check inactivity
    String? lastActivityStr = prefs.getString(_keyLastActivity);
    if (lastActivityStr != null) {
      DateTime lastActivity = DateTime.parse(lastActivityStr);
      if (DateTime.now().difference(lastActivity).inDays >= 30) {
        return true;
      }
    }

    return false;
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLogin, false);
    await prefs.setString(_keyLastActivity, DateTime.now().toIso8601String());
    AppLogger.info('Onboarding marked as complete');
  }

  Future<void> updateLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastActivity, DateTime.now().toIso8601String());
  }
}
