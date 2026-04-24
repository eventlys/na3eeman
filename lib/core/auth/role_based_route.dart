import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Providers/features/auth_provider.dart';
import '../../../core/enums/app_enums.dart';
import '../../Packages/Core/constants/app_roles.dart';

class RoleBasedRoute extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget page;

  const RoleBasedRoute({
    super.key,
    required this.allowedRoles,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userRole = authProvider.user?.role ?? UserRole.customer;

    if (allowedRoles.contains(userRole)) {
      return page;
    }

    // Redirect to home or show an unauthorized page
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Unauthorized Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.noPermissionMessage),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: Text(AppLocalizations.of(context)!.backToHome),
            ),
          ],
        ),
      ),
    );
  }
}
