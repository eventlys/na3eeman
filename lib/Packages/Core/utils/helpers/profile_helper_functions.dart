import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../Services/core/user_service.dart';
// import 'package:easy_localization/easy_localization.dart';

class ProfileHelperFunctions {
  static void initializeControllers({
    required UserProfile? userProfile,
    required Map<String, TextEditingController> controllers,
  }) {
    if (userProfile == null) return;

    // Split the name into first and last name if possible
    final nameParts = userProfile.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    controllers['firstName']!.text = firstName;
    controllers['lastName']!.text = lastName;
    controllers['email']!.text = userProfile.email;
    controllers['phone']!.text = userProfile.phone ?? '';
    controllers['bio']!.text = ''; // Not available in UserProfile
    controllers['location']!.text = ''; // Not available in UserProfile
    controllers['specialties']!.text = ''; // Not available in UserProfile
  }

  static UserProfile updateProfileFromControllers({
    required UserProfile userProfile,
    required Map<String, TextEditingController> controllers,
  }) {
    final firstName = controllers['firstName']!.text;
    final lastName = controllers['lastName']!.text;
    final fullName = '$firstName $lastName'.trim();

    // Note: Since UserProfile doesn't have a copyWith method and is immutable,
    // you'll need to create a new instance. You may want to add a copyWith
    // method to your UserProfile class for better maintainability.
    return UserProfile(
      id: userProfile.id,
      name: fullName.isNotEmpty ? fullName : userProfile.name,
      email: controllers['email']!.text.isNotEmpty
          ? controllers['email']!.text
          : userProfile.email,
      phone: controllers['phone']!.text.isNotEmpty
          ? controllers['phone']!.text
          : userProfile.phone,
      avatar: userProfile.avatar,
      emailVerifiedAt: userProfile.emailVerifiedAt,
      createdAt: userProfile.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static Future<void> saveToBackend({
    required UserProfile profile,
    required BuildContext context,
    required VoidCallback onError,
  }) async {
    try {
      // Implement your actual API call here
      print('Saving profile to API: $profile');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Replace with your actual API call:
      // await ApiService.updateProfile(profile);

      print('Profile saved successfully');
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
      onError();
    }
  }

  static void showDeleteConfirmationDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_profile".tr()),
        content: Text("are_you_sure_you_want_to_delete_your_profile_this".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text("delete".tr(), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Future<void> performDelete({
    required BuildContext context,
    required VoidCallback onSuccess,
  }) async {
    try {
      // Implement your delete API call here
      print('Deleting profile...');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Replace with your actual API call:
      // await ApiService.deleteProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("profile_deleted".tr())),
      );

      onSuccess();
    } catch (e) {
      print('Error deleting profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete profile: $e')),
      );
    }
  }

  static String getAccountType(UserProfile? userProfile) {
    if (userProfile == null) return 'User';
    // Since UserProfile doesn't have isOwner/isWorker fields,
    // you'll need to determine account type differently.
    // This could be based on user role, permissions, or other criteria.
    return 'User'; // Default to 'User' for now
  }

  static void showImagePickerDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("change_profile_picture".tr()),
        content: Text("choose_an_option".tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: Text("gallery".tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhoto();
            },
            child: Text("camera".tr()),
          ),
        ],
      ),
    );
  }

  static void _pickImageFromGallery() {
    // Implement gallery image picker
  }

  static void _takePhoto() {
    // Implement camera functionality
  }
}
