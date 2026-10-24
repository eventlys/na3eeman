import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Packages/features/appointments/pages/book_appointment_page.dart';
import 'package:na3eeman/Providers/features/expert_provider.dart';
import 'package:na3eeman/Providers/features/gift_card_provider.dart';
import 'package:na3eeman/Providers/features/points_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';

import 'widget_test_harness.dart';

/// Smoke tests for [BookAppointmentPage].
///
/// Characterization mindset: capture current behavior, fix nothing. On init
/// the page fires `PointsProvider.loadBalance` and
/// `GiftCardProvider.loadMyCards`; both hit the inline `ApiService` singleton
/// whose `Environment._config` is uninitialized in tests, so they fail with
/// LateInitializationError — which both providers swallow.
void main() {
  late WidgetTestFixture fixture;

  setUp(() async {
    fixture = await setUpWidgetTestEnvironment();
  });

  tearDown(() {
    fixture.dispose();
  });

  testWidgets('renders its loading state without throwing', (tester) async {
    final auth = fixture.signedOutAuth;
    addTearDown(auth.dispose);
    final points = PointsProvider(apiService: ApiService());
    addTearDown(points.dispose);
    final experts = ExpertProvider();
    addTearDown(experts.dispose);
    final giftCards = GiftCardProvider(apiService: ApiService());
    addTearDown(giftCards.dispose);

    // No ModalRoute arguments → salonData stays null → spinner branch.
    await pumpPageWithProviders(
      tester,
      page: const BookAppointmentPage(),
      mockProviders: smokeProviders(
        auth: auth,
        points: points,
        experts: experts,
        giftCards: giftCards,
      ),
    );

    expect(find.byType(BookAppointmentPage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // App bar title (raw .tr() key fallback).
    expect(find.text('book_appointment'), findsOneWidget);
    // Confirm button still renders in the bottom bar.
    expect(find.text('confirm_appointment'), findsOneWidget);
  });

  // NOTE: a "booking form with salon arguments" variant is intentionally
  // OMITTED. Supplying `salonData` via route arguments moves the page past
  // its spinner branch, but `didChangeDependencies` then calls
  // `ExpertProvider.refreshExperts` *synchronously*
  // (book_appointment_page.dart:94), and `ExpertProvider.loadExperts` calls
  // `notifyListeners()` before its first `await`
  // (expert_provider.dart:40). Because the page also `context.watch`es
  // ExpertProvider, that notification fires during the very first build →
  // "setState() or markNeedsBuild() called during build" in debug/test mode.
  // This is a pre-existing product bug, not a mocking gap. Per the
  // characterization mandate (capture current behavior, fix nothing) it is
  // documented here instead of being patched in the test.
}
