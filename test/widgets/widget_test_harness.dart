import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Transitive dependency used only to type-check caught async errors.
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:na3eeman/Providers/features/appointment_provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Providers/features/expert_provider.dart';
import 'package:na3eeman/Providers/features/gift_card_provider.dart';
import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/Providers/features/points_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:na3eeman/Services/repositories/auth_repository.dart';
import 'package:na3eeman/Services/storage_service.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared harness for the widget smoke tests in this folder.
///
/// These are the first widget tests in the suite, written ahead of a large
/// refactoring with a characterization mindset: they capture the current
/// "renders without throwing" behavior of key screens and fix nothing.
///
/// Environment traps handled here (mirroring test/auth/auth_provider_test.dart):
/// - flutter_secure_storage → stubbed method channel.
/// - SharedPreferences → in-memory mock values.
/// - path_provider → Linux Dart implementation against a temp directory.
/// - easy_localization → deliberately NOT initialized. The screens call
///   `.tr()`, which falls back to rendering the raw key when
///   EasyLocalization is absent from the tree. Raw keys are acceptable for
///   smoke tests.
/// - Network → ApiService is a singleton whose baseUrl comes from
///   `AppConfig.baseUrl`, and `Environment._config` is `late` (never
///   initialized in tests), so any provider/screen that fires an inline
///   request on init fails with a LateInitializationError. Providers swallow
///   their own load errors except [ExpertProvider.loadExperts], which
///   rethrows; the harness swallows that specific pattern.
///
/// IMPORTANT: all async work here runs in `setUp` (real event loop), never
/// inside a `testWidgets` body (fake-async clock). Awaiting real I/O such as
/// `Directory.systemTemp.createTemp`, `SharedPreferences.getInstance`, or
/// `UnifiedStorageService().initialize()` inside a test body deadlocks —
/// verified empirically. `UnifiedStorageService().initialize()` additionally
/// opens Hive boxes, which never completes under fake async even from
/// `setUp`, so it is intentionally not called; the screens under test only
/// read SharedPreferences and flutter_secure_storage on initial render.

/// In-memory store behind the flutter_secure_storage method channel.
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

/// Minimal [PathProviderPlatform] that points every directory at [root].
///
/// The stock `PathProviderLinux.private(...)` resolves
/// getApplicationDocumentsPath via `xdg-user-dirs`, which (a) ignores the
/// injected environment when xdg-user-dirs is absent, returning the real
/// `$HOME/Documents`, and (b) therefore makes every concurrent test file open
/// the same Hive lock files → FileSystemException lock conflicts. This fake
/// keeps everything in a per-run temp dir.
class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this.root);
  final String root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getLibraryPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;

  @override
  Future<String?> getDownloadsPath() async => root;
}

/// Bundle returned by [setUpWidgetTestEnvironment] with everything a smoke
/// test needs.
class WidgetTestFixture {
  final FakeSecureStorageChannel secureChannel;

  /// An AuthProvider signed in as [smokeTestUser], loaded from the mocked
  /// storage. Build it in setUp, dispose it in the test's addTearDown.
  final AuthProvider signedInAuth;

  /// A signed-out AuthProvider.
  final AuthProvider signedOutAuth;

  WidgetTestFixture({
    required this.secureChannel,
    required this.signedInAuth,
    required this.signedOutAuth,
  });

  void dispose() {
    secureChannel.tearDown();
  }
}

/// Call from a plain `setUp` (NOT inside testWidgets). Performs the real-I/O
/// setup on the real event loop and returns a ready-to-use fixture.
Future<WidgetTestFixture> setUpWidgetTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final secureChannel = FakeSecureStorageChannel()..setUp();

  final tempDir = await Directory.systemTemp.createTemp('widget_smoke_test_');
  PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
  // Initialize the real storage singleton (SharedPreferences + Hive) on the
  // real event loop. This must run in setUp, not inside a test body.
  await UnifiedStorageService().initialize();

  // Seed a signed-in session in the mocked storage.
  secureChannel.store['auth_token'] = 'test_jwt_token';
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_profile', json.encode(smokeTestUser()));

  final signedInAuth = AuthProvider(
    authRepository: AuthRepository(ApiService()),
  );
  await signedInAuth.loadSavedAuth();

  final signedOutAuth = AuthProvider(
    authRepository: AuthRepository(ApiService()),
  );

  // Install the async-error guard. This is a plain (non-widget) callback, so
  // it is safe to set from setUp; it stays installed for the whole file.
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (_isExpectedAsyncError(details.exception)) {
      // ignore: avoid_print
      print('[harness] swallowed async error: ${details.exception}');
      return;
    }
    previousOnError?.call(details);
  };

  return WidgetTestFixture(
    secureChannel: secureChannel,
    signedInAuth: signedInAuth,
    signedOutAuth: signedOutAuth,
  );
}

/// The screens under test fire network calls on init through the inline
/// `ApiService()` singleton; with `Environment._config` uninitialized this
/// throws LateInitializationError inside async gaps. Most providers swallow
/// it; ExpertProvider.loadExperts rethrows, so it can surface as an uncaught
/// async error. Swallowing exactly these errors (and nothing else) keeps the
/// smoke test about "rendered without throwing synchronously".
bool _isExpectedAsyncError(Object? error) =>
    error.toString().contains('LateInitializationError') ||
    error is SocketException ||
    error is HandshakeException ||
    error is http.ClientException;

/// Pumps [page] inside a MaterialApp with the given [mockProviders] and
/// optional [routeSettings] (used to inject ModalRoute arguments, e.g. for
/// BookAppointmentPage).
///
/// Uses pump() + pump(Duration) rather than pumpAndSettle: the screens start
/// animations/timers (sidebar controller, DelayedWidget, RefreshIndicator)
/// that never settle in a fake-async test.
Future<void> pumpPageWithProviders(
  WidgetTester tester, {
  required Widget page,
  required List<SingleChildWidget> mockProviders,
  RouteSettings? routeSettings,
}) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final Widget child = routeSettings == null
      ? page
      : Builder(
          builder: (context) {
            // Push a route carrying the settings so ModalRoute.of(context)
            // inside the page sees the arguments.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  settings: routeSettings,
                  builder: (_) => page,
                ),
              );
            });
            return const Scaffold(body: SizedBox.shrink());
          },
        );

  await tester.pumpWidget(
    MultiProvider(
      providers: mockProviders,
      child: MaterialApp(home: child),
    ),
  );
  // Let post-frame callbacks and swallowable async loads run.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Builds the provider list used by the smoke tests. Only the providers each
/// screen actually consumes are supplied, as `ChangeNotifierProvider.value`
/// so the test owns their lifecycle.
List<SingleChildWidget> smokeProviders({
  AuthProvider? auth,
  PointsProvider? points,
  AppointmentProvider? appointments,
  ExpertProvider? experts,
  GiftCardProvider? giftCards,
  OwnerProvider? owner,
}) {
  return [
    if (auth != null) ChangeNotifierProvider<AuthProvider>.value(value: auth),
    if (points != null)
      ChangeNotifierProvider<PointsProvider>.value(value: points),
    if (appointments != null)
      ChangeNotifierProvider<AppointmentProvider>.value(value: appointments),
    if (experts != null)
      ChangeNotifierProvider<ExpertProvider>.value(value: experts),
    if (giftCards != null)
      ChangeNotifierProvider<GiftCardProvider>.value(value: giftCards),
    if (owner != null)
      ChangeNotifierProvider<OwnerProvider>.value(value: owner),
  ];
}

/// Test user matching the production payload shape (numeric id).
Map<String, dynamic> smokeTestUser({String role = 'customer'}) => {
  'id': 123,
  'name': 'Test User',
  'email': 'test@example.com',
  'phone': '+1234567890',
  'profilePicture': 'https://example.com/avatar.jpg',
  'role': role,
  'gender': 'MALE',
  'created_at': '2026-01-01T00:00:00.000Z',
  'updated_at': '2026-01-01T00:00:00.000Z',
};
