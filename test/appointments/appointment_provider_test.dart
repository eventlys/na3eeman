import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Models/appointments/salon_appointments_model.dart';
import 'package:na3eeman/Models/auth/user_model.dart';
import 'package:na3eeman/Providers/features/appointment_provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/core/enums/user_type.dart';

// Characterization tests for AppointmentProvider's pure (non-network) logic,
// plus the network paths that became testable once ApiService moved from
// inline instantiation to constructor injection.
//
// AuthProvider's user is private with no setter, so we hand it a subclass
// (`TestAuthProvider`) that overrides the exact getters the provider reads.

/// Hand-written fake for [ApiService], following the pattern in
/// test/auth/auth_repository_test.dart: the singleton cannot be subclassed
/// (private constructor), so this implements the interface and stubs the
/// members AppointmentProvider actually calls; `noSuchMethod` covers the rest.
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
  Future<Map<String, dynamic>> bookAppointment(
    Map<String, dynamic> data,
  ) async {
    return _dispatch('bookAppointment', {
      'method': 'bookAppointment',
      'data': data,
    });
  }
}

class TestAuthProvider extends AuthProvider {
  TestAuthProvider({this.userOverride, this.authenticated = true});

  final User? userOverride;
  final bool authenticated;

  @override
  User? get user => userOverride;

  @override
  bool get isAuthenticated => authenticated;

  @override
  bool get isExpert => userOverride?.isExpert ?? false;

  @override
  bool get isCustomer => userOverride?.isCustomer ?? false;
}

User makeUser(int id, UserType type) {
  return User.fromJson({
    'id': id,
    'email': 'user$id@example.com',
    'first_name': 'Test',
    'last_name': 'User$id',
    'user_type': type.value,
    'gender': 'MALE',
    'created_at': '2026-01-01T00:00:00.000',
    'updated_at': '2026-01-01T00:00:00.000',
  });
}

Map<String, dynamic> appointmentJson({
  required int id,
  required int customerId,
  int? expertId,
  required String startTime,
  String status = 'SCHEDULED',
}) {
  return {
    'id': id,
    'customer': customerId,
    'salon': 3,
    'expert': ?expertId,
    'start_time': startTime,
    'end_time': startTime,
    'created_at': '2026-10-01T00:00:00.000',
    'status': status,
  };
}

void main() {
  // Required because updateAuth schedules loadAppointments() via
  // Future.microtask, which reaches the inline ApiService() and (through it)
  // ServicesBinding.instance. With the binding initialized that call fails
  // as a logged, caught error instead of an uncaught binding assertion.
  TestWidgetsFlutterBinding.ensureInitialized();

  // The microtask reloads read the auth token through flutter_secure_storage;
  // answering the channel with null keeps those (caught, logged) calls
  // deterministic and free of MissingPluginException noise.
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(storageChannel, (call) async => null);

  late AppointmentProvider provider;

  setUp(() {
    provider = AppointmentProvider();
  });

  group('initial state', () {
    test('starts empty with no error and not loading', () {
      expect(provider.appointments, isEmpty);
      expect(provider.soonestAppointment, isNull);
      expect(provider.user, isNull);
      expect(provider.error, isNull);
      expect(provider.hasError, isFalse);
      expect(provider.isLoading, isFalse);
    });
  });

  group('myAppointments', () {
    test('returns all appointments when no auth provider is attached', () {
      provider.appointments.addAll([
        SalonAppointment.fromJson(
          appointmentJson(id: 1, customerId: 7, startTime: '2099-01-01T10:00'),
        ),
        SalonAppointment.fromJson(
          appointmentJson(id: 2, customerId: 8, startTime: '2099-01-02T10:00'),
        ),
      ]);

      final mine = provider.myAppointments;
      expect(mine, hasLength(2));
      // Entries are toJson() maps (request-shaped), not SalonAppointments.
      expect(mine.first, isA<Map<String, dynamic>>());
      expect(mine.first['salon'], 3);
    });

    test('expert sees only appointments where they are the expert', () {
      // authenticated: false keeps updateAuth from scheduling the
      // (unmockable) network reload; we only need the role getters here.
      final auth = TestAuthProvider(
        userOverride: makeUser(11, UserType.expert),
        authenticated: false,
      );
      provider.updateAuth(auth);
      provider.appointments.addAll([
        SalonAppointment.fromJson(
          appointmentJson(
            id: 1,
            customerId: 7,
            expertId: 11,
            startTime: '2099-01-01T10:00',
          ),
        ),
        SalonAppointment.fromJson(
          appointmentJson(
            id: 2,
            customerId: 7,
            expertId: 22,
            startTime: '2099-01-02T10:00',
          ),
        ),
        SalonAppointment.fromJson(
          appointmentJson(id: 3, customerId: 11, startTime: '2099-01-03T10:00'),
        ),
      ]);

      final mine = provider.myAppointments;
      expect(mine, hasLength(1));
      expect(mine.first['expert'], 11);
      // Current behavior: an appointment where the expert is the CUSTOMER is
      // not included (filter is on expertId only).
    });

    test('customer sees only their own appointments', () {
      final auth = TestAuthProvider(
        userOverride: makeUser(7, UserType.customer),
        authenticated: false,
      );
      provider.updateAuth(auth);
      provider.appointments.addAll([
        SalonAppointment.fromJson(
          appointmentJson(id: 1, customerId: 7, startTime: '2099-01-01T10:00'),
        ),
        SalonAppointment.fromJson(
          appointmentJson(id: 2, customerId: 8, startTime: '2099-01-02T10:00'),
        ),
      ]);

      expect(provider.myAppointments, hasLength(1));
    });

    test('non-expert non-customer roles see all appointments', () {
      final auth = TestAuthProvider(
        userOverride: makeUser(1, UserType.owner),
        authenticated: false,
      );
      provider.updateAuth(auth);
      provider.appointments.addAll([
        SalonAppointment.fromJson(
          appointmentJson(id: 1, customerId: 7, startTime: '2099-01-01T10:00'),
        ),
        SalonAppointment.fromJson(
          appointmentJson(id: 2, customerId: 8, startTime: '2099-01-02T10:00'),
        ),
      ]);

      // Fallback branch: no filtering for owners/admins.
      expect(provider.myAppointments, hasLength(2));
    });
  });

  group('loadSoonestAppointment (local filtering)', () {
    test('does nothing when no auth user id is available', () async {
      await provider.loadSoonestAppointment();
      expect(provider.soonestAppointment, isNull);
    });

    test('picks the nearest future SCHEDULED appointment', () async {
      final auth = TestAuthProvider(
        userOverride: makeUser(7, UserType.customer),
        authenticated: false,
      );
      provider.updateAuth(auth);
      provider.appointments.addAll([
        SalonAppointment.fromJson(
          appointmentJson(id: 1, customerId: 7, startTime: '2099-01-03T10:00'),
        ),
        SalonAppointment.fromJson(
          appointmentJson(id: 2, customerId: 7, startTime: '2099-01-01T10:00'),
        ),
      ]);

      await provider.loadSoonestAppointment();

      final soonest = provider.soonestAppointment;
      expect(soonest, isNotNull);
      expect(soonest!['id'], '2');
      expect(soonest['customerId'], 7);
      expect(soonest['salonId'], 3);
      expect(soonest['dateTime'], '2099-01-01T10:00:00.000');
      // Current behavior: hardcoded placeholders, not real API data.
      expect(soonest['totalPrice'], 0.0);
      expect(soonest['salonName'], 'Salon #3');
    });

    test('ignores past and non-scheduled appointments', () async {
      final auth = TestAuthProvider(
        userOverride: makeUser(7, UserType.customer),
        authenticated: false,
      );
      provider.updateAuth(auth);
      provider.appointments.addAll([
        SalonAppointment.fromJson(
          appointmentJson(id: 1, customerId: 7, startTime: '2000-01-01T10:00'),
        ),
        SalonAppointment.fromJson(
          appointmentJson(
            id: 2,
            customerId: 7,
            startTime: '2099-01-01T10:00',
            status: 'CANCELLED',
          ),
        ),
      ]);

      await provider.loadSoonestAppointment();
      expect(provider.soonestAppointment, isNull);
    });

    test('is null when there are no future scheduled appointments', () async {
      final auth = TestAuthProvider(
        userOverride: makeUser(7, UserType.customer),
        authenticated: false,
      );
      provider.updateAuth(auth);

      await provider.loadSoonestAppointment();
      expect(provider.soonestAppointment, isNull);
    });

    test(
      'considers appointments of all customers (no customer filter)',
      () async {
        final auth = TestAuthProvider(
          userOverride: makeUser(7, UserType.customer),
          authenticated: false,
        );
        provider.updateAuth(auth);
        provider.appointments.add(
          SalonAppointment.fromJson(
            appointmentJson(
              id: 9,
              customerId: 8,
              startTime: '2099-01-01T10:00',
            ),
          ),
        );

        await provider.loadSoonestAppointment();
        // Current behavior: the soonest-appointment filter does NOT scope to
        // the current user's customer id.
        expect(provider.soonestAppointment, isNotNull);
        expect(provider.soonestAppointment!['customerId'], 8);
      },
    );
  });

  group('updateAuth', () {
    test('attaches the auth provider without throwing', () {
      // authenticated: false -> updateAuth detects no change and schedules
      // nothing, keeping this a purely synchronous characterization.
      expect(
        () => provider.updateAuth(
          TestAuthProvider(
            userOverride: makeUser(7, UserType.customer),
            authenticated: false,
          ),
        ),
        returnsNormally,
      );
    });

    test(
      'does not notify listeners when attaching the first auth provider',
      () {
        var notified = 0;
        provider.addListener(() => notified++);

        // Current behavior: updateAuth itself never calls notifyListeners();
        // it only schedules async reloads via Future.microtask.
        provider.updateAuth(
          TestAuthProvider(
            userOverride: makeUser(7, UserType.customer),
            authenticated: false,
          ),
        );

        expect(notified, 0);
      },
    );

    // Note: when the auth state changes to authenticated, updateAuth schedules
    // loadAppointments()/loadSoonestAppointment() via Future.microtask, which
    // reaches the ApiService (no Environment initialized, no network) and
    // fails asynchronously — the error is caught and logged via AppLogger
    // inside loadAppointments, so it does not fail these tests.
  });

  // Network-path tests enabled by the ApiService injection seam.
  group('loadAppointments (with fake ApiService)', () {
    late FakeApiService fakeApi;

    setUp(() {
      fakeApi = FakeApiService();
      provider = AppointmentProvider(apiService: fakeApi);
    });

    test('parses results, notifies, and clears loading on success', () async {
      fakeApi.stub('GET /salons/appointments/', {
        'results': [
          appointmentJson(id: 1, customerId: 7, startTime: '2099-01-01T10:00'),
        ],
      });

      var notified = 0;
      provider.addListener(() => notified++);

      await provider.loadAppointments();

      expect(provider.appointments, hasLength(1));
      expect(provider.appointments.single.id, '1');
      expect(provider.hasError, isFalse);
      expect(provider.isLoading, isFalse);
      // Loading, parsed-data, and clear-loading transitions all notify.
      expect(notified, greaterThan(0));
    });

    test('sends customer_name query param when a query is given', () async {
      fakeApi.stub('GET /salons/appointments/', {'results': []});

      await provider.loadAppointments(query: 'sam');

      expect(fakeApi.calls.single['queryParams'], {'customer_name': 'sam'});
    });

    test('API failure sets error, rethrows, and clears loading', () async {
      fakeApi.stubError(
        'GET /salons/appointments/',
        Exception('server exploded'),
      );

      await expectLater(provider.loadAppointments(), throwsA(isException));

      expect(provider.hasError, isTrue);
      expect(provider.error, contains('server exploded'));
      expect(provider.isLoading, isFalse);
    });
  });

  group('bookAppointment (with fake ApiService)', () {
    late FakeApiService fakeApi;

    setUp(() {
      fakeApi = FakeApiService();
      provider = AppointmentProvider(apiService: fakeApi);
    });

    test('returns the API response and reloads on success', () async {
      fakeApi.stub('bookAppointment', {'id': 42, 'status': 'SCHEDULED'});
      fakeApi.stub('GET /salons/appointments/', {'results': []});

      final result = await provider.bookAppointment({'service': 1});

      expect(result, {'id': 42, 'status': 'SCHEDULED'});
      expect(fakeApi.calls.map((c) => c['method']), ['bookAppointment', 'GET']);
      expect(provider.hasError, isFalse);
      expect(provider.isLoading, isFalse);
    });

    test('booking failure sets error and rethrows', () async {
      fakeApi.stubError('bookAppointment', Exception('slot taken'));

      await expectLater(
        provider.bookAppointment({'service': 1}),
        throwsA(isException),
      );

      expect(provider.hasError, isTrue);
      expect(provider.error, contains('slot taken'));
      expect(provider.isLoading, isFalse);
      // The reload is skipped when booking throws.
      expect(fakeApi.calls, hasLength(1));
    });
  });
}
