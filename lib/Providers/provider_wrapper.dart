import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../Helpers/config.dart';
import '../Services/business_service.dart';
import '../Services/api/api_service.dart';
import 'app_providers.dart';
import 'features/app_state_provider.dart';
import 'features/auth_provider.dart';
import 'features/salon_provider.dart';
import 'features/appointment_provider.dart';
import 'features/cart_provider.dart';
import 'features/staff_provider.dart';
import 'features/subscription_provider.dart';
import 'features/favorites_provider.dart';
import 'features/expert_provider.dart';
import 'features/profit_provider.dart';
import 'features/settings_provider.dart';
// import 'features/points_provider.dart';
import 'features/inventory_provider.dart'; // Added
import 'features/offers_provider.dart';
import 'features/owner_provider.dart'; // ← Owner module
import 'features/intern_provider.dart'; // Added
import 'features/notification_provider.dart';
import 'features/points_provider.dart';
import 'features/admin_analytics_provider.dart';
import 'features/admin_service_provider.dart';
import 'features/schedule_provider.dart';
import 'features/gift_card_provider.dart';
import '../Helpers/inventory_helpers.dart'; // Added
import 'locale_provider.dart';

// Provider List for MultiProvider
List<SingleChildWidget> providers = [
  // ── Auth (must be first as many others depend on it) ──
  ChangeNotifierProvider(create: (_) => AuthProvider()),

  // ── Theme & RBAC (now depends on Auth to sync gender & roles) ──
  ChangeNotifierProxyProvider<AuthProvider, ThemeProvider>(
    create: (_) => ThemeProvider(brightness: Brightness.light),
    update: (_, authProvider, themeProvider) =>
        themeProvider!..updateAuth(authProvider),
  ),
  ChangeNotifierProxyProvider<AuthProvider, RBACProvider>(
    create: (_) => RBACProvider(),
    update: (_, authProvider, rbacProvider) =>
        rbacProvider!..updateAuth(authProvider),
  ),
  ChangeNotifierProvider(create: (_) => LocaleProvider()),

  // Independent providers
  ChangeNotifierProvider(create: (_) => AppStateProvider()),
  ChangeNotifierProvider(create: (_) => SettingsProvider()),

  // Dependent providers - depend on AuthProvider
  ChangeNotifierProxyProvider<AuthProvider, SalonProvider>(
    create: (_) => SalonProvider(),
    update: (_, authProvider, salonProvider) =>
        salonProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider2<
    AuthProvider,
    SalonProvider,
    AppointmentProvider
  >(
    create: (_) => AppointmentProvider(),
    update: (_, authProvider, salonProvider, appointmentProvider) {
      final provider = appointmentProvider!..updateAuth(authProvider);
      // Resolve salon names for appointment reminder notifications.
      provider.salonNameResolver = (salonId) {
        for (final salon in salonProvider.salons) {
          if (salon.id == salonId) return salon.salonName;
        }
        return null;
      };
      return provider;
    },
  ),
  ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
    create: (_) => CartProvider(),
    update: (_, authProvider, cartProvider) =>
        cartProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, StaffProvider>(
    create: (_) => StaffProvider(),
    update: (_, authProvider, staffProvider) =>
        staffProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
    create: (_) => SubscriptionProvider(
      subscriptionService: SubscriptionService(
        apiService: ApiService(), // Add this
      ),
    ),
    update: (_, authProvider, subscriptionProvider) =>
        subscriptionProvider!..updateAuth(authProvider),
  ),

  // Independent providers (no auth proxy needed — handles missing token gracefully)
  ChangeNotifierProvider(create: (_) => FavoritesProvider()),

  // ── OwnerProvider ─────────────────────────────────────────────────────────
  ChangeNotifierProxyProvider<AuthProvider, OwnerProvider>(
    create: (_) => OwnerProvider(),
    update: (_, authProvider, ownerProvider) =>
        ownerProvider!..updateAuth(authProvider),
  ),

  // ── ExpertProvider ───────────────────────────────────────────────────────────
  // Registered here so any route deep in the tree can call
  // Provider.of<ExpertProvider>(context) without a ProviderNotFoundException.
  ChangeNotifierProvider(create: (_) => ExpertProvider()),

  // ── ProfitProvider ───────────────────────────────────────────────────────────
  ChangeNotifierProvider(
    create: (_) => ProfitProvider(
      reportService: ProfitService(baseUrl: AppConfig.baseUrl),
    ),
  ),

  // ── OffersProvider added for Special Offers features ────────────────────────
  ChangeNotifierProvider(create: (_) => OffersProvider()),

  // ── Inventory Providers ──────────────────────────────────────────────────────
  Provider(create: (_) => InventoryService(ApiService())),
  ChangeNotifierProvider(
    create: (context) {
      final service = context.read<InventoryService>();
      return InventoryProvider(
        inventoryService: service,
        inventoryHelpers: InventoryHelpers(service),
      );
    },
  ),
  ChangeNotifierProvider(create: (_) => InternProvider()),
  ChangeNotifierProvider(create: (_) => AdminAnalyticsProvider()),
  ChangeNotifierProvider(create: (_) => AdminServiceProvider()),
  ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ChangeNotifierProvider(create: (_) => ScheduleProvider()),
  ChangeNotifierProvider(create: (_) => GiftCardProvider()),
  ChangeNotifierProvider(create: (_) => PointsProvider()),
];
