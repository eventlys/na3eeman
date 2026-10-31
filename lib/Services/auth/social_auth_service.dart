import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../Helpers/config.dart';
import '../../Helpers/logger.dart';
import '../../Helpers/registration_helper.dart';

/// Result of a native social sign-in attempt: either the normalized payload the
/// backend expects, or a user-facing error / cancellation.
class SocialSignInResult {
  final Map<String, dynamic>? data;
  final String? errorMessage;
  final bool cancelled;

  const SocialSignInResult._({
    this.data,
    this.errorMessage,
    this.cancelled = false,
  });

  factory SocialSignInResult.success(Map<String, dynamic> data) =>
      SocialSignInResult._(data: data);

  factory SocialSignInResult.failure(String message) =>
      SocialSignInResult._(errorMessage: message);

  factory SocialSignInResult.cancelled() =>
      const SocialSignInResult._(cancelled: true);

  bool get isSuccess => data != null;
}

/// Thin wrapper around the Google / Apple sign-in SDKs that returns a
/// normalized `socialData` map shaped for `SocialRegistrationHelper`.
class SocialAuthService {
  static const List<AppleIDAuthorizationScopes> _appleScopes = [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ];

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    // On Android, google_sign_in v7 requires the *Web* OAuth client ID
    // (serverClientId) to obtain credentials the backend can verify.
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleClientId,
    );
    _googleInitialized = true;
  }

  Future<SocialSignInResult> signInWithGoogle() async {
    // Fail fast with a clear message if the client ID isn't configured, instead
    // of surfacing the SDK's clientConfigurationError.
    final clientId = AppConfig.googleClientId;
    if (clientId == null || clientId.isEmpty) {
      AppLogger.error(
        'Google sign-in not configured: GOOGLE_CLIENT_ID missing',
      );
      return SocialSignInResult.failure('google_sign_in_not_configured');
    }
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final displayName = account.displayName;
      final nameParts = displayName?.trim().split(RegExp(r'\s+')) ?? [];
      final data = <String, dynamic>{
        'id': account.id,
        'email': account.email,
        'displayName': displayName,
        'givenName': nameParts.isNotEmpty ? nameParts.first : null,
        'familyName': nameParts.length > 1 ? nameParts.last : null,
        'photoUrl': account.photoUrl,
      };
      return SocialSignInResult.success(data);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return SocialSignInResult.cancelled();
      }
      AppLogger.error('Google sign-in failed', error: e);
      return SocialSignInResult.failure('google_sign_in_failed');
    } catch (e) {
      AppLogger.error('Google sign-in failed', error: e);
      return SocialSignInResult.failure('google_sign_in_failed');
    }
  }

  Future<SocialSignInResult> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: _appleScopes,
      );

      final data = <String, dynamic>{
        'id': credential.userIdentifier,
        'email': credential.email,
        'givenName': credential.givenName,
        'familyName': credential.familyName,
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
      };
      return SocialSignInResult.success(data);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return SocialSignInResult.cancelled();
      }
      AppLogger.error('Apple sign-in failed', error: e);
      return SocialSignInResult.failure('apple_sign_in_failed');
    } catch (e) {
      AppLogger.error('Apple sign-in failed', error: e);
      return SocialSignInResult.failure('apple_sign_in_failed');
    }
  }

  /// Whether Apple sign-in should be offered (iOS/macOS; also offered on Android
  /// when configured via web service — see Environment config).
  bool get isAppleSignInAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Map a UI provider name to the helper's provider constant.
  String providerNameFor(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.google:
        return SocialRegistrationHelper.googleProvider;
      case SocialProvider.apple:
        return SocialRegistrationHelper.appleProvider;
    }
  }
}

enum SocialProvider { google, apple }
