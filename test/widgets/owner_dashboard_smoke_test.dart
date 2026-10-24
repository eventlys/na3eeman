import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:na3eeman/Packages/features/navigation/sidebar.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/pages/owner_dashboard_page.dart';
import 'package:na3eeman/Packages/features/owner/dashboard/widgets/shared/practitioner_mode_toggle.dart';
import 'package:na3eeman/Packages/features/staff/widgets/today_appointments_overview.dart';
import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/core/widgets/dashboard/dashboard_widgets.dart';

import 'widget_test_harness.dart';

/// Smoke tests for [OwnerDashboardPage].
///
/// Characterization mindset: capture current behavior, fix nothing. With a
/// signed-out OwnerProvider the current implementation hardcodes
/// `tier => OwnerSubscriptionTier.empire` and `isSubscriptionActive => true`,
/// so no subscription banner renders, `loadDashboardAnalytics` early-returns
/// (`activeSalonId == null`), and `TodayAppointmentsOverview`'s inline
/// ApiService call fails (LateInitializationError, caught by the widget).
void main() {
  late WidgetTestFixture fixture;

  setUp(() async {
    fixture = await setUpWidgetTestEnvironment();
  });

  tearDown(() {
    fixture.dispose();
  });

  testWidgets('renders dashboard shell for signed-out owner', (tester) async {
    final auth = fixture.signedOutAuth;
    addTearDown(auth.dispose);
    final owner = OwnerProvider();
    addTearDown(owner.dispose);

    await pumpPageWithProviders(
      tester,
      page: const OwnerDashboardPage(),
      mockProviders: smokeProviders(auth: auth, owner: owner),
    );

    expect(find.byType(OwnerDashboardPage), findsOneWidget);
    // App bar widgets.
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.byType(GlobalSearchBar), findsOneWidget);
    expect(find.byType(PractitionerModeToggle), findsOneWidget);
    expect(find.byType(Sidebar), findsOneWidget);
    // Tier header (raw .tr() key fallback) and current hardcoded tier badge.
    expect(find.text('welcome_back'), findsOneWidget);
    expect(find.text('Empire'), findsOneWidget);
    // Universal dashboard widgets.
    expect(find.byType(TodayAppointmentsOverview), findsOneWidget);
    expect(find.byType(FeedbackSection), findsOneWidget);
  });
}
