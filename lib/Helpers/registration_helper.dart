import 'dart:math';
import 'package:logger/logger.dart';

class SocialRegistrationHelper {
  final Logger _logger = Logger();

  // Social provider types
  static const String googleProvider = 'google';
  static const String facebookProvider = 'facebook';
  static const String appleProvider = 'apple';

  /// Process social registration data and prepare it for the API
  Future<Map<String, dynamic>> processSocialRegistration({
    required String provider,
    required Map<String, dynamic> socialData,
    String? selectedRole,
    String? selectedGender,
  })
  async {
    try {
      _logger.d('Processing social registration for $provider');

      // Extract common data from social providers
      final Map<String, dynamic> userData = {
        'first_name': _extractFirstName(socialData, provider),
        'last_name': _extractLastName(socialData, provider),
        'email': _extractEmail(socialData, provider),
        'phone_number': _extractPhoneNumber(socialData, provider),
        'gender': selectedGender ?? _inferGender(socialData, provider),
        'password': _generateTemporaryPassword(),
        'role': selectedRole ?? 'customer', // Default role
        'social_provider': provider,
        'social_id': _extractSocialId(socialData, provider),
        'is_social_signup': true,
        'avatar_url': _extractAvatarUrl(socialData, provider),
      };

      // Validate required fields
      final validationResult = _validateSocialData(userData);
      if (!validationResult['valid']) {
        throw Exception(validationResult['message']);
      }

      _logger.i('Social registration data processed successfully');
      return userData;
    } catch (e) {
      _logger.e('Error processing social registration: $e');
      rethrow;
    }
  }

  /// Extract first name from social data
  String _extractFirstName(Map<String, dynamic> socialData, String provider) {
    switch (provider) {
      case googleProvider:
        return socialData['givenName'] ?? socialData['displayName']?.split(' ').first ?? 'User';
      case facebookProvider:
        return socialData['first_name'] ?? socialData['name']?.split(' ').first ?? 'User';
      case appleProvider:
        return socialData['givenName'] ?? socialData['fullName']?.givenName ?? 'User';
      default:
        return 'User';
    }
  }

  /// Extract last name from social data
  String _extractLastName(Map<String, dynamic> socialData, String provider) {
    switch (provider) {
      case googleProvider:
        return socialData['familyName'] ?? socialData['displayName']?.split(' ').last ?? 'Social';
      case facebookProvider:
        return socialData['last_name'] ?? socialData['name']?.split(' ').last ?? 'Social';
      case appleProvider:
        return socialData['familyName'] ?? socialData['fullName']?.familyName ?? 'Social';
      default:
        return 'Social';
    }
  }

  /// Extract email from social data
  String _extractEmail(Map<String, dynamic> socialData, String provider) {
    final email = socialData['email'];
    if (email == null || email.isEmpty) {
      throw Exception('Email is required for social registration');
    }
    return email;
  }

  /// Extract phone number from social data
  String? _extractPhoneNumber(Map<String, dynamic> socialData, String provider) {
    return socialData['phoneNumber'] ?? socialData['phone'];
  }

  /// Extract social ID from social data
  String _extractSocialId(Map<String, dynamic> socialData, String provider) {
    return socialData['id'] ??
           socialData['userId'] ??
           socialData['sub'] ??
           DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Extract avatar URL from social data
  String? _extractAvatarUrl(Map<String, dynamic> socialData, String provider) {
    return socialData['photoUrl'] ??
           socialData['picture']?['data']?['url'] ??
           socialData['avatarUrl'];
  }

  /// Infer gender from social data
  String? _inferGender(Map<String, dynamic> socialData, String provider) {
    final gender = socialData['gender'];
    if (gender != null) {
      if (gender.toString().toLowerCase().contains('male')) return 'Male';
      if (gender.toString().toLowerCase().contains('female')) return 'Female';
    }
    return null;
  }

  /// Generate a temporary password for social signups
  String _generateTemporaryPassword() {
    return 'social_${DateTime.now().millisecondsSinceEpoch}_${String.fromCharCodes(List.generate(8, (index) => Random().nextInt(26) + 97))}';
  }

  /// Validate social registration data
  Map<String, dynamic> _validateSocialData(Map<String, dynamic> userData) {
    if (userData['email'] == null || userData['email'].toString().isEmpty) {
      return {'valid': false, 'message': 'Email is required'};
    }

    if (userData['first_name'] == null || userData['first_name'].toString().isEmpty) {
      return {'valid': false, 'message': 'First name is required'};
    }

    if (userData['social_id'] == null) {
      return {'valid': false, 'message': 'Social ID is required'};
    }

    return {'valid': true, 'message': 'Validation successful'};
  }

  /// Get provider display name
  String getProviderDisplayName(String provider) {
    switch (provider) {
      case googleProvider:
        return 'Google';
      case facebookProvider:
        return 'Facebook';
      case appleProvider:
        return 'Apple';
      default:
        return provider;
    }
  }
}
