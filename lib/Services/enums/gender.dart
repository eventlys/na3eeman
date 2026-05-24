// lib/core/enums/gender.dart
enum Gender { male, female, nonBinary }

extension GenderExtension on Gender {
  String get value {
    switch (this) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
      case Gender.nonBinary:
        return 'NON_BINARY';
    }
  }

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.nonBinary:
        return 'Non-Binary';
    }
  }

  static Gender fromString(String value) {
    switch (value.toUpperCase()) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      case 'NON_BINARY':
        return Gender.nonBinary;
      default:
        return Gender.male;
    }
  }
}
