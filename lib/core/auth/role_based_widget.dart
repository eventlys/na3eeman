import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Providers/features/auth_provider.dart';
import '../../../core/enums/app_enums.dart';
import '../../Packages/Core/constants/app_roles.dart';

class RoleBasedWidget extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.user?.role ?? UserRole.customer;

    if (allowedRoles.contains(userRole)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}
