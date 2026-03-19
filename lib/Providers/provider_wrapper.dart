import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:get_it/get_it.dart';
import '../Helpers/config.dart';
import '../Services/business_service.dart';
import '../Services/api/api_service.dart';
import '../Services/ui/navigation_service.dart';
import '../Packages/Core/utils/helpers/themes_helpers.dart';
import 'app_providers.dart';
// import 'base_provider.dart';
import 'features/app_state_provider.dart';
import 'features/auth_provider.dart';
import 'features/shop_provider.dart';
import 'features/appointment_provider.dart';
import 'features/cart_provider.dart';
import 'features/staff_provider.dart';
import 'features/subscription_provider.dart';
import 'features/favorites_provider.dart';
import 'features/barber_provider.dart';
import 'features/profit_provider.dart';
import 'features/settings_provider.dart';
// import 'features/points_provider.dart';
// import 'features/inventory_provider.dart';
import 'features/offers_provider.dart';

// Service Locator
final GetIt locator = GetIt.instance;


class DependencyInjection {
  static void setup() {
    // Services
    // locator.registerLazySingleton(() => AuthService());
    locator.registerLazySingleton(() => ApiService());
    locator.registerLazySingleton(() => NavigationService());

    // Providers will be registered through Provider package
  }

  static T get<T extends Object>() => locator.get<T>();
}

// Provider List for MultiProvider
List<SingleChildWidget> providers = [
  // ── Theme & RBAC (must be first — everything depends on these) ──
  ChangeNotifierProvider(
    create: (_) =>
        ThemeProvider(brightness: Brightness.light),
  ),
  ChangeNotifierProvider(create: (_) => RBACProvider()),

  // Independent providers
  ChangeNotifierProvider(create: (_) => AppStateProvider()),
  ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ChangeNotifierProvider(create: (_) => AuthProvider()),

  // Dependent providers - depend on AuthProvider
  ChangeNotifierProxyProvider<AuthProvider, ShopProvider>(
    create: (_) => ShopProvider(),
    update: (_, authProvider, shopProvider) =>
        shopProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
    create: (_) => AppointmentProvider(),
    update: (_, authProvider, appointmentProvider) =>
        appointmentProvider!..updateAuth(authProvider),
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

  // ── BarberProvider ───────────────────────────────────────────────────────────
  // Registered here so any route deep in the tree can call
  // Provider.of<BarberProvider>(context) without a ProviderNotFoundException.
  ChangeNotifierProvider(create: (_) => BarberProvider()),

  // ── ProfitProvider ───────────────────────────────────────────────────────────
  ChangeNotifierProvider(
    create: (_) => ProfitProvider(
      reportService: ProfitService(baseUrl: AppConfig.baseUrl),
    ),
  ),

  // ── OffersProvider added for Special Offers features ────────────────────────
  ChangeNotifierProvider(create: (_) => OffersProvider()),
];

