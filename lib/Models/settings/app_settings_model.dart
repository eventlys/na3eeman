class AppSettings {
  final bool isDarkMode;
  final String languageCode;
  final bool locationEnabled;
  final bool notificationsEnabled;
  final bool? biometricAuthEnabled;
  final String? themeColor;
  final String? fontSize;
  final bool? autoBackupEnabled;
  final String? backupFrequency;

  AppSettings({
    required this.isDarkMode,
    required this.languageCode,
    required this.locationEnabled,
    required this.notificationsEnabled,
    this.biometricAuthEnabled,
    this.themeColor,
    this.fontSize,
    this.autoBackupEnabled,
    this.backupFrequency,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    String? languageCode,
    bool? locationEnabled,
    bool? notificationsEnabled,
    bool? biometricAuthEnabled,
    String? themeColor,
    String? fontSize,
    bool? autoBackupEnabled,
    String? backupFrequency,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      themeColor: themeColor ?? this.themeColor,
      fontSize: fontSize ?? this.fontSize,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['is_dark_mode'] as bool? ?? false,
      languageCode: json['language_code'] as String? ?? 'en',
      locationEnabled: json['location_enabled'] as bool? ?? true,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      biometricAuthEnabled: json['biometric_auth_enabled'] as bool?,
      themeColor: json['theme_color'] as String?,
      fontSize: json['font_size'] as String?,
      autoBackupEnabled: json['auto_backup_enabled'] as bool?,
      backupFrequency: json['backup_frequency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_dark_mode': isDarkMode,
      'language_code': languageCode,
      'location_enabled': locationEnabled,
      'notifications_enabled': notificationsEnabled,
      'biometric_auth_enabled': biometricAuthEnabled,
      'theme_color': themeColor,
      'font_size': fontSize,
      'auto_backup_enabled': autoBackupEnabled,
      'backup_frequency': backupFrequency,
    };
  }

  static AppSettings get defaultSettings {
    return AppSettings(
      isDarkMode: false,
      languageCode: 'en',
      locationEnabled: true,
      notificationsEnabled: true,
      biometricAuthEnabled: false,
      themeColor: 'blue',
      fontSize: 'medium',
      autoBackupEnabled: false,
      backupFrequency: 'weekly',
    );
  }
}
