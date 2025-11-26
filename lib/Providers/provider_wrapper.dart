import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:get_it/get_it.dart';
import '../Services/business_service.dart';
import '../Services/api/api_service.dart';
import '../Services/ui/navigation_service.dart';
import 'main_providers.dart';

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
  // Independent providers
  ChangeNotifierProvider(create: (_) => AppStateProvider()),
  ChangeNotifierProvider(create: (_) => SettingsProvider()),
  ChangeNotifierProvider(create: (_) => AuthProvider()),

  // Dependent providers - depend on AuthProvider
  ChangeNotifierProxyProvider<AuthProvider, ShopProvider>(
    create: (_) => ShopProvider(),
    update: (_, authProvider, shopProvider) => shopProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
    create: (_) => AppointmentProvider(),
    update: (_, authProvider, appointmentProvider) => appointmentProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
    create: (_) => CartProvider(),
    update: (_, authProvider, cartProvider) => cartProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, StaffProvider>(
    create: (_) => StaffProvider(),
    update: (_, authProvider, staffProvider) => staffProvider!..updateAuth(authProvider),
  ),

  ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
    create: (_) => SubscriptionProvider(
      subscriptionService: SubscriptionService(
        apiService: ApiService(), // Add this
      ),
    ),
    update: (_, authProvider, subscriptionProvider) => subscriptionProvider!..updateAuth(authProvider),
  )
];
