import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Helpers/error_handler.dart';
import 'package:na3eeman/Models/salon/salons_model.dart' hide Review;
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Services/repositories/salon_repository.dart';

import '../test_helpers.dart';

/// Same seam as test/auth/auth_repository_test.dart: [ApiService] is a
/// singleton with a private constructor, so this fake implements the
/// interface and stubs the members [SalonRepository] actually calls.
class FakeApiService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final Map<String, dynamic> _responses = {};
  final Map<String, Object> _errors = {};

  void stub(String method, String path, dynamic response) {
    _responses['$method $path'] = response;
  }

  void stubError(String method, String path, Object error) {
    _errors['$method $path'] = error;
  }

  dynamic _dispatch(String method, String path) {
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
    return _dispatch('GET', path);
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, String>? customHeaders,
  }) async {
    return _dispatch('POST', path);
  }

  @override
  Future<dynamic> getSalons({
    int? categoryId,
    int? page,
    int? limit,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
    Map<String, dynamic>? filters,
  }) async {
    return _dispatch('GET_SALONS', '/salons');
  }
}

Map<String, dynamic> _salonJson({int id = 1, String name = 'Test Salon'}) {
  return {'id': id, 'salon_name': name};
}

void main() {
  late FakeApiService fakeApi;
  late SalonRepository repository;

  setUp(() {
    setupTestEnvironment();
    fakeApi = FakeApiService();
    repository = SalonRepository(fakeApi);
  });

  group('SalonRepository.getSalonsSafe', () {
    test('returns Success with parsed salons on a good payload', () async {
      fakeApi.stub('GET_SALONS', '/salons', {
        'results': [_salonJson(id: 1), _salonJson(id: 2, name: 'Second')],
      });

      final result = await repository.getSalonsSafe();

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      final salons = result.valueOrNull;
      expect(salons, isA<List<Salon>>());
      expect(salons, hasLength(2));
      expect(salons!.first.id, 1);
      expect(salons.last.salonName, 'Second');
    });

    test(
      'a thrown AppError surfaces as Failure carrying the same error',
      () async {
        final original = AppError('Rate limited', type: ErrorType.client);
        fakeApi.stubError('GET_SALONS', '/salons', original);

        final result = await repository.getSalonsSafe();

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, same(original));
        expect(result.valueOrNull, isNull);
      },
    );

    test('network failure maps to Failure with ErrorType.network', () async {
      fakeApi.stubError(
        'GET_SALONS',
        '/salons',
        const SocketException('No route to host'),
      );

      final result = await repository.getSalonsSafe();

      expect(result.isFailure, isTrue);
      final error = result.errorOrNull!;
      expect(error.type, ErrorType.network);
      expect(error.message, 'No internet connection');
    });

    test('unmapped exceptions normalize to an unknown AppError', () async {
      fakeApi.stubError('GET_SALONS', '/salons', Exception('boom'));

      final result = await repository.getSalonsSafe();

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.type, ErrorType.unknown);
    });
  });

  group('SalonRepository.getSalonDetailsSafe', () {
    test('returns Success with the parsed salon', () async {
      fakeApi.stub('GET', '/salons/7', {'data': _salonJson(id: 7)});

      final result = await repository.getSalonDetailsSafe(7);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.id, 7);
      expect(result.valueOrNull!.salonName, 'Test Salon');
    });

    test('missing data payload surfaces as a handled Failure', () async {
      // response['data'] is null → Salon.fromJson throws a TypeError, which
      // the Safe wrapper normalizes instead of rethrowing.
      fakeApi.stub('GET', '/salons/7', <String, dynamic>{});

      final result = await repository.getSalonDetailsSafe(7);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<AppError>());
    });

    test('a thrown AppError surfaces as Failure', () async {
      final original = AppError('Not found', type: ErrorType.notFound);
      fakeApi.stubError('GET', '/salons/7', original);

      final result = await repository.getSalonDetailsSafe(7);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, same(original));
    });
  });

  group('SalonRepository.submitReviewSafe', () {
    test('a thrown AppError surfaces as Failure', () async {
      final original = AppError(
        'Review not allowed',
        type: ErrorType.authorization,
      );
      fakeApi.stubError('POST', '/reviews', original);

      final result = await repository.submitReviewSafe(
        salonId: 1,
        customerId: 2,
        rating: 5,
        comment: 'Great',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, same(original));
    });
  });

  group('SalonRepository.toggleFavoriteSafe', () {
    test('returns Success(null) when the call succeeds', () async {
      fakeApi.stub('POST', '/salons/favorites', <String, dynamic>{});

      final result = await repository.toggleFavoriteSafe(3);

      expect(result.isSuccess, isTrue);
    });

    test('a thrown AppError surfaces as Failure', () async {
      fakeApi.stubError(
        'POST',
        '/salons/favorites',
        AppError('Auth required', type: ErrorType.authentication),
      );

      final result = await repository.toggleFavoriteSafe(3);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.type, ErrorType.authentication);
    });
  });
}
