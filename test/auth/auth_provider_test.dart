import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Services/api/endpoints.dart';
import 'package:na3eeman/Services/repositories/auth_repository.dart';
import 'package:na3eeman/Services/storage_service.dart';
// Transitive dependencies used only to fake platform paths in tests.
// ignore: depend_on_referenced_packages
import 'package:path_provider_linux/path_provider_linux.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

/// Hand-written fake for [ApiService].
///
/// [ApiService] is a singleton built on the top-level `http.get`/`http.post`
/// functions, so it cannot be mocked at the HTTP layer, and its only
/// constructor is private, so it cannot be subclassed. This fake implements
/// the interface instead: `noSuchMethod` covers members we do not care about
/// and the concrete overrides stub the verbs the auth flow uses. The seam is
/// intentionally brittle: if a refactored `ApiService` changes its method
/// signatures, update this fake to match.
class FakeApiService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final Map<String, dynamic> _responses = {};
  final Map<String, Object> _errors = {};
  final List<Map<String, dynamic>> calls = [];

  void stub(String method, String path, dynamic response) {
    _responses['$method $path'] = response;
  }

  void stubError(String method, String path, Object error) {
    _errors['$method $path'] = error;
  }

  dynamic _dispatch(String method, String path, Map<String, dynamic> call) {
    calls.add(call);
    final key = '$method $path';
    if (_errors.containsKey(key)) throw _errors[key]!;
    if (_responses.containsKey(key)) return _responses[key];
    throw StateError('FakeApiService: no stub registered for $key');
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? customHeaders,
  }) async {
    return _dispatch('GET', path, {
      'method': 'GET',
      'path': path,
      'queryParams': queryParams,
      'customHeaders': customHeaders,
    });
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, String>? customHeaders,
  }) async {
    return _dispatch('POST', path, {
      'method': 'POST',
      'path': path,
      'data': data,
      'customHeaders': customHeaders,
    });
  }
}

/// In-memory store behind the flutter_secure_storage method channel.
///
/// `UnifiedStorageService` is a singleton wrapping `FlutterSecureStorage`,
/// so instead of mocking the service we mock the plugin channel it uses.
class FakeSecureStorageChannel {
  static const MethodChannel _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final Map<String, String> store = {};

  void setUp() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          final args = Map<String, dynamic>.from(
            (call.arguments as Map?) ?? {},
          );
          final key = args['key'] as String?;
          switch (call.method) {
            case 'read':
              return store[key];
            case 'write':
              store[key!] = args['value'] as String;
              return null;
            case 'delete':
              store.remove(key);
              return null;
            case 'deleteAll':
              store.clear();
              return null;
            case 'readAll':
              return Map<String, String>.from(store);
            default:
              return null;
          }
        });
  }

  void tearDown() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}

void main() {
  late FakeApiService fakeApi;
  late FakeSecureStorageChannel secureChannel;
  late AuthProvider provider;

  // TestData.getTestUser() uses a string id ('user_123') which breaks the
  // login path: AuthService passes user['id'] to AnalyticsService.logLogin's
  // `int? userId` parameter. The production backend returns numeric ids, so
  // these payloads use one.
  Map<String, dynamic> testUser() => {...TestData.getTestUser(), 'id': 123};

  Map<String, dynamic> loginPayload() => {
    'access': TestData.testToken,
    'refresh': 'refresh_token_value',
    'user': testUser(),
  };

  setUp(() async {
    setupTestEnvironment();
    SharedPreferences.setMockInitialValues({});
    secureChannel = FakeSecureStorageChannel()..setUp();
    // path_provider falls back to a (missing) method channel in unit tests,
    // so register the Linux Dart implementation against a temp directory;
    // then the real UnifiedStorageService singleton can be fully initialized.
    final tempDir = await Directory.systemTemp.createTemp('auth_test_');
    PathProviderPlatform.instance = PathProviderLinux.private(
      environment: {'TMPDIR': tempDir.path, 'HOME': tempDir.path},
    );
    await UnifiedStorageService().initialize();
    fakeApi = FakeApiService();
    provider = AuthProvider(authRepository: AuthRepository(fakeApi));
  });

  tearDown(() {
    provider.dispose();
    secureChannel.tearDown();
  });

  group('AuthProvider initial state', () {
    test('starts unauthenticated with no user', () {
      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
      expect(provider.currentToken, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });
  });

  group('AuthProvider.login', () {
    test('email login success authenticates and persists tokens', () async {
      fakeApi.stub('POST', Endpoints.login, loginPayload());

      final result = await provider.login(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );

      expect(result, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.user, isNotNull);
      expect(provider.user!.email, TestData.testEmail);
      expect(provider.currentToken, TestData.testToken);

      // Token storage behavior: both tokens go to secure storage.
      expect(secureChannel.store['auth_token'], TestData.testToken);
      expect(secureChannel.store['refresh_token'], 'refresh_token_value');

      // last_activity preference is stamped on login.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_activity'), isNotNull);
      expect(prefs.getString('user_data'), isNotNull);
    });

    test('login notifies listeners', () async {
      fakeApi.stub('POST', Endpoints.login, loginPayload());
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.login(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );

      expect(notifyCount, greaterThan(0));
    });

    test(
      'wrong credentials return false, set error, and persist nothing',
      () async {
        fakeApi.stubError(
          'POST',
          Endpoints.login,
          Exception('Unable to log in with provided credentials.'),
        );

        final result = await provider.login(
          email: TestData.testEmail,
          // A syntactically valid but wrong password: credential validation
          // (LoginUseCase) must let it through so the server rejection,
          // not a client-side validation error, is what surfaces.
          password: 'wrong1',
        );

        expect(result, isFalse);
        expect(provider.isAuthenticated, isFalse);
        expect(provider.isLoading, isFalse);
        // Current behavior: AppError.details is stringified and the
        // "Exception: " prefix is stripped from the user-facing message.
        expect(provider.error, 'Unable to log in with provided credentials.');
        expect(provider.user, isNull);
        expect(provider.currentToken, isNull);
        expect(secureChannel.store, isEmpty);
      },
    );

    test(
      'server error returns false with the server message as error',
      () async {
        fakeApi.stubError('POST', Endpoints.login, Exception('API Error 500'));

        final result = await provider.login(
          email: TestData.testEmail,
          password: TestData.testPassword,
        );

        expect(result, isFalse);
        expect(provider.error, 'API Error 500');
      },
    );

    test(
      'response without access token fails and keeps user logged out',
      () async {
        fakeApi.stub('POST', Endpoints.login, {'user': testUser()});

        final result = await provider.login(
          email: TestData.testEmail,
          password: TestData.testPassword,
        );

        expect(result, isFalse);
        expect(provider.isAuthenticated, isFalse);
        expect(provider.error, contains('missing access token'));
        expect(secureChannel.store, isEmpty);
      },
    );

    test(
      'login without credentials fails with invalid parameters error',
      () async {
        final result = await provider.login();

        expect(result, isFalse);
        // Current behavior: plain (non-AppError) exceptions fall back to the
        // "Login failed: <exception>" format.
        expect(provider.error, contains('Login failed:'));
        expect(provider.error, contains('Invalid login parameters'));
      },
    );
  });

  group('AuthProvider.logout', () {
    test('logout clears in-memory state and all stored auth data', () async {
      fakeApi.stub('POST', Endpoints.login, loginPayload());
      fakeApi.stub('POST', Endpoints.logout, <String, dynamic>{});

      await provider.login(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();

      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
      expect(provider.error, isNull);
      // clearAuthData deletes every secure storage key.
      expect(secureChannel.store, isEmpty);
      // user_data / user_profile preferences are removed.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_data'), isNull);
      expect(prefs.getString('user_profile'), isNull);
    });

    test('logout clears state even when the logout API call fails', () async {
      fakeApi.stub('POST', Endpoints.login, loginPayload());
      fakeApi.stubError('POST', Endpoints.logout, Exception('API Error 500'));

      await provider.login(
        email: TestData.testEmail,
        password: TestData.testPassword,
      );
      await provider.logout();

      // Current behavior: the API error is swallowed (logged only) and the
      // local session is cleared in the finally block.
      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
      expect(secureChannel.store, isEmpty);
    });
  });

  group('AuthProvider OTP flows', () {
    test('forgotPassword returns the service result on success', () async {
      fakeApi.stub('POST', Endpoints.passwordReset, {
        'success': true,
        'message': 'OTP sent',
      });

      final result = await provider.forgotPassword(TestData.testEmail);

      expect(result['success'], isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('forgotPassword failure returns a failure map with the server '
        'message', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.passwordReset,
        Exception('API Error 500'),
      );

      final result = await provider.forgotPassword(TestData.testEmail);

      expect(result['success'], isFalse);
      // Current behavior: when the AppError carries details, the user-facing
      // message is the (prefix-stripped) server detail, not the generic text.
      expect(result['message'], 'API Error 500');
      expect(provider.error, contains('Failed to send OTP'));
    });

    test(
      'verifyPasswordResetOtp returns the service result on success',
      () async {
        fakeApi.stub('POST', Endpoints.passwordResetVerify, {
          'success': true,
          'token': 'reset_token',
        });

        final result = await provider.verifyPasswordResetOtp(
          email: TestData.testEmail,
          otp: '123456',
        );

        expect(result['success'], isTrue);
        expect(provider.isLoading, isFalse);
      },
    );

    test('verifyPasswordResetOtp failure returns a failure map', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.passwordResetVerify,
        Exception('Invalid OTP'),
      );

      final result = await provider.verifyPasswordResetOtp(
        email: TestData.testEmail,
        // A well-formed but wrong OTP: the use-case format guard lets it
        // through so the server's "Invalid OTP" failure is what surfaces.
        otp: '000000',
      );

      expect(result['success'], isFalse);
      expect(result['message'], 'OTP verification failed. Please try again.');
      expect(provider.error, contains('OTP verification failed'));
    });

    test('resetPassword returns the service result on success', () async {
      fakeApi.stub('POST', Endpoints.passwordResetConfirm, {'success': true});

      final result = await provider.resetPassword(
        token: 'reset_token',
        newPassword: 'NewPass123!',
      );

      expect(result['success'], isTrue);
    });

    test('resetPassword failure returns a failure map', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.passwordResetConfirm,
        Exception('Token expired'),
      );

      final result = await provider.resetPassword(
        token: 'bad_token',
        newPassword: 'NewPass123!',
      );

      expect(result['success'], isFalse);
      expect(result['message'], 'Password reset failed. Please try again.');
    });
  });

  group('AuthProvider use-case validation (no network)', () {
    test('login with an invalid email fails without hitting the API', () async {
      final result = await provider.login(
        email: 'not-an-email',
        password: TestData.testPassword,
      );

      expect(result, isFalse);
      expect(provider.isLoading, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.error, 'Please enter a valid email');
      expect(fakeApi.calls, isEmpty);
    });

    test('login with a short password fails without hitting the API', () async {
      final result = await provider.login(
        email: TestData.testEmail,
        password: '12345',
      );

      expect(result, isFalse);
      expect(provider.error, 'Password must be at least 6 characters');
      expect(fakeApi.calls, isEmpty);
    });

    test(
      'login with empty credentials fails without hitting the API',
      () async {
        final result = await provider.login(email: '', password: '');

        expect(result, isFalse);
        expect(provider.error, 'Email and password are required');
        expect(fakeApi.calls, isEmpty);
      },
    );

    test(
      'forgotPassword with an invalid email fails without hitting the API',
      () async {
        final result = await provider.forgotPassword('not-an-email');

        expect(result['success'], isFalse);
        expect(result['message'], 'Please enter a valid email');
        expect(fakeApi.calls, isEmpty);
      },
    );

    test('verifyPasswordResetOtp with a malformed OTP fails without hitting '
        'the API', () async {
      final result = await provider.verifyPasswordResetOtp(
        email: TestData.testEmail,
        otp: 'abc',
      );

      expect(result['success'], isFalse);
      expect(result['message'], 'OTP verification failed. Please try again.');
      expect(provider.error, contains('OTP verification failed'));
      expect(fakeApi.calls, isEmpty);
    });

    test('resetPassword with a short new password fails without hitting the '
        'API', () async {
      final result = await provider.resetPassword(
        token: 'reset_token',
        newPassword: '12345',
      );

      expect(result['success'], isFalse);
      expect(result['message'], 'Password must be at least 6 characters');
      expect(fakeApi.calls, isEmpty);
    });
  });
}
