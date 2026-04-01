// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import 'package:easy_localization/easy_localization.dart';

class UserInfoHeader extends StatelessWidget {
  const UserInfoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    // Check if user is authenticated and has data
    if (!authProvider.isAuthenticated || authProvider.user == null) {
      return _buildLoadingState();
    }

    // Get user data from AuthProvider
    final userData = _getUserDataFromAuthProvider(authProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildProfilePicture(userData),
          const SizedBox(width: 16),
          _buildUserInfo(context, userData, authProvider),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(Map<String, dynamic> userData) {
    final profilePicture = userData['avatar'] ?? userData['profilePicture'];

    return CircleAvatar(
      radius: 40,
      backgroundImage: _getProfileImage(profilePicture),
      backgroundColor: Colors.grey[300],
      child: _shouldShowPlaceholder(profilePicture)
          ? const Icon(Icons.person, size: 40, color: Colors.grey)
          : null,
    );
  }

  ImageProvider? _getProfileImage(String? profilePicture) {
    if (profilePicture != null && profilePicture.isNotEmpty) {
      // Check if it's a network URL or local asset
      if (profilePicture.startsWith('http')) {
        return NetworkImage(profilePicture);
      } else {
        return AssetImage(profilePicture);
      }
    }
    return null;
  }

  bool _shouldShowPlaceholder(String? profilePicture) {
    return profilePicture == null || profilePicture.isEmpty;
  }

  Widget _buildUserInfo(BuildContext context, Map<String, dynamic> userData, AuthProvider authProvider) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getUserName(userData),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getUserEmail(userData),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildEditProfileButton(context, authProvider),
        ],
      ),
    );
  }

  String _getUserName(Map<String, dynamic> userData) {
    // Try to get name from various possible fields
    if (userData['name'] != null && userData['name'].toString().isNotEmpty) {
      return userData['name'].toString();
    }

    // Try first and last name combination
    final firstName = userData['firstName'] ?? userData['first_name'];
    final lastName = userData['lastName'] ?? userData['last_name'];
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    } else if (firstName != null) {
      return firstName.toString();
    } else if (lastName != null) {
      return lastName.toString();
    }

    // Try username
    if (userData['username'] != null && userData['username'].toString().isNotEmpty) {
      return userData['username'].toString();
    }

    // Fallback to email username
    final email = userData['email'] ?? '';
    return email.split('@').first;
  }

  String _getUserEmail(Map<String, dynamic> userData) {
    return userData['email']?.toString() ?? 'No email';
  }

  Widget _buildEditProfileButton(BuildContext context, AuthProvider authProvider) {
    return InkWell(
      onTap: () => _handleEditProfile(context, authProvider),
      child: Text(
        'Edit Profile',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleEditProfile(BuildContext context, AuthProvider authProvider) {
    // Navigate to edit profile screen or show edit dialog
    _showEditProfileOptions(context, authProvider);
  }

  void _showEditProfileOptions(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile Information'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditProfileScreen(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text('change_profile_picture'.tr()),
              onTap: () {
                Navigator.pop(context);
                _showImageSourceDialog(context, authProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfileScreen(BuildContext context) {
    // Navigate to edit profile screen - this would be implemented in your app navigation
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
  }

  void _showImageSourceDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('change_profile_picture'.tr()),
        content: const Text('Select image source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement camera functionality
            },
            child: Text('camera'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement gallery functionality
            },
            child: Text('gallery'.tr()),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getUserDataFromAuthProvider(AuthProvider authProvider) {
    final user = authProvider.user;

    if (user == null) return {};

    // Simply convert the User object to JSON
    return user.toJson();
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
