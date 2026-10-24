import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Helpers/cache_helper.dart';
import 'package:na3eeman/Providers/features/salon_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Services/api/endpoints.dart';

import '../test_helpers.dart';

/// In-memory fake for [CacheHelper]'s store/retrieve/listener surface.
///
/// CacheHelper is a Hive-backed singleton, so unit tests fake it at the
/// helper boundary instead of standing up Hive. Mirrors the TTL expiry
/// semantics of the real helper: expired entries read as null.
class FakeCacheHelper implements CacheHelper {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final Map<String, dynamic> _data = {};
  final Map<String, DateTime> _expiry = {};
  final Map<String, List<void Function(dynamic)>> _listeners = {};
  final List<String> storedKeys = [];

  bool _isLive(String key) {
    final expiresAt = _expiry[key];
    return expiresAt == null || DateTime.now().isBefore(expiresAt);
  }

  void seed(
    String key,
    dynamic value, {
    Duration ttl = const Duration(hours: 1),
  }) {
    _data[key] = value;
    _expiry[key] = DateTime.now().add(ttl);
  }

  void _publish(String key, dynamic data) {
    final listeners = _listeners[key];
    if (listeners == null) return;
    for (final listener in List<void Function(dynamic)>.of(listeners)) {
      listener(data);
    }
  }

  @override
  void Function() addListener(String key, void Function(dynamic) listener) {
    (_listeners[key] ??= []).add(listener);
    return () => _listeners[key]?.remove(listener);
  }

  @override
  void removeListener(String key, void Function(dynamic) listener) {
    _listeners[key]?.remove(listener);
  }

  @override
  Future<void> store(
    String key,
    dynamic data, {
    Duration duration = const Duration(hours: 1),
  }) async {
    storedKeys.add(key);
    _data[key] = data;
    _expiry[key] = DateTime.now().add(duration);
    _publish(key, data);
  }

  @override
  dynamic retrieve(String key) => _isLive(key) ? _data[key] : null;

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
    _expiry.remove(key);
  }

  @override
  Future<void> storeSalonsList(List<dynamic> salons) =>
      store(CacheKeys.salonsList, salons);

  @override
  List<dynamic>? retrieveSalonsList() => retrieve(CacheKeys.salonsList);

  @override
  Future<void> storeCategoriesList(List<dynamic> categories) =>
      store(CacheKeys.categoriesList, categories);

  @override
  List<dynamic>? retrieveCategoriesList() => retrieve(CacheKeys.categoriesList);

  @override
  Future<void> storeSalonDetails(
    int salonId,
    Map<String, dynamic> details, {
    Duration duration = CacheDurations.medium,
  }) => store('${CacheKeys.salonDetailsPrefix}$salonId', details);

  @override
  Map<String, dynamic>? retrieveSalonDetails(int salonId) {
    final data = retrieve('${CacheKeys.salonDetailsPrefix}$salonId');
    return data is Map<String, dynamic> ? data : null;
  }
}

/// Hand-written fake for [ApiService], following the pattern in
/// test/auth/auth_repository_test.dart: the singleton cannot be subclassed
/// (private constructor), so this implements the interface and stubs the
/// members SalonProvider actually calls; `noSuchMethod` covers the rest.
class FakeApiService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final Map<String, dynamic> _responses = {};
  final Map<String, Object> _errors = {};
  final List<Map<String, dynamic>> calls = [];

  void stub(String key, dynamic response) {
    _responses[key] = response;
  }

  void stubError(String key, Object error) {
    _errors[key] = error;
  }

  dynamic _dispatch(String key, Map<String, dynamic> call) {
    calls.add(call);
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
    return _dispatch('GET $path', {
      'method': 'GET',
      'path': path,
      'queryParams': queryParams,
      'customHeaders': customHeaders,
    });
  }

  @override
  Future<List<dynamic>> getCategories() async {
    final result = _dispatch('getCategories', {'method': 'getCategories'});
    return result as List<dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getSalonDetails(int salonId) async {
    final result = _dispatch('getSalonDetails $salonId', {
      'method': 'getSalonDetails',
      'salonId': salonId,
    });
    return Map<String, dynamic>.from(result as Map);
  }

  @override
  Future<dynamic> updateSalonWithImages({
    required int salonId,
    required Map<String, String> fields,
    List<File>? images,
  }) async {
    return _dispatch('updateSalonWithImages', {
      'method': 'updateSalonWithImages',
      'salonId': salonId,
      'fields': fields,
    });
  }
}

/// Minimal salon payload accepted by Salon.fromJson.
Map<String, dynamic> testSalonJson(int id, String name) => {
  'id': id,
  'salonName': name,
  'salonPhoneNum': '+96650000000$id',
  'salonDescription': 'Test salon $id',
  'location': 'Riyadh',
  'lat': '24.7',
  'lng': '46.6',
  'confirmed_phone': true,
  'owner_id': 1,
};

void main() {
  late FakeApiService fakeApi;
  late FakeCacheHelper fakeCache;
  late SalonProvider provider;

  setUp(() {
    setupTestEnvironment();
    fakeApi = FakeApiService();
    fakeCache = FakeCacheHelper();
    provider = SalonProvider(apiService: fakeApi, cacheHelper: fakeCache);
  });

  tearDown(() {
    provider.dispose();
  });

  group('SalonProvider.loadSalons cache-then-network', () {
    test('cold cache: fetches from network and populates the cache', () async {
      fakeApi.stub('GET ${Endpoints.salons}', {
        'results': [testSalonJson(1, 'Alpha')],
      });

      await provider.loadSalons();

      expect(provider.salons.map((s) => s.salonName), ['Alpha']);
      expect(fakeCache.retrieveSalonsList(), hasLength(1));
      expect(fakeCache.storedKeys, contains(CacheKeys.salonsList));
    });

    test('warm cache: emits cached salons before the network response, '
        'then updates with fresh data and still revalidates', () async {
      fakeCache.seed(CacheKeys.salonsList, [testSalonJson(1, 'Cached')]);
      fakeApi.stub('GET ${Endpoints.salons}', {
        'results': [testSalonJson(2, 'Fresh')],
      });

      final emissions = <List<String>>[];
      provider.addListener(() {
        emissions.add(provider.salons.map((s) => s.salonName).toList());
      });

      await provider.loadSalons();

      // First emission is the cached list, second is the fresh list.
      expect(emissions, isNotEmpty);
      expect(emissions.first, ['Cached']);
      expect(emissions.last, ['Fresh']);
      // The network was still hit (stale-while-revalidate).
      expect(
        fakeApi.calls.where((c) => c['path'] == Endpoints.salons),
        hasLength(1),
      );
      expect(provider.salons.single.salonName, 'Fresh');
      // Cache refreshed with the parsed list.
      final cached = fakeCache.retrieveSalonsList()!;
      expect((cached.single as Map)['salonName'], 'Fresh');
    });

    test('network failure with warm cache keeps the cached salons', () async {
      fakeCache.seed(CacheKeys.salonsList, [testSalonJson(1, 'Cached')]);
      fakeApi.stubError('GET ${Endpoints.salons}', Exception('offline'));

      await provider.loadSalons();

      expect(provider.salons.single.salonName, 'Cached');
    });

    test('owner salon update invalidates the salons list cache', () async {
      fakeCache.seed(CacheKeys.salonsList, [testSalonJson(1, 'Alpha')]);
      fakeApi.stub('GET ${Endpoints.salons}', {
        'results': [testSalonJson(1, 'Alpha')],
      });
      await provider.loadSalons();
      expect(fakeCache.retrieveSalonsList(), isNotNull);

      fakeApi.stub('updateSalonWithImages', testSalonJson(1, 'Renamed'));
      await provider.updateSalonOnBackend(
        name: 'Renamed',
        phone: '+966500000001',
        location: 'Riyadh',
        description: 'Updated',
      );

      expect(fakeCache.retrieveSalonsList(), isNull);
      expect(fakeCache.retrieve('${CacheKeys.salonDetailsPrefix}1'), isNull);
    });
  });

  group('SalonProvider.getCategoriesCached', () {
    test('cold cache: returns network list and populates the cache', () async {
      fakeApi.stub('getCategories', [
        {'id': 1, 'name': 'Hair'},
      ]);

      final result = await provider.getCategoriesCached();

      expect(result, hasLength(1));
      expect(fakeCache.retrieveCategoriesList(), hasLength(1));
      expect(
        fakeApi.calls.where((c) => c['method'] == 'getCategories'),
        hasLength(1),
      );
    });

    test('warm cache: callback fires with cached list first, then the fresh '
        'list when the background revalidation lands', () async {
      fakeCache.seed(CacheKeys.categoriesList, [
        {'id': 1, 'name': 'Cached'},
      ]);
      fakeApi.stub('getCategories', [
        {'id': 2, 'name': 'Fresh'},
      ]);

      final emissions = <List<dynamic>>[];
      final result = await provider.getCategoriesCached(
        onCategories: emissions.add,
      );

      expect(emissions, hasLength(2));
      expect((emissions[0].single as Map)['name'], 'Cached');
      expect((emissions[1].single as Map)['name'], 'Fresh');
      expect((result.single as Map)['name'], 'Fresh');
    });

    test('network failure with warm cache returns the cached list', () async {
      fakeCache.seed(CacheKeys.categoriesList, [
        {'id': 1, 'name': 'Cached'},
      ]);
      fakeApi.stubError('getCategories', Exception('offline'));

      final result = await provider.getCategoriesCached();

      expect((result.single as Map)['name'], 'Cached');
    });

    test('network failure on cold cache rethrows (same as before)', () async {
      fakeApi.stubError('getCategories', Exception('offline'));

      await expectLater(provider.getCategoriesCached(), throwsException);
    });
  });

  group('SalonProvider.getSalonDetailsCached', () {
    test('warm cache: callback fires with cached details first, then fresh '
        'details, and the cache is updated', () async {
      fakeCache.seed(
        '${CacheKeys.salonDetailsPrefix}7',
        testSalonJson(7, 'Cached Details'),
      );
      fakeApi.stub('getSalonDetails 7', testSalonJson(7, 'Fresh Details'));

      final emissions = <Map<String, dynamic>>[];
      final result = await provider.getSalonDetailsCached(
        7,
        onDetails: emissions.add,
      );

      expect(emissions, hasLength(2));
      expect(emissions[0]['salonName'], 'Cached Details');
      expect(emissions[1]['salonName'], 'Fresh Details');
      expect(result['salonName'], 'Fresh Details');
      expect(fakeCache.retrieveSalonDetails(7)?['salonName'], 'Fresh Details');
    });

    test(
      'network failure with warm cache returns the cached details',
      () async {
        fakeCache.seed(
          '${CacheKeys.salonDetailsPrefix}7',
          testSalonJson(7, 'Cached Details'),
        );
        fakeApi.stubError('getSalonDetails 7', Exception('offline'));

        final result = await provider.getSalonDetailsCached(7);

        expect(result['salonName'], 'Cached Details');
      },
    );
  });
}
