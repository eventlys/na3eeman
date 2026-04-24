import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/customized/animations.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/enums/gender.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../Core/constants/app_roles.dart';
import '../sidebar_controller.dart';


class UserProfileSection extends StatelessWidget {
  final SidebarController controller;

  const UserProfileSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appStateProvider = Provider.of<AppStateProvider>(context);

    // Get user data directly from providers without using User model
    final isAuthenticated = authProvider.isAuthenticated;
    final userEmail = appStateProvider.userEmail ?? 'Not logged in';
    final userRole = appStateProvider.userRole;
    final userGender = appStateProvider.userGender;

    // Extract name from email or use provider data
    final displayName = _getDisplayName(authProvider, appStateProvider, userEmail);

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            -100 + (controller.animation.value * 100),
            0,
          ),
          child: Opacity(
            opacity: controller.animation.value,
            child: child,
          ),
        );
      },
      child: DelayedWidget(
        delay: const Duration(milliseconds: 50),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture - Using default based on role/gender
              _buildProfilePicture(userGender, userRole),
              const SizedBox(height: 16),
              // User Name
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // User Email
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // User Role Badge
              if (isAuthenticated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(userRole),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(userRole),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              // Authentication Status
              if (!isAuthenticated)
                Text(
                  'Please log in',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build profile picture widget - using default icons only
  Widget _buildProfilePicture(Gender gender, UserRole role) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: _getRoleColor(role).withValues(alpha: 0.2),
      child: Icon(
        _getProfileIcon(gender, role),
        size: 40,
        color: _getRoleColor(role),
      ),
    );
  }

  // Get appropriate icon based on role and gender
  IconData _getProfileIcon(Gender gender, UserRole role) {
    switch (role) {
      case UserRole.employee:
        return Icons.content_cut; // Scissors icon for barber
      case UserRole.admin:
      case UserRole.owner:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return Icons.business; // Business icon for owner
      case UserRole.customer:
      default:
        return gender == Gender.female ? Icons.face_3 : Icons.face; // Male/female face icons
    }
  }

  // Helper methods
  String _getDisplayName(AuthProvider authProvider, AppStateProvider appStateProvider, String userEmail) {
    if (!authProvider.isAuthenticated) {
      return 'Guest User';
    }

    // Try to get name from userEmail first
    final emailName = userEmail.split('@').first;
    if (emailName.isNotEmpty && emailName != 'Not logged in') {
      // Capitalize first letter of each word
      final nameParts = emailName.split('.');
      if (nameParts.length > 1) {
        return nameParts.map((part) => part[0].toUpperCase() + part.substring(1)).join(' ');
      }
      return emailName[0].toUpperCase() + emailName.substring(1);
    }

    // Final fallback based on role
    switch (appStateProvider.userRole) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.employee:
        return 'Staff';
      case UserRole.owner:
      case UserRole.admin:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return 'Salon Owner';
      default:
        return 'User';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Colors.blue;
      case UserRole.employee:
        return Colors.green;
      case UserRole.admin:
      case UserRole.owner:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.employee:
        return 'Staff';
      case UserRole.admin:
      case UserRole.owner:
      case UserRole.ownerEmployee:
      case UserRole.ownerOwner:
        return 'Salon Owner';
      default:
        return 'User';
    }
  }
}

