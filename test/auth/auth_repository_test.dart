import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Helpers/error_handler.dart';
import 'package:na3eeman/Models/auth/user_model.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Services/api/endpoints.dart';
import 'package:na3eeman/Services/repositories/auth_repository.dart';

import '../test_helpers.dart';

/// Hand-written fake for [ApiService].
///
/// [ApiService] is a singleton built on the top-level `http.get`/`http.post`
/// functions, so it cannot be mocked at the HTTP layer, and its only
/// constructor is private, so it cannot be subclassed. This fake implements
/// the interface instead: `noSuchMethod` covers members we do not care about
/// and the concrete overrides stub the verbs the repository uses. The seam is
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

  @override
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, String>? customHeaders,
  }) async {
    return _dispatch('PATCH', path, {
      'method': 'PATCH',
      'path': path,
      'data': data,
      'customHeaders': customHeaders,
    });
  }
}

void main() {
  late FakeApiService fakeApi;
  late AuthRepository repository;

  setUp(() {
    setupTestEnvironment();
    fakeApi = FakeApiService();
    repository = AuthRepository(fakeApi);
  });

  group('AuthRepository.login', () {
    test('returns the response map on success', () async {
      final payload = {
        'access': TestData.testToken,
        'refresh': 'refresh_token_value',
        'user': TestData.getTestUser(),
      };
      fakeApi.stub('POST', Endpoints.login, payload);

      final result = await repository.login(
        TestData.testEmail,
        TestData.testPassword,
      );

      expect(result, equals(payload));
      expect(fakeApi.calls, hasLength(1));
      expect(fakeApi.calls.single['path'], Endpoints.login);
      expect(fakeApi.calls.single['data'], {
        'email': TestData.testEmail,
        'password': TestData.testPassword,
      });
    });

    test(
      'wrong credentials surface as AppError carrying the server message',
      () async {
        // ApiService._handleResponse throws Exception(message) for non-2xx;
        // the repository wraps it via ErrorHandler.handleException into an
        // AppError with type unknown and the exception string in details.
        fakeApi.stubError(
          'POST',
          Endpoints.login,
          Exception('Unable to log in with provided credentials.'),
        );

        await expectLater(
          repository.login(TestData.testEmail, 'wrong'),
          throwsA(
            isA<AppError>()
                .having((e) => e.type, 'type', ErrorType.unknown)
                .having(
                  (e) => e.details,
                  'details',
                  contains('Unable to log in with provided credentials.'),
                ),
          ),
        );
      },
    );

    test('server error surfaces as AppError', () async {
      fakeApi.stubError('POST', Endpoints.login, Exception('API Error 500'));

      await expectLater(
        repository.login(TestData.testEmail, TestData.testPassword),
        throwsA(isA<AppError>()),
      );
    });

    test('network failure maps to ErrorType.network', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.login,
        const SocketException('No route to host'),
      );

      await expectLater(
        repository.login(TestData.testEmail, TestData.testPassword),
        throwsA(
          isA<AppError>()
              .having((e) => e.type, 'type', ErrorType.network)
              .having((e) => e.message, 'message', 'No internet connection'),
        ),
      );
    });

    test('timeout maps to ErrorType.timeout', () async {
      fakeApi.stubError('POST', Endpoints.login, TimeoutException('timed out'));

      await expectLater(
        repository.login(TestData.testEmail, TestData.testPassword),
        throwsA(
          isA<AppError>().having((e) => e.type, 'type', ErrorType.timeout),
        ),
      );
    });

    test('an AppError thrown below passes through unchanged', () async {
      final original = AppError(
        'Session expired',
        type: ErrorType.authentication,
      );
      fakeApi.stubError('POST', Endpoints.login, original);

      await expectLater(
        repository.login(TestData.testEmail, TestData.testPassword),
        throwsA(same(original)),
      );
    });
  });

  group('AuthRepository.register', () {
    final userData = {
      'first_name': 'Test',
      'last_name': 'User',
      'email': TestData.testEmail,
      'username': 'test',
      'phone': '+1234567890',
      'gender': 'MALE',
      'password': TestData.testPassword,
      'role': 'CUSTOMER',
    };

    test('returns the response map on success', () async {
      final payload = {
        'access': TestData.testToken,
        'refresh': 'refresh_token_value',
        'user': TestData.getTestUser(),
      };
      fakeApi.stub('POST', Endpoints.register, payload);

      final result = await repository.register(userData);

      expect(result, equals(payload));
      expect(fakeApi.calls.single['path'], Endpoints.register);
      expect(fakeApi.calls.single['data'], equals(userData));
    });

    test(
      'validation failure surfaces as AppError with field details',
      () async {
        fakeApi.stubError(
          'POST',
          Endpoints.register,
          Exception('email: Email already exists'),
        );

        await expectLater(
          repository.register(userData),
          throwsA(
            isA<AppError>().having(
              (e) => e.details,
              'details',
              contains('email: Email already exists'),
            ),
          ),
        );
      },
    );
  });

  group('AuthRepository.forgotPassword', () {
    test('returns success flag from a Map response', () async {
      fakeApi.stub('POST', Endpoints.passwordReset, {
        'success': true,
        'message': 'Check your inbox',
      });

      final result = await repository.forgotPassword(TestData.testEmail);

      expect(result['success'], isTrue);
      expect(result['message'], 'Check your inbox');
      expect(fakeApi.calls.single['data'], {'email': TestData.testEmail});
    });

    // When the server omits success/message, the repository injects
    // defaults. The default message is a plain English literal — the
    // repository no longer localizes (.tr() was removed in Phase 3.4a);
    // presentation layers may localize at display time.
    test('missing success defaults to true and message defaults to the '
        'English default string', () async {
      fakeApi.stub('POST', Endpoints.passwordReset, <String, dynamic>{});

      final result = await repository.forgotPassword(TestData.testEmail);

      expect(result['success'], isTrue);
      expect(result['message'], 'OTP sent successfully');
    });

    test('non-Map response is wrapped in data with success true', () async {
      fakeApi.stub('POST', Endpoints.passwordReset, 'ok');

      final result = await repository.forgotPassword(TestData.testEmail);

      expect(result['success'], isTrue);
      expect(result['data'], 'ok');
    });

    test('failure surfaces as AppError', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.passwordReset,
        Exception('user: No account found with this email'),
      );

      await expectLater(
        repository.forgotPassword(TestData.testEmail),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('AuthRepository.verifyPasswordResetOtp', () {
    test('returns success flag on valid OTP', () async {
      fakeApi.stub('POST', Endpoints.passwordResetVerify, {
        'success': true,
        'message': 'OTP verified',
        'token': 'reset_token',
      });

      final result = await repository.verifyPasswordResetOtp(
        email: TestData.testEmail,
        otp: '123456',
      );

      expect(result['success'], isTrue);
      expect(result['token'], 'reset_token');
      expect(fakeApi.calls.single['data'], {
        'email': TestData.testEmail,
        'otp': '123456',
      });
    });

    // Same as forgotPassword: the repository's default message is now a
    // plain English literal, not a .tr() call.
    test(
      'missing success defaults to true with English default message',
      () async {
        fakeApi.stub(
          'POST',
          Endpoints.passwordResetVerify,
          <String, dynamic>{},
        );

        final result = await repository.verifyPasswordResetOtp(
          email: TestData.testEmail,
          otp: '123456',
        );

        expect(result['success'], isTrue);
        expect(result['message'], 'OTP verified successfully');
      },
    );

    test('invalid OTP surfaces as AppError', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.passwordResetVerify,
        Exception('Invalid OTP'),
      );

      await expectLater(
        repository.verifyPasswordResetOtp(
          email: TestData.testEmail,
          otp: '000000',
        ),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('AuthRepository.resetPassword', () {
    test('sends token and new password, returns success', () async {
      fakeApi.stub('POST', Endpoints.passwordResetConfirm, {'success': true});

      final result = await repository.resetPassword(
        token: 'reset_token',
        newPassword: 'NewPass123!',
      );

      expect(result['success'], isTrue);
      expect(fakeApi.calls.single['data'], {
        'new_password': 'NewPass123!',
        'token': 'reset_token',
      });
    });

    test('omits null optional fields from the request body', () async {
      fakeApi.stub('POST', Endpoints.passwordResetConfirm, {'success': true});

      await repository.resetPassword(newPassword: 'NewPass123!');

      expect(fakeApi.calls.single['data'], {'new_password': 'NewPass123!'});
    });

    test('failure surfaces as AppError', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.passwordResetConfirm,
        Exception('Token expired'),
      );

      await expectLater(
        repository.resetPassword(token: 'x', newPassword: 'NewPass123!'),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('AuthRepository.verifyEmailOtp', () {
    test('returns the response map on success', () async {
      fakeApi.stub('POST', Endpoints.verifyEmail, {
        'success': true,
        'message': 'Email verified',
      });

      final result = await repository.verifyEmailOtp(
        email: TestData.testEmail,
        otp: '123456',
      );

      expect(result['success'], isTrue);
      expect(fakeApi.calls.single['data'], {
        'email': TestData.testEmail,
        'otp': '123456',
      });
    });

    test('invalid OTP surfaces as AppError', () async {
      fakeApi.stubError(
        'POST',
        Endpoints.verifyEmail,
        Exception('Invalid or expired OTP'),
      );

      await expectLater(
        repository.verifyEmailOtp(email: TestData.testEmail, otp: '000000'),
        throwsA(isA<AppError>()),
      );
    });
  });

  group('AuthRepository.getCurrentUser', () {
    // TestData.getTestUser() uses a string id ('user_123'); User.fromJson
    // parses it with int.tryParse and falls back to 0 — captured as-is.
    test('parses a wrapped data response into a User', () async {
      fakeApi.stub('GET', Endpoints.currentUser, {
        'data': TestData.getTestUser(),
      });

      final user = await repository.getCurrentUser();

      expect(user, isA<User>());
      expect(user.email, TestData.testEmail);
      expect(user.id, 0);
    });

    test('parses a direct (unwrapped) response into a User', () async {
      fakeApi.stub('GET', Endpoints.currentUser, TestData.getTestUser());

      final user = await repository.getCurrentUser();

      expect(user.email, TestData.testEmail);
    });

    test('failure surfaces as AppError', () async {
      fakeApi.stubError(
        'GET',
        Endpoints.currentUser,
        Exception('API Error 401'),
      );

      await expectLater(repository.getCurrentUser(), throwsA(isA<AppError>()));
    });
  });

  group('AuthRepository.logout', () {
    test('sends the refresh token when provided', () async {
      fakeApi.stub('POST', Endpoints.logout, <String, dynamic>{});

      await repository.logout(refreshToken: 'refresh_token_value');

      expect(fakeApi.calls.single['data'], {'refresh': 'refresh_token_value'});
    });

    test('sends null data when no refresh token is given', () async {
      fakeApi.stub('POST', Endpoints.logout, <String, dynamic>{});

      await repository.logout();

      expect(fakeApi.calls.single['data'], isNull);
    });

    test('server failure still throws AppError (does not swallow)', () async {
      fakeApi.stubError('POST', Endpoints.logout, Exception('API Error 500'));

      await expectLater(repository.logout(), throwsA(isA<AppError>()));
    });
  });
}
