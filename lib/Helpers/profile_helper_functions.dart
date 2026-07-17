// ignore_for_file: use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/main_providers.dart';
import '../Services/core/user_service.dart';
import 'package:na3eeman/Helpers/logger.dart';
// import 'package:easy_localization/easy_localization.dart';

class ProfileHelperFunctions {
  // Initialize text controllers with user data
  static void initializeControllers({
    required Map<String, dynamic>? userData,
    required Map<String, TextEditingController> controllers,
  }) {
    if (userData == null) return;

    controllers['firstName']?.text = userData['firstName']?.toString() ?? '';
    controllers['lastName']?.text = userData['lastName']?.toString() ?? '';
    controllers['username']?.text = userData['username']?.toString() ?? '';
    controllers['email']?.text = userData['email']?.toString() ?? '';
    controllers['phone']?.text = userData['phone']?.toString() ?? '';
    controllers['bio']?.text = userData['bio']?.toString() ?? '';
    controllers['location']?.text = userData['location']?.toString() ?? '';

    // Handle specialties list conversion
    final specialties = userData['specialties'];
    if (specialties is List<dynamic>) {
      controllers['specialties']?.text = specialties
          .where((item) => item != null)
          .map((item) => item.toString())
          .join(', ');
    } else {
      controllers['specialties']?.text = specialties?.toString() ?? '';
    }
  }

  // Update user data from controllers
  static Map<String, dynamic> updateUserFromControllers({
    required Map<String, dynamic> userData,
    required Map<String, TextEditingController> controllers,
  }) {
    final updatedData = Map<String, dynamic>.from(userData);

    updatedData['firstName'] = controllers['firstName']?.text ?? '';
    updatedData['lastName'] = controllers['lastName']?.text ?? '';
    updatedData['username'] = controllers['username']?.text ?? '';
    updatedData['email'] = controllers['email']?.text ?? '';
    updatedData['phone'] = controllers['phone']?.text ?? '';
    updatedData['bio'] = controllers['bio']?.text ?? '';
    updatedData['location'] = controllers['location']?.text ?? '';

    // Handle specialties conversion back to list
    final specialtiesText = controllers['specialties']?.text ?? '';
    updatedData['specialties'] = specialtiesText
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    updatedData['updatedAt'] = DateTime.now();

    return updatedData;
  }

  // Save profile to backend
  static Future<void> saveToBackend({
    required Map<String, dynamic> profile,
    required BuildContext context,
    required Function() onError,
  }) async {
    try {
      final userService = UserService();
      final authProvider = context.read<AuthProvider>();

      // Prepare the data for the service layer
      final updateData = _prepareUpdateData(profile, authProvider);

      // Call the UserService to update the profile
      await userService.updateUserProfile(
        userId: authProvider.user!.id,
        profileData: updateData,
      );

      // Update the local provider state with the new data
      await _updateProviderState(profile, authProvider, context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile_updated_successfully".tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      onError();
    }
  }

  // Prepare the data in the format expected by the service
  static Map<String, dynamic> _prepareUpdateData(
    Map<String, dynamic> profile,
    AuthProvider authProvider,
  ) {
    return {
      'first_name': profile['firstName'],
      'last_name': profile['lastName'],
      'username': profile['username'],
      'email': profile['email'],
      'phone_number': profile['phone'],
      'bio': profile['bio'],
      'location': profile['location'],
      'specialties': profile['specialties'] is List
          ? (profile['specialties'] as List).join(',')
          : profile['specialties'],
      // Include any other fields that your backend expects
    };
  }

  // Update the provider state with the new profile data
  static Future<void> _updateProviderState(
    Map<String, dynamic> profile,
    AuthProvider authProvider,
    BuildContext context,
  ) async {
    try {
      // Create updated user object (you might need to adjust this based on your User model)
      final updatedUser = authProvider.user!.copyWith(
        firstName: profile['firstName'],
        lastName: profile['lastName'],
        email: profile['email'],
        phone: profile['phone'],
        location: profile['location'],
        // Add other fields as needed
      );

      // Update the provider
      authProvider.updateProfile(updatedUser: updatedUser);

      // Optionally refresh the user data from the server to ensure consistency
      await authProvider.refreshUserData();
    } catch (e) {
      // Log the error but don't show to user since the backend update was successful
      AppLogger.error('Error updating provider state: $e');
    }
  }

  // Show delete confirmation dialog
  static void showDeleteConfirmationDialog({
    required BuildContext context,
    required Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("delete_profile".tr()),
          content: Text(
            "are_you_sure_you_want_to_delete_your_profile_this".tr(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text("delete".tr(), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Perform profile deletion
  static Future<void> performDelete({
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final authProvider = AuthProvider();
      await authProvider.logout();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile_deleted_successfully".tr())),
      );

      onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete profile: $e')));
    }
  }

  // Show image picker dialog
  static void showImagePickerDialog({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("choose_from_gallery".tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement gallery picker
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text("take_a_photo".tr()),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement camera
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Get account type from user data
  static String getAccountType(Map<String, dynamic>? userData) {
    if (userData == null) return 'Customer';

    final role = userData['role']?.toString().toLowerCase() ?? 'customer';

    switch (role) {
      case 'expert':
        return 'Expert';
      case 'owner':
        return 'Salon Owner';
      case 'admin':
        return 'Administrator';
      default:
        return 'Customer';
    }
  }

  // Validate profile form
  static String? validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    switch (fieldName.toLowerCase()) {
      case 'email':
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case 'phone':
        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
        if (!phoneRegex.hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        break;
    }

    return null;
  }
}
