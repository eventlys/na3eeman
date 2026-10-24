import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Packages/features/home/pages/customer_home.dart';
import 'package:na3eeman/Providers/features/appointment_provider.dart';
import 'package:na3eeman/Providers/features/points_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';
import 'package:provider/provider.dart';

import 'widget_test_harness.dart';

/// Smoke tests for [CustomerHomePage].
///
/// Characterization mindset: capture the current render behavior, fix
/// nothing. The page fires two async loads on init — `_loadCategories` via an
/// inline `ApiService()` (fails with LateInitializationError because
/// `Environment.init` never ran in tests; the page catches it and leaves the
/// categories grid empty) and `PointsProvider.loadBalance` (also swallowed).
/// `.tr()` renders raw keys because EasyLocalization is uninitialized.
void main() {
  late WidgetTestFixture fixture;

  setUp(() async {
    fixture = await setUpWidgetTestEnvironment();
  });

  tearDown(() {
    fixture.dispose();
  });

  testWidgets('renders loading spinner before data resolves', (tester) async {
    final auth = fixture.signedInAuth;
    addTearDown(auth.dispose);
    final points = PointsProvider(apiService: ApiService());
    addTearDown(points.dispose);
    final appointments = AppointmentProvider();
    addTearDown(appointments.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: smokeProviders(
          auth: auth,
          points: points,
          appointments: appointments,
        ),
        child: const MaterialApp(home: CustomerHomePage()),
      ),
    );

    // First frame: _isLoading is still true → spinner branch.
    expect(find.byType(CustomerHomePage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // NOTE: the "full home page" variant (pumping past the spinner so the AppBar
  // and body build) is intentionally OMITTED. It cannot render in a debug/test
  // build because of a pre-existing layout bug in this screen, unrelated to
  // mocking: the AppBar title Row wraps `GlobalSearchBar` in
  // `Expanded`, but `GlobalSearchBar`'s own root is *also* an `Expanded`
  // (lib/core/widgets/dashboard/dashboard_widgets.dart:160). Two `Expanded`
  // ParentDataWidgets then compete for the same RenderObject →
  // "Incorrect use of ParentDataWidget". This crashes the frame in debug mode
  // (in release the assert is compiled out). Per the characterization mandate
  // (capture current behavior, fix nothing) the broken full render is
  // documented here rather than "fixed" in the test.
}
