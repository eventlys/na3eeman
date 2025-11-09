class AppSettings {
  final bool isDarkMode;
  final String languageCode;
  final bool locationEnabled;
  final bool notificationsEnabled;

  AppSettings({
    required this.isDarkMode,
    required this.languageCode,
    required this.locationEnabled,
    required this.notificationsEnabled,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? locationEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
