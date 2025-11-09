import 'package:flutter/material.dart';
import '../../Models/profile_model.dart';

class ProfileHelperFunctions {
  static void initializeControllers({
    required UserProfile? userProfile,
    required Map<String, TextEditingController> controllers,
  }) {
    if (userProfile == null) return;

    controllers['firstName']!.text = userProfile.firstName ?? '';
    controllers['lastName']!.text = userProfile.lastName ?? '';
    controllers['username']!.text = userProfile.username ?? '';
    controllers['email']!.text = userProfile.email ?? '';
    controllers['phone']!.text = userProfile.phone ?? '';
    controllers['bio']!.text = userProfile.bio ?? '';
    controllers['location']!.text = userProfile.location ?? '';
    controllers['specialties']!.text = userProfile.specialties?.join(', ') ?? '';
  }

  static UserProfile updateProfileFromControllers({
    required UserProfile userProfile,
    required Map<String, TextEditingController> controllers,
  }) {
    return userProfile.copyWith(
      firstName: controllers['firstName']!.text.isEmpty ? null : controllers['firstName']!.text,
      lastName: controllers['lastName']!.text.isEmpty ? null : controllers['lastName']!.text,
      username: controllers['username']!.text.isEmpty ? null : controllers['username']!.text,
      email: controllers['email']!.text.isEmpty ? null : controllers['email']!.text,
      phone: controllers['phone']!.text.isEmpty ? null : controllers['phone']!.text,
      bio: controllers['bio']!.text.isEmpty ? null : controllers['bio']!.text,
      location: controllers['location']!.text.isEmpty ? null : controllers['location']!.text,
      specialties: controllers['specialties']!.text.isEmpty
          ? null
          : controllers['specialties']!.text.split(',').map((e) => e.trim()).toList(),
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
        title: const Text('Delete Profile'),
        content: const Text('Are you sure you want to delete your profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        const SnackBar(content: Text('Profile deleted')),
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
    if (userProfile.isOwner == true) return 'Owner';
    if (userProfile.isWorker == true) return 'Worker';
    return 'User';
  }

  static void showImagePickerDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: const Text('Choose an option'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _takePhoto();
            },
            child: const Text('Camera'),
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


