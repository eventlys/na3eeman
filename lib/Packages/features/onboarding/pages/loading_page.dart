// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../Helpers/connectivity_helper.dart';
import '../../../../Services/ui/navigation_service.dart';
import '../../../../Routes/route_names.dart';
import '../../../../core/theme/colors.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _bootstrap();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // Gate on connectivity: if the device is offline, hold here and show the
    // offline state instead of launching into an app whose calls will fail.
    final connectivity = ConnectivityHelper();
    await connectivity.initialize();
    final online = await connectivity.checkConnection();

    if (!mounted) return;

    if (!online) {
      setState(() => _isOffline = true);
      return;
    }

    await _proceed();
  }

  Future<void> _proceed() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load auth details from storage (loads token and restores session)
    await authProvider.loadSavedAuth();

    if (!mounted) return;
    final bool isLoggedIn = authProvider.isAuthenticated;

    if (isLoggedIn) {
      final userRole = authProvider.userType?.name ?? 'customer';
      final user = authProvider.user;
      final String? tier = user?.subscriptionTier?.name.toUpperCase();

      NavigationService.navigateToHomeBasedOnRole(
        context,
        userRole,
        tier: tier,
      );
    } else {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  Future<void> _retry() async {
    setState(() => _isOffline = false);
    await _bootstrap();
  }

  String _getLogoAsset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    if (isArabic) {
      return isDark
          ? 'assets/logos/logo_ar_dark.png'
          : 'assets/logos/logo_ar_light.png';
    } else {
      return isDark
          ? 'assets/logos/logo_en_dark.png'
          : 'assets/logos/logo_en_light.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/logos/bg_faded.png'),
            fit: BoxFit.cover,
            opacity: isDark ? 0.05 : 0.08,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.black, AppColors.darkBackground]
                : [AppColors.cream, AppColors.cream100],
          ),
        ),
        child: Center(
          child: _isOffline ? _buildOffline(theme) : _buildLogo(theme),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _animationController.drive(Tween(begin: 0.8, end: 1.0)),
        child: Image.asset(
          _getLogoAsset(context),
          width: 180,
          height: 180,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text logo if asset doesn't load
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cut_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'na3eeman'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOffline(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'no_internet_connection'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'check_connection_and_retry'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}
