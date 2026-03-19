import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

    _loadAppStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAppStatus() async {
    // Artificial delay to show beautiful animation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // TODO: Ideally check token in secure storage here if persistence exists
    final bool isLoggedIn = authProvider.isAuthenticated;

    if (isLoggedIn) {
      final userRole = authProvider.userType?.name.toLowerCase() ?? 'customer';
      _navigateBasedOnRole(userRole);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'owner':
        Navigator.pushReplacementNamed(context, '/owner_dashboard');
        break;
      case 'employee':
        Navigator.pushReplacementNamed(context, '/employee_dashboard');
        break;
      case 'receptionist':
        Navigator.pushReplacementNamed(context, '/receptionist_dashboard');
        break;
      case 'intern':
        Navigator.pushReplacementNamed(context, '/intern_dashboard');
        break;
      case 'customer':
      default:
        Navigator.pushReplacementNamed(context, '/customer_home');
    }
  }

  String _getLogoAsset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    if (isArabic) {
      return isDark ? 'assets/images/logo_ar_dark.png' : 'assets/images/logo_ar_light.png';
    } else {
      return isDark ? 'assets/images/logo_en_dark.png' : 'assets/images/logo_en_light.png';
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
            image: const AssetImage('assets/images/bg_faded.png'),
            fit: BoxFit.cover,
            opacity: isDark ? 0.05 : 0.08,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.black, const Color(0xff121212)]
                : [const Color(0xffFDFBF7), const Color(0xffF3EFDF)],
          ),
        ),
        child: Center(
          child: ScaleTransition(
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
                      Icon(Icons.cut_rounded, size: 80, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'NA3EEMAN',
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
          ),
        ),
      ),
    );
  }
}
